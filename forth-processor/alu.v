`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:58:45 12/22/2017 
// Design Name: 
// Module Name:    alu 
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
module alu(
    input signed [15:0] A,
    input signed [15:0] B,
    input [3:0] AluOp,
    output reg [15:0] Res
    );
	always@(*) begin
		case (AluOp)
			1: Res = A + B;
			2: Res = A - B;
			3: Res = A * B;
			4: Res = A / B;
			5: Res = A % B;
			6: Res = A & B;
			7: Res = A | B;
			8: Res = A ^ B;
			9: Res = ~B;
			10: Res = B;
			11: Res = A << B;
			12: Res = A >> B;
			13: Res = A < B;
			14: Res = A >= B;
			15: Res = A == B;
			default: Res = {16{1'bx}};
		endcase
	end

endmodule
