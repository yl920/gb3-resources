/*
 *		Branch Predictor FSM
 */


module branch_predictor(
    input        clk,
    input        rst,  // Add reset for proper initialization
    input        actual_branch_decision,
    input        branch_decode_sig,
    input        branch_mem_sig,
    input [31:0] in_addr,
    input [31:0] offset,

    output reg [31:0] branch_addr,
    output reg        prediction
);

    reg [1:0] s;  // 2-bit saturating counter state

    // Pipeline registers to delay branch signals by 1 cycle
    reg branch_decode_sig_d1;
    reg branch_mem_sig_d1;

    // Initialize state with reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s <= 2'b00;
            branch_decode_sig_d1 <= 1'b0;
            branch_mem_sig_d1 <= 1'b0;
            branch_addr <= 32'b0;
            prediction <= 1'b0;
        end else begin
            // Pipeline the branch control signals for timing alignment
            branch_decode_sig_d1 <= branch_decode_sig;
            branch_mem_sig_d1 <= branch_mem_sig;

            // Update FSM state on rising edge of delayed branch_mem_sig
            if (branch_mem_sig_d1) begin
                s[1] <= (s[1] & s[0]) | (s[0] & actual_branch_decision) | (s[1] & actual_branch_decision);
                s[0] <= (s[1] & (~s[0])) | ((~s[0]) & actual_branch_decision) | (s[1] & actual_branch_decision);
            end

            // Calculate branch address and prediction using delayed decode signal
            branch_addr <= in_addr + offset;
            prediction <= s[1] & branch_decode_sig_d1;
        end
    end

endmodule

