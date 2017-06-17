
`timescale 1ns/1ns

module execute(
	input 			CLK,
	input			Reset,
	input  [3:0]	D0ALUControl, D1ALUControl,
	input  [31:0]	D0SrcA, D0SrcB, D1SrcA, D1SrcB, D2SrcA, D2SrcB, D3SrcA, D3SrcB,
	input  [31:0]	D0Dest, D1Dest, D2Dest, D3Data,
	input			D0RegWrite, D1RegWrite, D2RegWrite, D3MemWrite,
	input  [31:0]	ALURTag0A, ALURTag0B, ALURTag1A, ALURTag1B, ALURTag2A, ALURTag2B, ALURTag3A, ALURTag3B,
	output [31:0]	ALUOut0, ALUOut1, A2, A3,
	output [31:0]	Dest0, Dest1, Dest2, Data3,
	output			RegWrite0, RegWrite1, RegWrite2, MemWrite3,
	output [31:0]	ALURData0A, ALURData0B, ALURData1A, ALURData1B, ALURData2A, ALURData2B, ALURData3A, ALURData3B,
	output			ALURFlag0A, ALURFlag0B, ALURFlag1A, ALURFlag1B, ALURFlag2A, ALURFlag2B, ALURFlag3A, ALURFlag3B);

/****************************************************************************************/
/* 	ALU0, ALU1, AG2, AG3																*/
/****************************************************************************************/
	alu alu0(
		.SrcA(D0SrcA),
		.SrcB(D0SrcB),
		.ALUControl(D0ALUControl),
		.ALUOut(ALUOut0));
	alu alu1(
		.SrcA(D1SrcA),
		.SrcB(D1SrcB),
		.ALUControl(D1ALUControl),
		.ALUOut(ALUOut1));
	assign A2 = D2SrcA + D2SrcB;	
	assign A3 = D3SrcA + D3SrcB;
	
/****************************************************************************************/
/* 	Output Assignment																	*/
/****************************************************************************************/
	assign Dest0 = D0Dest;
	assign Dest1 = D1Dest;
	assign Dest2 = D2Dest;
	assign Data3 = D3Data;
	assign RegWrite0 = D0RegWrite;
	assign RegWrite1 = D1RegWrite;
	assign RegWrite2 = D2RegWrite;
	assign MemWrite3 = D3MemWrite;

	assign ALURFlag0A = ~((ALURTag0A==Dest0 && RegWrite0==1'b1) || (ALURTag0A==Dest1 && RegWrite1==1'b1));
	assign ALURFlag0B = ~((ALURTag0B==Dest0 && RegWrite0==1'b1) || (ALURTag0B==Dest1 && RegWrite1==1'b1));
	assign ALURFlag1A = ~((ALURTag1A==Dest0 && RegWrite0==1'b1) || (ALURTag1A==Dest1 && RegWrite1==1'b1));
	assign ALURFlag1B = ~((ALURTag1B==Dest0 && RegWrite0==1'b1) || (ALURTag1B==Dest1 && RegWrite1==1'b1));
	assign ALURFlag2A = ~((ALURTag2A==Dest0 && RegWrite0==1'b1) || (ALURTag2A==Dest1 && RegWrite1==1'b1));
	assign ALURFlag2B = ~((ALURTag2B==Dest0 && RegWrite0==1'b1) || (ALURTag2B==Dest1 && RegWrite1==1'b1));
	assign ALURFlag3A = ~((ALURTag3A==Dest0 && RegWrite0==1'b1) || (ALURTag3A==Dest1 && RegWrite1==1'b1));
	assign ALURFlag3B = ~((ALURTag3B==Dest0 && RegWrite0==1'b1) || (ALURTag3B==Dest1 && RegWrite1==1'b1));
	
	assign ALURData0A = (ALURTag0A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag0A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData0B = (ALURTag0B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag0B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData1A = (ALURTag1A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag1A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData1B = (ALURTag1B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag1B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData2A = (ALURTag2A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag2A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData2B = (ALURTag2B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag2B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData3A = (ALURTag3A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag3A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	assign ALURData3B = (ALURTag3B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ALURTag3B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : 32'd0;
	
endmodule
