`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:28:09 12/22/2017 
// Design Name: 
// Module Name:    processor_tb 
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
module processor_tb(
    );
	reg Clk;
	reg Rst;

	// Instantiate the Unit Under Test (UUT)
	processor uut (
		.Clk(Clk), 
		.Rst(Rst)
	);
	always #10 Clk=~Clk;
	initial begin
		// Initialize Inputs
		Clk = 0;
		Rst = 0;
		// Add stimulus here
	end

endmodule
