`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:28 12/22/2017 
// Design Name: 
// Module Name:    dm 
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
module dm(
    input [15:0] MemAddr,
    input [15:0] WData,
    output [15:0] RData,
    input Clk,
    input Rst,
    input MemRead,
    input MemWrite
    );
	reg [15:0] mem[1023:0];
	integer i;
	initial begin 
		for (i=0;i<1024;i=i+1) begin
				mem[i]=0;
			end
	end
	always @(posedge Clk) begin
		if (Rst) begin
			for (i=0;i<1024;i=i+1) begin
				mem[i]<=0;
			end
		end else
			if (MemWrite) begin
					$display("*%h <= %h\n", MemAddr, WData);
					mem[MemAddr[10:1]]<=WData;
				end
	end
	assign RData = MemRead ? mem[MemAddr[10:1]] : {16{1'bx}};

endmodule
