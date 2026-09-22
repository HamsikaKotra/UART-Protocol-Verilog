module uart_rx (
    input clk,
    input rst,
    input tick,          // 16x oversampled tick
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);
    reg [3:0] sample_count;
    reg [3:0] bit_index;
    reg [7:0] shift_reg;
    reg [1:0] state;
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; rx_done <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: if (!rx) begin state <= START; sample_count <= 0; end
                START: if (tick) begin
                    if (sample_count == 7) begin state <= DATA; sample_count <= 0; bit_index <= 0; end
                    else sample_count <= sample_count + 1;
                end
                DATA: if (tick) begin
                    if (sample_count == 15) begin
                        shift_reg[bit_index] <= rx;
                        sample_count <= 0;
                        if (bit_index == 7) state <= STOP;
                        else bit_index <= bit_index + 1;
                    end else sample_count <= sample_count + 1;
                end
                STOP: if (tick) begin
                    if (sample_count == 15) begin
                        rx_data <= shift_reg;
                        rx_done <= 1;
                        state <= IDLE;
                    end else sample_count <= sample_count + 1;
                end
            endcase
        end
    end
endmodule