`timescale 1ns/1ps

module uart_tb;

    //---------------------------------------------------------
    // Testbench signals
    //---------------------------------------------------------
    reg        clk;
    reg        rst;
    reg        tx_start;
    reg  [7:0] tx_data;

    wire       baud_tick_16x;
    wire       baud_tick_1x;
    wire       tx_line;        // TX output, looped into RX
    wire       tx_busy;
    wire       rx_done;
    wire [7:0] rx_data;

    //---------------------------------------------------------
    // Clock generation: 50 MHz -> 20 ns period -> 10 ns half-period
    //---------------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk;

    //---------------------------------------------------------
    // Baud generator (same as in uart_top)
    //---------------------------------------------------------
    baud_gen #(
        .CLK_FREQ  (50000000),
        .BAUD_RATE (9600)
    ) baud_inst (
        .clk (clk),
        .rst (rst),
        .tick(baud_tick_16x)
    );

    // Divide 16x tick down to 1x tick for TX
    reg [3:0] div16;
    reg       tick_1x_reg;

    always @(posedge clk or posedge rst) begin
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
    // DUT: Transmitter
    //---------------------------------------------------------
    uart_tx tx_inst (
        .clk      (clk),
        .rst      (rst),
        .tick     (baud_tick_1x),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx_line),
        .tx_busy  (tx_busy)
    );

    //---------------------------------------------------------
    // DUT: Receiver (loopback: tx_line feeds directly into rx)
    //---------------------------------------------------------
    uart_rx rx_inst (
        .clk     (clk),
        .rst     (rst),
        .tick    (baud_tick_16x),
        .rx      (tx_line),      // <-- loopback connection
        .rx_data (rx_data),
        .rx_done (rx_done)
    );

    //---------------------------------------------------------
    // Stimulus
    //---------------------------------------------------------
    initial begin
        // Initialize
        rst      = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        // Hold reset for a bit
        #100;
        rst = 0;

        // Wait a little, then send first byte: 'A' = 0x41
        #100;
        tx_data  = 8'h41;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait long enough for one full UART frame at 9600 baud
        // 1 frame = 10 bits x (1/9600 s) ~= 1.0417 ms = 1,041,700 ns
        #1200000;

        // Send a second byte to confirm back-to-back sends work: 'Z' = 0x5A
        tx_data  = 8'h5A;
        tx_start = 1;
        #20;
        tx_start = 0;

        #1200000;

        // Finish simulation
        $display("Simulation complete.");
        $stop;
    end

    //---------------------------------------------------------
    // Monitor: print to console whenever RX successfully
    // decodes a byte, so you can confirm it matches tx_data
    //---------------------------------------------------------
    always @(posedge clk) begin
        if (rx_done) begin
            $display("Time=%0t : RX received byte = 0x%02h ('%c')",
                       $time, rx_data, rx_data);
        end
    end

endmodule