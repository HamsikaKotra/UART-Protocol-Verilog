module uart_tx (
    input clk,
    input rst,
    input tick,           // baud tick (1x, not 16x, for TX)
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);
    reg [3:0] bit_index;
    reg [9:0] shift_reg;   // start + 8 data + stop
    reg [1:0] state;
    localparam IDLE = 0, LOAD = 1, SHIFT = 2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1; tx_busy <= 0; state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= {1'b1, tx_data, 1'b0}; // stop,data,start
                        bit_index <= 0;
                        tx_busy <= 1;
                        state <= SHIFT;
                    end
                end
                SHIFT: begin
                    if (tick) begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        bit_index <= bit_index + 1;
                        if (bit_index == 9) begin
                            tx_busy <= 0;
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end
endmodule