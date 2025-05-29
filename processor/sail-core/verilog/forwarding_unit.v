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
 *	Forwarding Unit
 */

`default_nettype none

module ForwardingUnit (
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  MEM_RegWriteAddr,
    input  wire [4:0]  WB_RegWriteAddr,
    input  wire        MEM_RegWrite,
    input  wire        WB_RegWrite,
    input  wire [11:0] EX_CSRR_Addr,
    input  wire [11:0] MEM_CSRR_Addr,
    input  wire [11:0] WB_CSRR_Addr,
    input  wire        MEM_CSRR,
    input  wire        WB_CSRR,
    output wire        MEM_fwd1,
    output wire        MEM_fwd2,
    output wire        WB_fwd1,
    output wire        WB_fwd2
);

        wire rs1_eq_MEM = ~|(rs1 ^ MEM_RegWriteAddr);
    wire rs2_eq_MEM = ~|(rs2 ^ MEM_RegWriteAddr);

    wire rs1_eq_WB  = ~|(rs1 ^ WB_RegWriteAddr);
    wire rs2_eq_WB  = ~|(rs2 ^ WB_RegWriteAddr);

    wire csr_EX_eq_MEM = ~|(EX_CSRR_Addr ^ MEM_CSRR_Addr);
    wire csr_EX_eq_WB  = ~|(EX_CSRR_Addr ^ WB_CSRR_Addr);
 
     assign MEM_fwd1 = MEM_RegWrite & rs1_eq_MEM & |MEM_RegWriteAddr;

    assign MEM_fwd2 = (MEM_RegWrite & rs2_eq_MEM & |MEM_RegWriteAddr) |
                      (MEM_CSRR     & csr_EX_eq_MEM);

    assign WB_fwd1  = WB_RegWrite  & rs1_eq_WB  & |WB_RegWriteAddr & ~rs1_eq_MEM;

    assign WB_fwd2  = (WB_RegWrite  & rs2_eq_WB  & |WB_RegWriteAddr & ~rs2_eq_MEM) |
                      (WB_CSRR      & csr_EX_eq_WB & ~csr_EX_eq_MEM);

endmodule
