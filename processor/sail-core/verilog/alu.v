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



/*
 *	Description:
 *
 *		This module implements the ALU for the RV32I.
 */



/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */

module alu (
    input  [6:0]  ALUctl,
    input  [31:0] A,
    input  [31:0] B,
    output reg [31:0] ALUOut,
    output reg       Branch_Enable
);

     wire is_sub       = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB) |
                        (ALUctl[6:4] != 3'b000); // any branch
    wire [31:0] b_eff = is_sub ? ~B : B;

    (* use_dsp = "yes" *)
    wire [32:0] sum   = {1'b0, A} + {1'b0, b_eff} + is_sub;

    wire [31:0] add_sub_result = sum[31:0];
    wire        add_zero       = (add_sub_result == 32'd0);

        wire do_shift = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL) |
                    (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL) |
                    (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA);

    wire [4:0] shamt = do_shift ? B[4:0] : 5'd0;

    wire [31:0] shift_left  = A <<  shamt;
    wire [31:0] shift_right = A >>  shamt;
    wire [31:0] shift_arith = $signed(A) >>> shamt;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
     
    always @* begin
        ALUOut = 32'b0;
        Branch_Enable = 1'b0;

        case (ALUctl[3:0])
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   ALUOut = A & B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    ALUOut = A | B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   ALUOut = A ^ B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   ALUOut = shift_left;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   ALUOut = shift_right;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   ALUOut = shift_arith;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut = A;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut = A | B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC: ALUOut = (~A) & B;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD,
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   ALUOut = add_sub_result;
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   ALUOut = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            default:                                    ALUOut = 32'b0;
        endcase

        case (ALUctl[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:   Branch_Enable =  add_zero;
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:   Branch_Enable = !add_zero;
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:   Branch_Enable = ($signed(A) <  $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:   Branch_Enable = ($signed(A) >= $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:  Branch_Enable = ($unsigned(A) <  $unsigned(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:  Branch_Enable = ($unsigned(A) >= $unsigned(B));
            default:                                    Branch_Enable = 1'b0;
        endcase
    end

endmodule
