module alu_sim();
	reg clk = 0;
	reg rst = 0;

	reg[31:0] A, B;
	wire[31:0] ALUOut;
	wire Branch_Enable;

	//alu_control interface
	reg[3:0] FuncCode;
	reg[6:0] Opcode;

	//alu aluctl interface
	wire[6:0] AluCtl_wire;

	// Dummy forwarding-related signals
    	reg [31:0] MEM_result = 0;
    	reg [31:0] WB_result = 0;
    	reg MEM_fwd1_reg = 0, MEM_fwd2_reg = 0;
    	reg WB_fwd1_reg = 0, WB_fwd2_reg = 0;

	//ALU control decoder
	ALUControl aluCtrl_inst(
		.FuncCode(FuncCode),
		.ALUCtl(AluCtl_wire),
		.Opcode(Opcode)
	);

	//ALU instantiation
	alu alu_inst(
		.clk(clk),
		.rst(rst),
		.ALUctl(AluCtl_wire),
		.A(A),
		.B(B),
		.MEM_result(MEM_result),
      	  	.WB_result(WB_result),
        	.MEM_fwd1_reg(MEM_fwd1_reg),
        	.MEM_fwd2_reg(MEM_fwd2_reg),
        	.WB_fwd1_reg(WB_fwd1_reg),
        	.WB_fwd2_reg(WB_fwd2_reg),
		.ALUOut(ALUOut),
		.Branch_Enable(Branch_Enable)
	);

//simulation
always
 #0.5 clk = ~clk;

initial begin
	$dumpfile ("alu_sim.vcd");
 	$dumpvars;

 	//reg[31:0] A, B;
 	//reg[3:0] FuncCode; //bit 32 + bit 14:12
	//reg[6:0] Opcode; //bits 6:0

	        // Apply reset
        rst = 1;
        A = 0; B = 0; FuncCode = 0; Opcode = 0;
        #2;
        rst = 0;

        // AND
        A = 32'b00001111;
        B = 32'b01010101;
        FuncCode = 4'b0111;
        Opcode = 7'b0110011;
        #4;

        // OR
        FuncCode = 4'b0110;
        #4;

        // ADD
        A = 32'd10000;
        B = 32'd7;
        FuncCode = 4'b0000;
        #4;

        // SUB
        FuncCode = 4'b1000;
        #4;

        // SLT
        A = 32'b0;
        B = 32'b10;
        FuncCode = 4'b0010;
        #4;

        // SRL
        A = 32'b10000;
        B = 32'b10;
        FuncCode = 4'b0101;
        #4;

        // SRA
        A = 32'b1000;
        B = 32'b1;
        FuncCode = 4'b1101;
        #4;

        // SLL
        A = 32'b10;
        B = 32'b10;
        FuncCode = 4'b0001;
        #4;

        // XOR
        A = 32'b01010101;
        B = 32'b11111111;
        FuncCode = 4'b0100;
        #4;

 	$finish;
end

endmodule

