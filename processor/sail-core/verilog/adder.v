/*
 *	Description:
 *
 *		This module implements an adder for use by the branch unit
 *		and program counter increment among other things.
 */


module adder (
    input clk,
    input rst,
    input [31:0] input1,
    input [31:0] input2,
    output reg [31:0] out
);

    reg [31:0] stage1_sum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage1_sum <= 32'b0;
            out <= 32'b0;
        end else begin
            stage1_sum <= input1 + input2;  // First stage
            out <= stage1_sum;              // Second stage
        end
    end
endmodule

