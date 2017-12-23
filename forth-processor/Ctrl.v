`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:33:48 12/22/2017 
// Design Name: 
// Module Name:    Ctrl 
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
module Ctrl(
	input [15:0] instr,
	output reg [1:0] B_op,
	output reg TWrite,
	output reg NWrite,
	output reg RWrite,
	output reg MemRead,
	output reg MemWrite,
	output reg Jump,
	output reg JumpZ,
	output reg JumpReg,
	output reg [3:0] AluOp,
	output reg signed [1:0] Offset,
	output reg signed [1:0] AOffset,
	output reg [15:0] imm,
	output reg SelectImm,
	output reg Swap
    );
	always @(*) begin
		B_op = 0; TWrite = 0; NWrite = 0; RWrite = 0; MemRead = 0;
		MemWrite = 0; Jump = 0; JumpZ = 0; AluOp = 0; Offset = 0; AOffset = 0;
		imm = 0; SelectImm = 0; Swap = 0; JumpReg = 0;
		if (instr[15] == 1) begin // imm
			imm = instr[14:0];
			SelectImm = 1;
			TWrite = 1; AluOp = 10; Offset = 1;
		end else if (instr[15:9] == 0) begin // jr
			B_op = 2; // R
			JumpReg = 1; AOffset = -1;
			AluOp = 10; // movb
		end else if (instr[15:13] == 'b001) begin // j
			imm = instr[12:0];
			Jump = 1;
		end else if (instr[15:13] == 'b010) begin // jal
			imm = instr[12:0]; Jump = 1;
			B_op = 0; // PC
			AOffset = 1; AluOp = 10; RWrite = 1;
		end else if (instr[15:13] == 'b011) begin // jz
			imm = instr[12:0]; JumpZ = 1;
			AluOp = 10; Swap = 1; // Result: T
		end else begin // ALU instructions
			if (instr[8:7] == 3)
				MemRead = 1;
			case (instr[6:5])
				0: TWrite = 1;
				1: NWrite = 1;
				2: RWrite = 1;
				3: MemWrite = 1;
				default: ;
			endcase
			Offset = instr[4:3];
			AOffset = instr[2:1];
			Swap = instr[0];
		end
	end
endmodule
