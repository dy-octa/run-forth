`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:57 12/22/2017 
// Design Name: 
// Module Name:    processor 
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
module processor(
    input Clk,
    input Rst
    );
	 
	wire [15:0] nPC;
	pc pc(
    .Clk(Clk),
	 .Rst(Rst),
	 .nPC(nPC),
	 .PC(PC)
   );
	im im(
		.PC(PC),
		.instr(instr)
	);
	Ctrl Ctrl(
		.instr(instr),
		.B_op(B_op),
		.TWrite(TWrite),
		.NWrite(NWrite),
		.RWrite(RWrite),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.Jump(Jump),
		.JumpZ(JumpZ),
		.AluOp(AluOp),
		.Offset(Offset),
		.AOffset(AOffset),
		.imm(imm),
		.SelectImm(SelectImm),
		.Swap(Swap)
    );
	 
	 stack stack(
		.Clk(Clk),
		.Rst(Rst),
		.TWrite(Twrite),
		.NWrite(NWrite),
		.WData(Result),
		.Offset(Offset),
		.T(T),
		.N(N)
    );
	 stack address(
		.Clk(Clk),
		.Rst(Rst),
		.TWrite(Rwrite),
		.NWrite(0),
		.WData(Result),
		.Offset(AOffset),
		.T(R)
    );
	 dm dm(
		.MemAddr(T),
		.WData(Result),
		.RData(Mem),
		.Clk(Clk),
		.Rst(Rst),
		.MemRead(MemRead),
		.MemWrite(MemWrite)
	);
	 
	alu_in alu_in(
		.B_op(B_op),
		.T(T),
		.PC(PC),
		.N(N),
		.R(R),
		.imm(imm),
		.Mem(Mem),
		.Swap(Swap),
		.SelectImm(SelectImm),
		.A(A),
		.B(B)
	);
	
	alu alu(
		.A(A),
		.B(B),
		.AluOp(AluOp),
		.Res(Result)
	);
	assign nPC = Jump || (JumpZ && T == 0)? Result : PC + 2;
endmodule
