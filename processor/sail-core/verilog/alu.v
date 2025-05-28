/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/


`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module alu(
    input clk,
    input rst,
    input [6:0] ALUctl,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] ALUOut,
    output reg Branch_Enable
);
    wire [31:0] B_neg = ~B + 1;
    wire [31:0] sub_result;
    wire [31:0] add_result;

    // ADD result via pipelined adder
    adder add_unit(
        .clk(clk),
        .rst(rst),
        .input1(A),
        .input2(B),
        .out(add_result)
    );

    // SUB result using combinational adder
    adder sub_unit(
        .clk(clk),
        .rst(rst),
        .input1(A),
        .input2(B_neg),
        .out(sub_result)
    );

    // Handle non-ADD instructions combinationally
    reg [31:0] ALUOut_comb;

    always @(*) begin
        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   ALUOut_comb = A & B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    ALUOut_comb = A | B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   ALUOut_comb = sub_result;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   ALUOut_comb = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   ALUOut_comb = A >> B[4:0];
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   ALUOut_comb = $signed(A) >>> B[4:0];
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   ALUOut_comb = A << B[4:0];
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   ALUOut_comb = A ^ B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut_comb = A;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut_comb = A | B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC: ALUOut_comb = (~A) & B;
            default:                                    ALUOut_comb = 32'b0;
        endcase
    end

    // Register ALUOut
    always @(posedge clk or posedge rst) begin
        if (rst)
            ALUOut <= 32'b0;
        else begin
            if (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD)
                ALUOut <= add_result;
            else
                ALUOut <= ALUOut_comb;
        end
    end

    // Branch logic (combinational, using registered ALUOut)
    always @(*) begin
        case (ALUctl[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  Branch_Enable = (ALUOut == 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  Branch_Enable = (ALUOut != 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  Branch_Enable = ($signed(A) < $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  Branch_Enable = ($signed(A) >= $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable = ($unsigned(A) < $unsigned(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable = ($unsigned(A) >= $unsigned(B));
            default:                                  Branch_Enable = 1'b0;
        endcase
    end
endmodule

