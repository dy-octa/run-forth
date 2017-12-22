`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:16:14 12/22/2017 
// Design Name: 
// Module Name:    pc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pc(
    input Clk,
    input Rst,
	 input [31:0] nPC,
    output reg [31:0] PC
    );
	initial PC <= 0; 
	always @(posedge Clk) begin
		if (Rst)
			PC <= 0;
		else PC <= nPC;
	end

endmodule
