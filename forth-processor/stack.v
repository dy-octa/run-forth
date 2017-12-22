`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:49:15 12/22/2017 
// Design Name: 
// Module Name:    stack 
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
module stack(
    input Clk,
    input Rst,
    input TWrite,
    input NWrite,
    input [15:0] WData,
    input signed [7:0] Offset,
    output [15:0] T,
    output [15:0] N
    );
	
	reg [15:0] _stack[255:0];
	reg [7:0] top;
	integer i;
	initial begin 
		for (i=0;i<256;i=i+1) begin
				_stack[i]=0;
			end
		top = 0;
	end
	always @(posedge Clk or Rst) begin
		if (Rst) begin
			for (i=0;i<256;i=i+1) begin
				_stack[i]=0;
			end
			top = 0;
		end else begin
			if (TWrite) begin
				$display("T <= %h\n", WData);
				_stack[top + Offset] <= WData;
			end
			if (NWrite) begin	
				$display("N <= %h\n", WData);
				_stack[top + Offset - 1] <= WData;
			end
			top <= top + Offset;
		end
	end
	assign T = top == 0 ? 0 : _stack[top];
	assign N = top <= 1 ? 0 : _stack[top - 1];

endmodule
