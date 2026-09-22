module baud_gen #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input clk,
    input rst,
    output reg tick
);
    localparam DIVISOR = CLK_FREQ / (BAUD_RATE * 16); // 16x oversampling
    reg [15:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else if (count == DIVISOR - 1) begin
            count <= 0;
            tick  <= 1;
        end else begin
            count <= count + 1;
            tick  <= 0;
        end
    end
endmodule