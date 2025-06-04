
/*
 *		Branch Predictor FSM
 */

module branch_predictor(
    input clk,
    input actual_branch_decision,
    input branch_decode_sig,
    input branch_mem_sig,
    input [31:0] in_addr,
    input [31:0] offset,
    output [31:0] branch_addr,
    output prediction
);

    // FSM state
    reg [1:0] s;
    reg branch_mem_sig_reg;

    // Pipeline register for branch_addr
    reg [31:0] branch_addr_reg;

    initial begin
        s = 2'b00;
        branch_mem_sig_reg = 1'b0;
        branch_addr_reg = 32'b0;
    end

    // Delay MEM signal by one cycle
    always @(negedge clk) begin
        branch_mem_sig_reg <= branch_mem_sig;
    end

    // Update FSM state on branch commit
    always @(posedge clk) begin
        if (branch_mem_sig_reg) begin
            s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
            s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
        end
    end

    // Pipeline branch address to cut logic depth
    always @(posedge clk) begin
        branch_addr_reg <= in_addr + offset;
    end

    assign branch_addr = branch_addr_reg;
    assign prediction = s[1] & branch_decode_sig;

endmodule

