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
    // Delayed signals to match 1-cycle delay of pipelined adder
    reg [6:0] ALUctl_d1;
    reg [31:0] A_d1, B_d1;

    wire [31:0] add_result;
    adder add_unit(.clk(clk), .rst(rst), .input1(A), .input2(B), .out(add_result));

    // Delay ALU control and inputs for 1 cycle
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUctl_d1 <= 7'b0;
            A_d1 <= 32'b0;
            B_d1 <= 32'b0;
        end else begin
            ALUctl_d1 <= ALUctl;
            A_d1 <= A;
            B_d1 <= B;
        end
    end

    // Compute ALU result on next cycle, synchronized with adder output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUOut <= 32'b0;
        end else begin
            case (ALUctl_d1[3:0])
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:  ALUOut <= A_d1 & B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:   ALUOut <= A_d1 | B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:  ALUOut <= add_result;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:  ALUOut <= A_d1 - B_d1; // Optional: use adder with ~B+1 for SUB
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:  ALUOut <= ($signed(A_d1) < $signed(B_d1)) ? 32'b1 : 32'b0;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:  ALUOut <= A_d1 >> B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:  ALUOut <= $signed(A_d1) >>> B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:  ALUOut <= A_d1 << B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:  ALUOut <= A_d1 ^ B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:ALUOut <= A_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:ALUOut <= A_d1 | B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:ALUOut <= (~A_d1) & B_d1;
                default:                                  ALUOut <= 32'b0;
            endcase
        end
    end

    // Branch decision also needs to be pipelined to match A_d1, B_d1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Branch_Enable <= 1'b0;
        end else begin
            case (ALUctl_d1[6:4])
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  Branch_Enable <= (ALUOut == 0);
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  Branch_Enable <= !(ALUOut == 0);
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  Branch_Enable <= ($signed(A_d1) < $signed(B_d1));
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  Branch_Enable <= ($signed(A_d1) >= $signed(B_d1));
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable <= ($unsigned(A_d1) < $unsigned(B_d1));
                `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable <= ($unsigned(A_d1) >= $unsigned(B_d1));
                default:                                  Branch_Enable <= 1'b0;
            endcase
        end
    end
endmodule

