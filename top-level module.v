//=============================================================
// uart_top.v
// Top-level module: connects baud generator, UART TX, and UART RX
// Board-agnostic version — rename ports to match your board's
// pin names in Quartus Pin Planner (e.g., DE10-Lite, DE0-CV)
//=============================================================

module uart_top (
    input        CLOCK_50,     // 50 MHz onboard clock
    input        RESET_N,      // active-low reset push button
    input        KEY_SEND,     // push button to trigger transmit
    input  [7:0] SW,           // switches = data byte to send
    output [7:0] LED,          // LEDs = received data byte
    output       TX_PIN,       // UART TX output pin
    input        RX_PIN        // UART RX input pin
);

    //---------------------------------------------------------
    // Reset (convert active-low button to active-high internal)
    //---------------------------------------------------------
    wire rst = ~RESET_N;

    //---------------------------------------------------------
    // Button edge detector -> single-cycle tx_start pulse
    //---------------------------------------------------------
    reg key_prev;
    wire tx_start;

    always @(posedge CLOCK_50) begin
        key_prev <= KEY_SEND;
    end

    assign tx_start = KEY_SEND & ~key_prev;   // rising edge = 1 pulse

    //---------------------------------------------------------
    // Internal signals
    //---------------------------------------------------------
    wire       baud_tick_16x;
    wire       baud_tick_1x;
    wire       tx_busy;
    wire       rx_done;
    wire [7:0] rx_data;

    //---------------------------------------------------------
    // Baud rate generator (16x oversampled tick, used by RX)
    //---------------------------------------------------------
    baud_gen #(
        .CLK_FREQ  (50000000),
        .BAUD_RATE (9600)
    ) baud_inst (
        .clk (CLOCK_50),
        .rst (rst),
        .tick(baud_tick_16x)
    );

    //---------------------------------------------------------
    // Divide 16x tick down to 1x tick (for TX, which shifts
    // out one bit per baud period, not per oversample)
    //---------------------------------------------------------
    reg [3:0] div16;
    reg       tick_1x_reg;

    always @(posedge CLOCK_50 or posedge rst) begin
        if (rst) begin
            div16       <= 4'd0;
            tick_1x_reg <= 1'b0;
        end else if (baud_tick_16x) begin
            if (div16 == 4'd15) begin
                div16       <= 4'd0;
                tick_1x_reg <= 1'b1;
            end else begin
                div16       <= div16 + 1'b1;
                tick_1x_reg <= 1'b0;
            end
        end else begin
            tick_1x_reg <= 1'b0;
        end
    end

    assign baud_tick_1x = tick_1x_reg;

    //---------------------------------------------------------
    // UART Transmitter
    //---------------------------------------------------------
    uart_tx tx_inst (
        .clk      (CLOCK_50),
        .rst      (rst),
        .tick     (baud_tick_1x),
        .tx_start (tx_start),
        .tx_data  (SW),
        .tx       (TX_PIN),
        .tx_busy  (tx_busy)
    );

    //---------------------------------------------------------
    // UART Receiver
    //---------------------------------------------------------
    uart_rx rx_inst (
        .clk     (CLOCK_50),
        .rst     (rst),
        .tick    (baud_tick_16x),
        .rx      (RX_PIN),
        .rx_data (rx_data),
        .rx_done (rx_done)
    );

    //---------------------------------------------------------
    // Latch received byte onto LEDs (avoid combinational glitches)
    //---------------------------------------------------------
    reg [7:0] rx_latched;

    always @(posedge CLOCK_50 or posedge rst) begin
        if (rst)
            rx_latched <= 8'h00;
        else if (rx_done)
            rx_latched <= rx_data;
    end

    assign LED = rx_latched;

endmodule