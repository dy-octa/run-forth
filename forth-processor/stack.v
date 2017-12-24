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
    input signed [1:0] Offset,
    output reg [15:0] T,
    output reg [15:0] N
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
	wire signed [7:0] Delta = Offset == 2'b11 ? -1 : Offset;
	always @(posedge Clk or Rst) begin
		if (Rst) begin
			for (i=0;i<256;i=i+1) begin
				_stack[i]=0;
			end
			top = 0;
		end else begin
			//if (Delta == 1)
			//	$display("%m: push");
			//else if (Delta == -1)
			//	$display("%m: pop");
			if (TWrite)
				if (top + Delta - 1 >= 0 && top + Delta - 1 < 256) begin
					_stack[top + Delta - 1] <= WData;	
					$display("%m: T[%d] <= %h\n", top + Delta - 1, WData);
				end
			if (NWrite)
				if (top + Delta - 2 >= 0 && top + Delta - 2 < 256) begin	
					_stack[top + Delta - 2] <= WData;
					$display("%m: N[%d] <= %h\n", top + Delta - 1, WData); 
				end
			if (Delta >= -1 && Delta <= 1) begin
				$display("%m: top %d -> %d\n", top, top + Delta);
				top <= top + Delta;
			end
			$display("%m: ");
			for (i=0; i<top; i=i+1)
				$display("%h ", _stack[i]);
			$display("\n");
		end
	end
	always @(*) begin
		T = top == 0 ? 0 : _stack[top - 1];
		N = top <= 1 ? 0 : _stack[top - 2];
	end
endmodule
