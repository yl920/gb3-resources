`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module alu(
    input clk,
    input rst,
    input [6:0] ALUctl,
    input [31:0] A,
    input [31:0] B,
    input [31:0] MEM_result,
    input [31:0] WB_result,
    input MEM_fwd1_reg, MEM_fwd2_reg,
    input WB_fwd1_reg, WB_fwd2_reg,
    output reg [31:0] ALUOut,
    output reg Branch_Enable
);
    // Forwarded operands
    wire [31:0] A_fwd = MEM_fwd1_reg ? MEM_result :
                        WB_fwd1_reg  ? WB_result  : A;

    wire [31:0] B_fwd = MEM_fwd2_reg ? MEM_result :
                        WB_fwd2_reg  ? WB_result  : B;

    wire [31:0] B_neg = ~B_fwd + 1;

    // Pipelined intermediate values
    reg [31:0] A_d1, A_d2;
    reg [31:0] B_d1, B_d2;
    reg [31:0] B_neg_d1, B_neg_d2;
    reg [6:0]  ALUctl_d1, ALUctl_d2;

    wire [31:0] add_result;
    wire [31:0] sub_result;

    adder add_unit(
        .clk(clk),
        .rst(rst),
        .input1(A_fwd),
        .input2(B_fwd),
        .out(add_result)
    );

    adder sub_unit(
        .clk(clk),
        .rst(rst),
        .input1(A_d1),
        .input2(B_neg_d1),
        .out(sub_result)
    );

    // Register pipeline stages
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_d1 <= 0; A_d2 <= 0;
            B_d1 <= 0; B_d2 <= 0;
            B_neg_d1 <= 0; B_neg_d2 <= 0;
            ALUctl_d1 <= 0; ALUctl_d2 <= 0;
        end else begin
            A_d1 <= A_fwd;  A_d2 <= A_d1;
            B_d1 <= B_fwd;  B_d2 <= B_d1;
            B_neg_d1 <= B_neg; B_neg_d2 <= B_neg_d1;
            ALUctl_d1 <= ALUctl; ALUctl_d2 <= ALUctl_d1;
        end
    end

    // Main ALU logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUOut <= 32'b0;
        end else begin
            case (ALUctl_d2[3:0])
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   ALUOut <= A_d2 & B_d2;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    ALUOut <= A_d2 | B_d2;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:   ALUOut <= add_result;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   ALUOut <= sub_result;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   ALUOut <= ($signed(A_d2) < $signed(B_d2)) ? 32'b1 : 32'b0;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   ALUOut <= A_d2 >> B_d2[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   ALUOut <= $signed(A_d2) >>> B_d2[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   ALUOut <= A_d2 << B_d2[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   ALUOut <= A_d2 ^ B_d2;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut <= A_d2;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut <= A_d2 | B_d2;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC: ALUOut <= (~A_d2) & B_d2;
                default:                                    ALUOut <= 32'b0;
            endcase
        end
    end

    // Branch condition logic (combinational — use forwarded A and B to avoid delay)
    always @(*) begin
        case (ALUctl[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  Branch_Enable = (A_fwd == B_fwd);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  Branch_Enable = (A_fwd != B_fwd);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  Branch_Enable = ($signed(A_fwd) < $signed(B_fwd));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  Branch_Enable = ($signed(A_fwd) >= $signed(B_fwd));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable = ($unsigned(A_fwd) < $unsigned(B_fwd));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable = ($unsigned(A_fwd) >= $unsigned(B_fwd));
            default:                                  Branch_Enable = 1'b0;
        endcase
    end

endmodule

