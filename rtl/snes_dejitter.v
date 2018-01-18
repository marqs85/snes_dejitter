// MIT License
// 
// Copyright (c) 2017-2018 Markus Hiienkari
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

`define EDGE_SENSITIVE_CLKEN

module snes_dejitter(
    input MCLK_XTAL_i, //21.477272MHz master clock via oscillator
    input MCLK_EXT_i,  //ext. master clock
    input MCLK_SEL_i,
    input CSYNC_i,
    output MCLK_XTAL_o,
    output GCLK_o,
    output reg CSYNC_o
);

wire CLK_i = MCLK_SEL_i ? MCLK_EXT_i : MCLK_XTAL_o;

assign GCLK_o = CLK_i & gclk_en;

assign MCLK_XTAL_o = ~MCLK_XTAL_i;

reg [10:0] h_cnt;
reg [2:0] g_cyc;
reg CSYNC_prev;
reg gclk_en;


always @(posedge CLK_i) begin
    if ((h_cnt >= 1024) && (CSYNC_prev==1'b1) && (CSYNC_i==1'b0)) begin
        h_cnt <= 0;
        if (h_cnt == 340*4-1)
            g_cyc <= 4;
        else
            CSYNC_o <= CSYNC_i;
    end else begin
        h_cnt <= h_cnt + 1'b1;
        if (g_cyc > 0)
            g_cyc <= g_cyc - 1'b1;
        if (g_cyc <= 1)
            CSYNC_o <= CSYNC_i;
    end

    CSYNC_prev <= CSYNC_i;
end

`ifdef EDGE_SENSITIVE_CLKEN
//Update clock gate enable signal on negative edge
always @(negedge CLK_i) begin
    gclk_en <= (g_cyc == 0);
end
`else
//ATF1502AS macrocells support D latch mode,
//enabling level sensitive update of gclk_en during negative phase
always @(*) begin
    if (!CLK_i)
        gclk_en <= (g_cyc == 0);
end
`endif

endmodule
