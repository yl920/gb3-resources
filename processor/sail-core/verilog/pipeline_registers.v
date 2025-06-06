/*
 *	Pipeline registers
 */



/* IF/ID pipeline registers */ 
module if_id (clk, data_in, data_out);
	input			clk;
	input [63:0]		data_in;
	output reg[63:0]	data_out;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		data_out = 64'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* ID/EX pipeline registers */ 
module id_ex (clk, data_in, data_out);
	input			clk;
	input [177:0]		data_in;
	output reg[177:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 178'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* EX/MEM pipeline registers */ 
module ex2_mem (clk, data_in, data_out);
	input			clk;
	input [154:0]		data_in;
	output reg[154:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 155'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* MEM/WB pipeline registers */ 
module mem_wb (clk, data_in, data_out);
	input			clk;
	input [116:0]		data_in;
	output reg[116:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 117'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule
