module top();
	reg clk = 0;
	reg rst = 0;

	reg[31:0] input1;
	reg[31:0] input2;
	wire[31:0] data_out;
	
	//Instantiate the adder
	adder adder_inst(
		.clk(clk),
		.rst(rst),
		.input1(input1),
		.input2(input2),
		.out(data_out)
	);

//simulation
always
 #0.5 clk = ~clk;

initial begin
	$dumpfile ("adder_sim.vcd");
 	$dumpvars ;
	
	// Reset the circuit
        rst = 1;
        input1 = 0;
        input2 = 0;
        #2; // hold reset for a couple of clock cycles

        rst = 0;

        // Apply inputs and observe pipelined result
        input1 = 32'd0;
        input2 = 32'd10;
        #2;

        input1 = 32'd1000;
        input2 = 32'd10;
        #2;

        input1 = 32'd12345;
        input2 = 32'd54321;
        #2;

 	$finish;
end

endmodule
