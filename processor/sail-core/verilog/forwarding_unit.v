/*
 *	Forwarding Unit
 */

module ForwardingUnit (
    input clk,
    input rst,

    input [4:0]  rs1,
    input [4:0]  rs2,
    input [4:0]  MEM_RegWriteAddr,
    input [4:0]  WB_RegWriteAddr,
    input        MEM_RegWrite,
    input        WB_RegWrite,
    input [11:0] EX_CSRR_Addr,
    input [11:0] MEM_CSRR_Addr,
    input [11:0] WB_CSRR_Addr,
    input        MEM_CSRR,
    input        WB_CSRR,

    output reg   MEM_fwd1,
    output reg   MEM_fwd2,
    output reg   WB_fwd1,
    output reg   WB_fwd2
);

    // Combinational forwarding signals (current cycle)
    wire mem_fwd1_cmb;
    wire mem_fwd2_cmb;
    wire wb_fwd1_cmb;
    wire wb_fwd2_cmb;

    assign mem_fwd1_cmb = (MEM_RegWriteAddr != 5'b0 && MEM_RegWriteAddr == rs1) ? MEM_RegWrite : 1'b0;
    assign mem_fwd2_cmb = ((MEM_RegWriteAddr != 5'b0 && MEM_RegWriteAddr == rs2 && MEM_RegWrite == 1'b1) ||
                           (EX_CSRR_Addr == MEM_CSRR_Addr && MEM_CSRR == 1'b1)) ? 1'b1 : 1'b0;

    assign wb_fwd1_cmb = (WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr == rs1 && WB_RegWriteAddr != MEM_RegWriteAddr) ? WB_RegWrite : 1'b0;
    assign wb_fwd2_cmb = ((WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr == rs2 && WB_RegWrite == 1'b1 && WB_RegWriteAddr != MEM_RegWriteAddr) ||
                          (EX_CSRR_Addr == WB_CSRR_Addr && WB_CSRR == 1'b1 && MEM_CSRR_Addr != WB_CSRR_Addr)) ? 1'b1 : 1'b0;

    // Pipeline outputs - register outputs on clock, async reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MEM_fwd1 <= 1'b0;
            MEM_fwd2 <= 1'b0;
            WB_fwd1  <= 1'b0;
            WB_fwd2  <= 1'b0;
        end else begin
            MEM_fwd1 <= mem_fwd1_cmb;
            MEM_fwd2 <= mem_fwd2_cmb;
            WB_fwd1  <= wb_fwd1_cmb;
            WB_fwd2  <= wb_fwd2_cmb;
        end
    end

endmodule

