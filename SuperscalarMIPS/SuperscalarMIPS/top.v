module top(
	input CLK,
	input Reset);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	wire [31:0]		InstructionMem_RD0, InstructionMem_RD1, InstructionMem_RD2, InstructionMem_RD3;
	wire [31:0]		InstructionMem_JumpRD0, InstructionMem_JumpRD1, InstructionMem_JumpRD2, InstructionMem_JumpRD3;
	
	wire [31:0]		InstructionMem_A, InstructionMem_JumpA, DataMem_WA, DataMem_RA;
	wire [31:0]		DataMem_WD;
	wire			DataMem_WE;
	wire [31:0]		CacheRA;
	wire [31:0]		DataMem_RD;
	wire [31:0]		CacheRD0, CacheRD1, CacheRD2, CacheRD3, CacheRD4, CacheRD5, CacheRD6, CacheRD7, CacheRD8, CacheRD9, CacheRD10, CacheRD11, CacheRD12, CacheRD13, CacheRD14, CacheRD15;

/****************************************************************************************/
/* 	Instruction Memory																	*/
/****************************************************************************************/
	instruction_mem instruction_mem(
		.A(InstructionMem_A), .JumpA(InstructionMem_JumpA),
		.RD0(InstructionMem_RD0), .RD1(InstructionMem_RD1), .RD2(InstructionMem_RD2), .RD3(InstructionMem_RD3),
		.JumpRD0(InstructionMem_JumpRD0), .JumpRD1(InstructionMem_JumpRD1), .JumpRD2(InstructionMem_JumpRD2), .JumpRD3(InstructionMem_JumpRD3));

/****************************************************************************************/
/* 	Microprocessor																		*/
/****************************************************************************************/
	mips mips(
		.CLK(CLK),
		.Reset(Reset),
		.InstructionMem_RD0(InstructionMem_RD0), .InstructionMem_RD1(InstructionMem_RD1), .InstructionMem_RD2(InstructionMem_RD2), .InstructionMem_RD3(InstructionMem_RD3),
		.InstructionMem_JumpRD0(InstructionMem_JumpRD0), .InstructionMem_JumpRD1(InstructionMem_JumpRD1), .InstructionMem_JumpRD2(InstructionMem_JumpRD2), .InstructionMem_JumpRD3(InstructionMem_JumpRD3),
		.DataMem_RD(DataMem_RD),
		.CacheRD0(CacheRD0), .CacheRD1(CacheRD1), .CacheRD2(CacheRD2), .CacheRD3(CacheRD3), .CacheRD4(CacheRD4), .CacheRD5(CacheRD5), .CacheRD6(CacheRD6), .CacheRD7(CacheRD7), .CacheRD8(CacheRD8), .CacheRD9(CacheRD9), .CacheRD10(CacheRD10), .CacheRD11(CacheRD11), .CacheRD12(CacheRD12), .CacheRD13(CacheRD13), .CacheRD14(CacheRD14), .CacheRD15(CacheRD15),
		.InstructionMem_A(InstructionMem_A), .InstructionMem_JumpA(InstructionMem_JumpA),
		.DataMem_WA(DataMem_WA), .DataMem_RA(DataMem_RA),
		.DataMem_WD(DataMem_WD),
		.DataMem_WE(DataMem_WE),
		.CacheRA(CacheRA));

/****************************************************************************************/
/* 	Data Memory																		*/
/****************************************************************************************/
	data_mem data_mem(
		.CLK(CLK),
		.WE(DataMem_WE),
		.WA(DataMem_WA), .RA(DataMem_RA),
		.WD(DataMem_WD),
		.CacheRA(CacheRA),
		.RD(DataMem_RD),
		.CacheRD0(CacheRD0), .CacheRD1(CacheRD1), .CacheRD2(CacheRD2), .CacheRD3(CacheRD3), .CacheRD4(CacheRD4), .CacheRD5(CacheRD5), .CacheRD6(CacheRD6), .CacheRD7(CacheRD7), .CacheRD8(CacheRD8), .CacheRD9(CacheRD9), .CacheRD10(CacheRD10), .CacheRD11(CacheRD11), .CacheRD12(CacheRD12), .CacheRD13(CacheRD13), .CacheRD14(CacheRD14), .CacheRD15(CacheRD15));
		
endmodule
