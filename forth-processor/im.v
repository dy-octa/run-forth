`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:11:08 12/22/2017 
// Design Name: 
// Module Name:    im 
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
module im(
    input [15:0] PC,
    output [15:0] instr
    );
	reg [15:0] mem [4095:0];
	initial begin
		$readmemh("code.txt", mem, 0, 2047);
		$readmemh("dict.txt", mem, 2048, 4095);
	end
	assign instr = mem[PC[13:1]];

endmodule
