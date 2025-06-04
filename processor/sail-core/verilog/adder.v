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



/*
 *	Description:
 *
 *		This module implements an adder for use by the branch unit
 *		and program counter increment among other things.
 */



module adder(input1, input2, is_sub, out);
    input  [31:0] input1;
    input  [31:0] input2;
    input         is_sub;
    output [31:0] out;

    wire [31:0] result;
    wire        carry_out;

    SB_MAC16 i_sbmac16 (
        .A(input1[31:16]),  
        .B(input1[15:0]),  
        .C(input2[31:16]), 
        .D(input2[15:0]),  
        .O(result),
        .CLK(1'b0),
        .CE(1'b1),
        .IRSTTOP(1'b0), 
        .IRSTBOT(1'b0),
        .ORSTTOP(1'b0), 
        .ORSTBOT(1'b0),
        .AHOLD(1'b0), 
        .BHOLD(1'b0),
        .CHOLD(1'b0), 
        .DHOLD(1'b0),
        .OHOLDTOP(1'b0),
        .OHOLDBOT(1'b0),
        .OLOADTOP(1'b0), 
        .OLOADBOT(1'b0),
        .ADDSUBTOP(is_sub), 
        .ADDSUBBOT(is_sub),
        .CO(carry_out),
        .CI(1'b0), 
        .ACCUMCI(1'b0),
        .ACCUMCO(), 
        .SIGNEXTIN(1'b0), 
        .SIGNEXTOUT()
    );

    // ---- DSP Configuration using defparam ----
    defparam i_sbmac16.TOPADDSUB_LOWERINPUT         = 2'b00;  // A
    defparam i_sbmac16.TOPADDSUB_UPPERINPUT         = 1'b1;   // C
    defparam i_sbmac16.TOPADDSUB_CARRYSELECT        = 2'b11;  // Carry from BOT
    defparam i_sbmac16.BOTOUTPUT_SELECT             = 2'b00;  // Bot adder output
    defparam i_sbmac16.BOTADDSUB_LOWERINPUT         = 2'b00;  // B
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT         = 1'b1;   // D
    defparam i_sbmac16.BOTADDSUB_CARRYSELECT        = 2'b00;  // No carry-in
    defparam i_sbmac16.MODE_8x8                     = 1'b0;
    defparam i_sbmac16.A_SIGNED                     = 1'b0;
    defparam i_sbmac16.B_SIGNED                     = 1'b0;

    assign out = result;
endmodule
