`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:21:36 12/22/2017 
// Design Name: 
// Module Name:    alu_in 
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
module alu_in(
    input [1:0] B_op,
	 input [15:0] T,
    input [15:0] PC,
    input [15:0] N,
    input [15:0] R,
	 input [15:0] imm,
    input [15:0] Mem,
    input Swap,
	 input SelectImm,
    output reg [15:0] A,
    output reg [15:0] B
    );
	always@(*) begin
		if (SelectImm) begin
			if (Swap) begin
				A = imm;
				B = T;
			end else begin
				A = T;
				B = imm;
			end
		end
		else
			case (B_op)
				0: if (Swap) begin
						A = PC;
						B = T;
					end else begin
						A = T;
						B = PC;
					end
				1: if (Swap) begin
						A = N;
						B = T;
					end else begin
						A = T;
						B = N;
					end
				2: if (Swap) begin
						A = R;
						B = T;
					end else begin
						A = T;
						B = R;
					end
				3: if (Swap) begin
						A = Mem;
						B = T;
					end else begin
						A = T;
						B = Mem;
					end
				default: begin
					A = {16{1'bx}};
					B = {16{1'bx}};
				end
			endcase
	end
endmodule
