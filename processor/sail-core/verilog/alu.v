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

    // Forwarding logic (combinational)
    wire [31:0] A_fwd_comb = MEM_fwd1_reg ? MEM_result :
                             WB_fwd1_reg  ? WB_result  : A;

    wire [31:0] B_fwd_comb = MEM_fwd2_reg ? MEM_result :
                             WB_fwd2_reg  ? WB_result  : B;

    // Pipeline registers for forwarded operands
    reg [31:0] A_fwd_reg1, B_fwd_reg1;
    reg [31:0] A_fwd_reg2, B_fwd_reg2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_fwd_reg1 <= 32'b0;
            B_fwd_reg1 <= 32'b0;
            A_fwd_reg2 <= 32'b0;
            B_fwd_reg2 <= 32'b0;
        end else begin
            A_fwd_reg1 <= A_fwd_comb;
            B_fwd_reg1 <= B_fwd_comb;
            A_fwd_reg2 <= A_fwd_reg1;
            B_fwd_reg2 <= B_fwd_reg1;
        end
    end

    // Negated B for subtraction (based on pipelined reg)
    wire [31:0] B_neg = ~B_fwd_reg2 + 1;

    // Pipeline registers for ALU inputs and control
    reg [31:0] A_d1, B_d1, B_neg_d1;
    reg [6:0]  ALUctl_d1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_d1 <= 0;
            B_d1 <= 0;
            B_neg_d1 <= 0;
            ALUctl_d1 <= 0;
        end else begin
            A_d1 <= A_fwd_reg2;
            B_d1 <= B_fwd_reg2;
            B_neg_d1 <= B_neg;
            ALUctl_d1 <= ALUctl;
        end
    end

    // Add and Sub units
    wire [31:0] add_result;
    wire [31:0] sub_result;

    adder add_unit(
        .clk(clk),
        .rst(rst),
        .input1(A_d1),
        .input2(B_d1),
        .out(add_result)
    );

    adder sub_unit(
        .clk(clk),
        .rst(rst),
        .input1(A_d1),
        .input2(B_neg_d1),
        .out(sub_result)
    );

    // Output registers for adder/subtractor
    reg [31:0] add_result_d1, sub_result_d1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            add_result_d1 <= 0;
            sub_result_d1 <= 0;
        end else begin
            add_result_d1 <= add_result;
            sub_result_d1 <= sub_result;
        end
    end

    // ALU output logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUOut <= 32'b0;
        end else begin
            case (ALUctl_d1[3:0])
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   ALUOut <= A_d1 & B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    ALUOut <= A_d1 | B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:   ALUOut <= add_result_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   ALUOut <= sub_result_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   ALUOut <= ($signed(A_d1) < $signed(B_d1)) ? 32'b1 : 32'b0;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   ALUOut <= A_d1 >> B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   ALUOut <= $signed(A_d1) >>> B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   ALUOut <= A_d1 << B_d1[4:0];
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   ALUOut <= A_d1 ^ B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW: ALUOut <= A_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS: ALUOut <= A_d1 | B_d1;
                `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC: ALUOut <= (~A_d1) & B_d1;
                default:                                    ALUOut <= 32'b0;
            endcase
        end
    end

    // Branch condition logic (registered compare inputs)
    always @(*) begin
        case (ALUctl[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  Branch_Enable = (A_fwd_reg2 == B_fwd_reg2);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  Branch_Enable = (A_fwd_reg2 != B_fwd_reg2);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  Branch_Enable = ($signed(A_fwd_reg2) < $signed(B_fwd_reg2));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  Branch_Enable = ($signed(A_fwd_reg2) >= $signed(B_fwd_reg2));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable = ($unsigned(A_fwd_reg2) < $unsigned(B_fwd_reg2));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable = ($unsigned(A_fwd_reg2) >= $unsigned(B_fwd_reg2));
            default:                                  Branch_Enable = 1'b0;
        endcase
    end

endmodule

