
module mips(
	input 			CLK,
	input			Reset,
	input  [31:0]	InstructionMem_RD0, InstructionMem_RD1, InstructionMem_RD2, InstructionMem_RD3,
	input  [31:0]	InstructionMem_JumpRD0, InstructionMem_JumpRD1, InstructionMem_JumpRD2, InstructionMem_JumpRD3,
	input  [31:0]	DataMem_RD,
	input  [31:0]	CacheRD0, CacheRD1, CacheRD2, CacheRD3, CacheRD4, CacheRD5, CacheRD6, CacheRD7, CacheRD8, CacheRD9, CacheRD10, CacheRD11, CacheRD12, CacheRD13, CacheRD14, CacheRD15,
	output [31:0]	InstructionMem_A, InstructionMem_JumpA,
	output [31:0]	DataMem_WA, DataMem_RA,
	output [31:0] 	DataMem_WD,
	output			DataMem_WE,
	output [31:0]	CacheRA);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	wire			InstrQueueBufEmpty0, InstrQueueBufEmpty1, InstrQueueBufEmpty2, InstrQueueBufEmpty3;
	wire   [63:0]	InstrQueueBufOut0, InstrQueueBufOut1, InstrQueueBufOut2, InstrQueueBufOut3;
	wire   [1:0]	InstrQueueRE;
	wire 			InstrQueueRCLK;
	wire   [31:0]	InstrQueueHeadData0, InstrQueueHeadData1, InstrQueueHeadData2, InstrQueueHeadData3, InstrQueueHeadPC;
	
	wire   [63:0]	Instr0, Instr1, Instr2, Instr3;
	wire   [31:0]	InstrROBTag;
	wire   [2:0]	MappingTableWE;
	wire			MappingTableWCLK;
	wire   [3:0]	D0ALUControlD, D1ALUControlD;
	wire   [31:0]	D0SrcAD, D0SrcBD, D1SrcAD, D1SrcBD, D2SrcAD, D2SrcBD, D3SrcAD, D3SrcBD;
	wire   [31:0]	D0DestD, D1DestD, D2DestD, D3DataD;
	wire			D0RegWriteD, D1RegWriteD, D2RegWriteD, D3MemWriteD;
	wire   [31:0]	ForwardTag0A, ForwardTag0B, ForwardTag1A, ForwardTag1B, ForwardTag2A, ForwardTag2B, ForwardTag3A, ForwardTag3B;
	wire   [31:0]	ForwardData0A, ForwardData0B, ForwardData1A, ForwardData1B, ForwardData2A, ForwardData2B, ForwardData3A, ForwardData3B;
	wire			ForwardFlag0A, ForwardFlag0B, ForwardFlag1A, ForwardFlag1B, ForwardFlag2A, ForwardFlag2B, ForwardFlag3A, ForwardFlag3B;
	wire			Branch, BranchResolved;
	wire   [31:0]	BranchTag;
	wire   [31:0]	BranchDest;
	wire			Jump;
	wire   [31:0]	JumpDest;
	wire   [31:0]	DataLoadCacheD, DestLoadCacheD;
	wire			RegWriteLoadCacheD;
	wire   [31:0]	LoadCacheRTag0A, LoadCacheRTag0B, LoadCacheRTag1A, LoadCacheRTag1B, LoadCacheRTag2A, LoadCacheRTag2B, LoadCacheRTag3A, LoadCacheRTag3B;
	wire   [31:0]	LoadCacheRData0A, LoadCacheRData0B, LoadCacheRData1A, LoadCacheRData1B, LoadCacheRData2A, LoadCacheRData2B, LoadCacheRData3A, LoadCacheRData3B;
	wire			LoadCacheRFlag0A, LoadCacheRFlag0B, LoadCacheRFlag1A, LoadCacheRFlag1B, LoadCacheRFlag2A, LoadCacheRFlag2B, LoadCacheRFlag3A, LoadCacheRFlag3B;
	
	wire   [3:0]	D0ALUControlE, D1ALUControlE;
	wire   [31:0]	D0SrcAE, D0SrcBE, D1SrcAE, D1SrcBE, D2SrcAE, D2SrcBE, D3SrcAE, D3SrcBE;
	wire   [31:0]	D0DestE, D1DestE, D2DestE, D3DataE;
	wire			D0RegWriteE, D1RegWriteE, D2RegWriteE, D3MemWriteE;
	
	wire   [1:0]	ROBWE;
	wire			ROBBufFull0, ROBBufFull1, ROBBufFull2, ROBBufFull3, ROBWCLK;
	wire   [31:0]	ROBRTag0A, ROBRTag0B, ROBRTag1A, ROBRTag1B, ROBRTag2A, ROBRTag2B, ROBRTag3A, ROBRTag3B;
	wire   [31:0]	ROBRData0A, ROBRData0B, ROBRData1A, ROBRData1B, ROBRData2A, ROBRData2B, ROBRData3A, ROBRData3B;
	wire			ROBRFlag0A, ROBRFlag0B, ROBRFlag1A, ROBRFlag1B, ROBRFlag2A, ROBRFlag2B, ROBRFlag3A, ROBRFlag3B;
	wire   [31:0]	ROBTag;
	wire   [69:0]	ROBBufIn0, ROBBufIn1, ROBBufIn2, ROBBufIn3;
	
	wire   [143:0]	RSEntry0, RSEntry1, RSEntry2, RSEntry3;
	wire   [69:0]	ROBEntry0, ROBEntry1, ROBEntry2, ROBEntry3;
	wire			ROBEntryValid0, ROBEntryValid1, ROBEntryValid2, ROBEntryValid3;
	wire			RegFileWE1, RegFileWE2;
	wire   [4:0]	RegFileA01, RegFileA02, RegFileA11, RegFileA12, RegFileA21, RegFileA22, RegFileA31, RegFileA32, RegFileWA1, RegFileWA2;
	wire   [31:0]	RegFileRD01, RegFileRD02, RegFileRD11, RegFileRD12, RegFileRD21, RegFileRD22, RegFileRD31, RegFileRD32, RegFileWD1, RegFileWD2, RegFileWD1Tag, RegFileWD2Tag;
	
	wire   [31:0]	ALUOut0E, ALUOut1E, A2E, A3E;
	wire   [31:0]	Dest0E, Dest1E, Dest2E, Data3E;
	wire			RegWrite0E, RegWrite1E, RegWrite2E, MemWrite3E;
	wire   [31:0]	ALURTag0A, ALURTag0B, ALURTag1A, ALURTag1B, ALURTag2A, ALURTag2B, ALURTag3A, ALURTag3B;
	wire   [31:0]	ALURData0A, ALURData0B, ALURData1A, ALURData1B, ALURData2A, ALURData2B, ALURData3A, ALURData3B;
	wire			ALURFlag0A, ALURFlag0B, ALURFlag1A, ALURFlag1B, ALURFlag2A, ALURFlag2B, ALURFlag3A, ALURFlag3B;
	
	wire   [31:0]	ALUOut0W, ALUOut1W, A2L, A3L;
	wire   [31:0]	Dest0W, Dest1W, Dest2L, Data3L;
	wire			RegWrite0W, RegWrite1W, RegWrite2L, MemWrite3L;
	
	wire   [31:0]	DataLoad2L;
	wire   [31:0]	DestLoad2L;
	wire			RegWriteLoad2L;
	wire   [31:0]	LoadRTag0A, LoadRTag0B, LoadRTag1A, LoadRTag1B, LoadRTag2A, LoadRTag2B, LoadRTag3A, LoadRTag3B;
	wire   [31:0]	LoadRData0A, LoadRData0B, LoadRData1A, LoadRData1B, LoadRData2A, LoadRData2B, LoadRData3A, LoadRData3B;
	wire			LoadRFlag0A, LoadRFlag0B, LoadRFlag1A, LoadRFlag1B, LoadRFlag2A, LoadRFlag2B, LoadRFlag3A, LoadRFlag3B;
	
	wire   [31:0]	DataLoad2W, DataLoadCacheW;
	wire   [31:0]	DestLoad2W, DestLoadCacheW;
	wire			RegWriteLoad2W, RegWriteLoadCacheW;
	
	wire			CacheRME, CacheHit;
	wire   [31:0]	CacheTag, CacheData;
	
/****************************************************************************************/
/* 	Fetch																				*/
/****************************************************************************************/
	fetch fetch(
		.CLK(CLK),
		.Reset(Reset),
		.RDF0(InstructionMem_RD0), .RDF1(InstructionMem_RD1), .RDF2(InstructionMem_RD2), .RDF3(InstructionMem_RD3),
		.JumpRDF0(InstructionMem_JumpRD0), .JumpRDF1(InstructionMem_JumpRD1), .JumpRDF2(InstructionMem_JumpRD2), .JumpRDF3(InstructionMem_JumpRD3),
		.InstrQueueRE(InstrQueueRE), .InstrQueueRCLK(InstrQueueRCLK),
		.Branch(Branch), .BranchDest(BranchDest), .Jump(Jump), .JumpDest(JumpDest), 
		.InstrQueueBufOut0(InstrQueueBufOut0), .InstrQueueBufOut1(InstrQueueBufOut1), .InstrQueueBufOut2(InstrQueueBufOut2), .InstrQueueBufOut3(InstrQueueBufOut3),
		.InstrQueueHeadData0(InstrQueueHeadData0), .InstrQueueHeadData1(InstrQueueHeadData1), .InstrQueueHeadData2(InstrQueueHeadData2), .InstrQueueHeadData3(InstrQueueHeadData3), .InstrQueueHeadPC(InstrQueueHeadPC),
		.InstrQueueBufEmpty0(InstrQueueBufEmpty0), .InstrQueueBufEmpty1(InstrQueueBufEmpty1), .InstrQueueBufEmpty2(InstrQueueBufEmpty2), .InstrQueueBufEmpty3(InstrQueueBufEmpty3),
		.AF(InstructionMem_A), .JumpAF(InstructionMem_JumpA));
	
/****************************************************************************************/
/* 	dispatch																			*/
/****************************************************************************************/
	dispatch dispatch(
		.CLK(CLK),
		.Reset(Reset),
		.InstrQueueBufEmpty0(InstrQueueBufEmpty0), .InstrQueueBufEmpty1(InstrQueueBufEmpty1), .InstrQueueBufEmpty2(InstrQueueBufEmpty2), .InstrQueueBufEmpty3(InstrQueueBufEmpty3),
		.InstrQueueBufOut0(InstrQueueBufOut0), .InstrQueueBufOut1(InstrQueueBufOut1), .InstrQueueBufOut2(InstrQueueBufOut2), .InstrQueueBufOut3(InstrQueueBufOut3),
		.InstrQueueHeadData0(InstrQueueHeadData0), .InstrQueueHeadData1(InstrQueueHeadData1), .InstrQueueHeadData2(InstrQueueHeadData2), .InstrQueueHeadData3(InstrQueueHeadData3), .InstrQueueHeadPC(InstrQueueHeadPC),
		.ROBBufFull0(ROBBufFull0), .ROBBufFull1(ROBBufFull1), .ROBBufFull2(ROBBufFull2), .ROBBufFull3(ROBBufFull3),
		.ROBTag(ROBTag),
		.RSEntry0(RSEntry0), .RSEntry1(RSEntry1), .RSEntry2(RSEntry2), .RSEntry3(RSEntry3),
		.ROBEntry0(ROBEntry0), .ROBEntry1(ROBEntry1), .ROBEntry2(ROBEntry2), .ROBEntry3(ROBEntry3),
		.ROBEntryValid0(ROBEntryValid0), .ROBEntryValid1(ROBEntryValid1), .ROBEntryValid2(ROBEntryValid2), .ROBEntryValid3(ROBEntryValid3),
		.ForwardData0A(ForwardData0A), .ForwardData0B(ForwardData0B), .ForwardData1A(ForwardData1A), .ForwardData1B(ForwardData1B), .ForwardData2A(ForwardData2A), .ForwardData2B(ForwardData2B), .ForwardData3A(ForwardData3A), .ForwardData3B(ForwardData3B),
		.ForwardFlag0A(ForwardFlag0A), .ForwardFlag0B(ForwardFlag0B), .ForwardFlag1A(ForwardFlag1A), .ForwardFlag1B(ForwardFlag1B), .ForwardFlag2A(ForwardFlag2A), .ForwardFlag2B(ForwardFlag2B), .ForwardFlag3A(ForwardFlag3A), .ForwardFlag3B(ForwardFlag3B),
		.D2CacheHit(CacheHit), .D2CacheData(CacheData),
		.LoadCacheRTag0A(LoadCacheRTag0A), .LoadCacheRTag0B(LoadCacheRTag0B), .LoadCacheRTag1A(LoadCacheRTag1A), .LoadCacheRTag1B(LoadCacheRTag1B), .LoadCacheRTag2A(LoadCacheRTag2A), .LoadCacheRTag2B(LoadCacheRTag2B), .LoadCacheRTag3A(LoadCacheRTag3A), .LoadCacheRTag3B(LoadCacheRTag3B),
		.InstrQueueRE(InstrQueueRE), .InstrQueueRCLK(InstrQueueRCLK),
		.ROBBufIn0(ROBBufIn0), .ROBBufIn1(ROBBufIn1), .ROBBufIn2(ROBBufIn2), .ROBBufIn3(ROBBufIn3),
		.ROBWE(ROBWE),
		.ROBWCLK(ROBWCLK),
		.Instr0(Instr0), .Instr1(Instr1), .Instr2(Instr2), .Instr3(Instr3),
		.InstrROBTag(InstrROBTag),
		.MappingTableWE(MappingTableWE), .MappingTableWCLK(MappingTableWCLK),
		.D0ALUControl(D0ALUControlD), .D1ALUControl(D1ALUControlD),
		.D0SrcA(D0SrcAD), .D0SrcB(D0SrcBD), .D1SrcA(D1SrcAD), .D1SrcB(D1SrcBD), .D2SrcA(D2SrcAD), .D2SrcB(D2SrcBD), .D3SrcA(D3SrcAD), .D3SrcB(D3SrcBD),
		.D0Dest(D0DestD), .D1Dest(D1DestD), .D2Dest(D2DestD), .D3Data(D3DataD),
		.D0RegWrite(D0RegWriteD), .D1RegWrite(D1RegWriteD), .D2RegWrite(D2RegWriteD), .D3MemWrite(D3MemWriteD),
		.Branch(Branch), .BranchResolved(BranchResolved), .BranchTag(BranchTag), .BranchDest(BranchDest), .Jump(Jump), .JumpDest(JumpDest), 
		.ForwardTag0A(ForwardTag0A), .ForwardTag0B(ForwardTag0B), .ForwardTag1A(ForwardTag1A), .ForwardTag1B(ForwardTag1B), .ForwardTag2A(ForwardTag2A), .ForwardTag2B(ForwardTag2B), .ForwardTag3A(ForwardTag3A), .ForwardTag3B(ForwardTag3B),
		.D2CacheRME(CacheRME), .D2CacheTag(CacheTag),
		.D2DataLoadCache(DataLoadCacheD), .D2DestLoadCache(DestLoadCacheD), .D2RegWriteLoadCache(RegWriteLoadCacheD),
		.LoadCacheRData0A(LoadCacheRData0A), .LoadCacheRData0B(LoadCacheRData0B), .LoadCacheRData1A(LoadCacheRData1A), .LoadCacheRData1B(LoadCacheRData1B), .LoadCacheRData2A(LoadCacheRData2A), .LoadCacheRData2B(LoadCacheRData2B), .LoadCacheRData3A(LoadCacheRData3A), .LoadCacheRData3B(LoadCacheRData3B),
		.LoadCacheRFlag0A(LoadCacheRFlag0A), .LoadCacheRFlag0B(LoadCacheRFlag0B), .LoadCacheRFlag1A(LoadCacheRFlag1A), .LoadCacheRFlag1B(LoadCacheRFlag1B), .LoadCacheRFlag2A(LoadCacheRFlag2A), .LoadCacheRFlag2B(LoadCacheRFlag2B), .LoadCacheRFlag3A(LoadCacheRFlag3A), .LoadCacheRFlag3B(LoadCacheRFlag3B));
	
	register #(.N(65)) reg_DtoW(
		.clk(CLK), .clear(Reset), .hold(1'b0), 
		.in({DataLoadCacheD, DestLoadCacheD, RegWriteLoadCacheD}), 
		.out({DataLoadCacheW, DestLoadCacheW, RegWriteLoadCacheW}));
	
/****************************************************************************************/
/* 	Mapping Table																		*/
/****************************************************************************************/
	mapping_table mapping_table(
		.CLK(CLK),
		.Reset(Reset),
		.WE(MappingTableWE), .WCLK(MappingTableWCLK),
		.Branch(Branch),
		.Instr0(Instr0), .Instr1(Instr1), .Instr2(Instr2), .Instr3(Instr3),
		.InstrROBTag(InstrROBTag),
		.RegFileRD01(RegFileRD01), .RegFileRD02(RegFileRD02), .RegFileRD11(RegFileRD11), .RegFileRD12(RegFileRD12), .RegFileRD21(RegFileRD21), .RegFileRD22(RegFileRD22), .RegFileRD31(RegFileRD31), .RegFileRD32(RegFileRD32),
		.RegFileWA1(RegFileWA1), .RegFileWA2(RegFileWA2), .RegFileWE1(RegFileWE1), .RegFileWE2(RegFileWE2), .RegFileWD1Tag(RegFileWD1Tag), .RegFileWD2Tag(RegFileWD2Tag),
		.RegFileA01(RegFileA01), .RegFileA02(RegFileA02), .RegFileA11(RegFileA11), .RegFileA12(RegFileA12), .RegFileA21(RegFileA21), .RegFileA22(RegFileA22), .RegFileA31(RegFileA31), .RegFileA32(RegFileA32),
		.RSEntry0(RSEntry0), .RSEntry1(RSEntry1), .RSEntry2(RSEntry2), .RSEntry3(RSEntry3),
		.ROBEntry0(ROBEntry0), .ROBEntry1(ROBEntry1), .ROBEntry2(ROBEntry2), .ROBEntry3(ROBEntry3),
		.ROBEntryValid0(ROBEntryValid0), .ROBEntryValid1(ROBEntryValid1), .ROBEntryValid2(ROBEntryValid2), .ROBEntryValid3(ROBEntryValid3));

	register #(.N(396)) reg_DtoE(
		.clk(CLK), .clear(Reset), .hold(1'b0), 
		.in({D0ALUControlD, D1ALUControlD, D0SrcAD, D0SrcBD, D1SrcAD, D1SrcBD, D2SrcAD, D2SrcBD, D3SrcAD, D3SrcBD, D0DestD, D1DestD, D2DestD, D3DataD, D0RegWriteD, D1RegWriteD, D2RegWriteD, D3MemWriteD}), 
		.out({D0ALUControlE, D1ALUControlE, D0SrcAE, D0SrcBE, D1SrcAE, D1SrcBE, D2SrcAE, D2SrcBE, D3SrcAE, D3SrcBE, D0DestE, D1DestE, D2DestE, D3DataE, D0RegWriteE, D1RegWriteE, D2RegWriteE, D3MemWriteE}));

/****************************************************************************************/
/* 	Execute																				*/
/****************************************************************************************/
	execute execute(
		.CLK(CLK),
		.Reset(Reset),
		.D0ALUControl(D0ALUControlE), .D1ALUControl(D1ALUControlE),
		.D0SrcA(D0SrcAE), .D0SrcB(D0SrcBE), .D1SrcA(D1SrcAE), .D1SrcB(D1SrcBE), .D2SrcA(D2SrcAE), .D2SrcB(D2SrcBE), .D3SrcA(D3SrcAE), .D3SrcB(D3SrcBE),
		.D0Dest(D0DestE), .D1Dest(D1DestE), .D2Dest(D2DestE), .D3Data(D3DataE),
		.D0RegWrite(D0RegWriteE), .D1RegWrite(D1RegWriteE), .D2RegWrite(D2RegWriteE), .D3MemWrite(D3MemWriteE),
		.ALURTag0A(ALURTag0A), .ALURTag0B(ALURTag0B), .ALURTag1A(ALURTag1A), .ALURTag1B(ALURTag1B), .ALURTag2A(ALURTag2A), .ALURTag2B(ALURTag2B), .ALURTag3A(ALURTag3A), .ALURTag3B(ALURTag3B),
		.ALUOut0(ALUOut0E), .ALUOut1(ALUOut1E), .A2(A2E), .A3(A3E),
		.Dest0(Dest0E), .Dest1(Dest1E), .Dest2(Dest2E), .Data3(Data3E),
		.RegWrite0(RegWrite0E), .RegWrite1(RegWrite1E), .RegWrite2(RegWrite2E), .MemWrite3(MemWrite3E),
		.ALURData0A(ALURData0A), .ALURData0B(ALURData0B), .ALURData1A(ALURData1A), .ALURData1B(ALURData1B), .ALURData2A(ALURData2A), .ALURData2B(ALURData2B), .ALURData3A(ALURData3A), .ALURData3B(ALURData3B),
		.ALURFlag0A(ALURFlag0A), .ALURFlag0B(ALURFlag0B), .ALURFlag1A(ALURFlag1A), .ALURFlag1B(ALURFlag1B), .ALURFlag2A(ALURFlag2A), .ALURFlag2B(ALURFlag2B), .ALURFlag3A(ALURFlag3A), .ALURFlag3B(ALURFlag3B));

	register #(.N(130)) reg_EtoLW(
		.clk(CLK), .clear(Reset), .hold(1'b0), 
		.in({A2E, A3E, Dest2E, Data3E, RegWrite2E, MemWrite3E}), 
		.out({A2L, DataMem_WA, Dest2L, DataMem_WD, RegWrite2L, DataMem_WE}));
	
	assign ALUOut0W = ALUOut0E;
	assign ALUOut1W = ALUOut1E;
	assign Dest0W = Dest0E;
	assign Dest1W = Dest1E;
	assign RegWrite0W = RegWrite0E;
	assign RegWrite1W = RegWrite1E;
		
/****************************************************************************************/
/* 	Load Unit																			*/
/****************************************************************************************/
	load load(
		.CLK(CLK),
		.Reset(Reset),
		.A(A2L),
		.Dest(Dest2L),
		.RegWrite(RegWrite2L),
		.DataMem_RD(DataMem_RD),
		.LoadRTag0A(LoadRTag0A), .LoadRTag0B(LoadRTag0B), .LoadRTag1A(LoadRTag1A), .LoadRTag1B(LoadRTag1B), .LoadRTag2A(LoadRTag2A), .LoadRTag2B(LoadRTag2B), .LoadRTag3A(LoadRTag3A), .LoadRTag3B(LoadRTag3B),
		.DataMem_RA(DataMem_RA),
		.DataLoad(DataLoad2L),
		.DestLoad(DestLoad2L),
		.RegWriteLoad(RegWriteLoad2L),
		.LoadRData0A(LoadRData0A), .LoadRData0B(LoadRData0B), .LoadRData1A(LoadRData1A), .LoadRData1B(LoadRData1B), .LoadRData2A(LoadRData2A), .LoadRData2B(LoadRData2B), .LoadRData3A(LoadRData3A), .LoadRData3B(LoadRData3B),
		.LoadRFlag0A(LoadRFlag0A), .LoadRFlag0B(LoadRFlag0B), .LoadRFlag1A(LoadRFlag1A), .LoadRFlag1B(LoadRFlag1B), .LoadRFlag2A(LoadRFlag2A), .LoadRFlag2B(LoadRFlag2B), .LoadRFlag3A(LoadRFlag3A), .LoadRFlag3B(LoadRFlag3B));
	
	register #(.N(65)) reg_LtoW(
		.clk(CLK), .clear(Reset), .hold(1'b0), 
		.in({DataLoad2L, DestLoad2L, RegWriteLoad2L}), 
		.out({DataLoad2W, DestLoad2W, RegWriteLoad2W}));

/****************************************************************************************/
/* 	Writeback																			*/
/****************************************************************************************/
	writeback writeback(
		.CLK(CLK),
		.Reset(Reset),
		.ROBWE(ROBWE),
		.ROBWCLK(ROBWCLK),
		.ROBBufIn0(ROBBufIn0), .ROBBufIn1(ROBBufIn1), .ROBBufIn2(ROBBufIn2), .ROBBufIn3(ROBBufIn3),
		.ALUOut0(ALUOut0W), .ALUOut1(ALUOut1W), .Data2(DataLoad2W), .DataCache(DataLoadCacheW),
		.Dest0(Dest0W), .Dest1(Dest1W), .Dest2(DestLoad2W), .DestCache(DestLoadCacheW),
		.RegWrite0(RegWrite0W), .RegWrite1(RegWrite1W), .RegWrite2(RegWriteLoad2W), .RegWriteCache(RegWriteLoadCacheW),
		.ROBRTag0A(ROBRTag0A), .ROBRTag0B(ROBRTag0B), .ROBRTag1A(ROBRTag1A), .ROBRTag1B(ROBRTag1B), .ROBRTag2A(ROBRTag2A), .ROBRTag2B(ROBRTag2B), .ROBRTag3A(ROBRTag3A), .ROBRTag3B(ROBRTag3B),
		.Branch(Branch), .BranchResolved(BranchResolved), .BranchTag(BranchTag),
		.ROBBufFull0(ROBBufFull0), .ROBBufFull1(ROBBufFull1), .ROBBufFull2(ROBBufFull2), .ROBBufFull3(ROBBufFull3), .ROBTag(ROBTag),
		.RegFileWA1(RegFileWA1), .RegFileWA2(RegFileWA2), .RegFileWD1(RegFileWD1), .RegFileWD2(RegFileWD2), .RegFileWE1(RegFileWE1), .RegFileWE2(RegFileWE2), .RegFileWD1Tag(RegFileWD1Tag), .RegFileWD2Tag(RegFileWD2Tag),
		.ROBRData0A(ROBRData0A), .ROBRData0B(ROBRData0B), .ROBRData1A(ROBRData1A), .ROBRData1B(ROBRData1B), .ROBRData2A(ROBRData2A), .ROBRData2B(ROBRData2B), .ROBRData3A(ROBRData3A), .ROBRData3B(ROBRData3B),
		.ROBRFlag0A(ROBRFlag0A), .ROBRFlag0B(ROBRFlag0B), .ROBRFlag1A(ROBRFlag1A), .ROBRFlag1B(ROBRFlag1B), .ROBRFlag2A(ROBRFlag2A), .ROBRFlag2B(ROBRFlag2B), .ROBRFlag3A(ROBRFlag3A), .ROBRFlag3B(ROBRFlag3B));

/****************************************************************************************/
/* 	Data Forwarding																		*/
/****************************************************************************************/
	forwarding forwarding(
		.ForwardTag0A(ForwardTag0A), .ForwardTag0B(ForwardTag0B), .ForwardTag1A(ForwardTag1A), .ForwardTag1B(ForwardTag1B), .ForwardTag2A(ForwardTag2A), .ForwardTag2B(ForwardTag2B), .ForwardTag3A(ForwardTag3A), .ForwardTag3B(ForwardTag3B),
		.ALURData0A(ALURData0A), .ALURData0B(ALURData0B), .ALURData1A(ALURData1A), .ALURData1B(ALURData1B), .ALURData2A(ALURData2A), .ALURData2B(ALURData2B), .ALURData3A(ALURData3A), .ALURData3B(ALURData3B),
		.ALURFlag0A(ALURFlag0A), .ALURFlag0B(ALURFlag0B), .ALURFlag1A(ALURFlag1A), .ALURFlag1B(ALURFlag1B), .ALURFlag2A(ALURFlag2A), .ALURFlag2B(ALURFlag2B), .ALURFlag3A(ALURFlag3A), .ALURFlag3B(ALURFlag3B),
		.LoadRData0A(LoadRData0A), .LoadRData0B(LoadRData0B), .LoadRData1A(LoadRData1A), .LoadRData1B(LoadRData1B), .LoadRData2A(LoadRData2A), .LoadRData2B(LoadRData2B), .LoadRData3A(LoadRData3A), .LoadRData3B(LoadRData3B),
		.LoadRFlag0A(LoadRFlag0A), .LoadRFlag0B(LoadRFlag0B), .LoadRFlag1A(LoadRFlag1A), .LoadRFlag1B(LoadRFlag1B), .LoadRFlag2A(LoadRFlag2A), .LoadRFlag2B(LoadRFlag2B), .LoadRFlag3A(LoadRFlag3A), .LoadRFlag3B(LoadRFlag3B),
		.LoadCacheRData0A(LoadCacheRData0A), .LoadCacheRData0B(LoadCacheRData0B), .LoadCacheRData1A(LoadCacheRData1A), .LoadCacheRData1B(LoadCacheRData1B), .LoadCacheRData2A(LoadCacheRData2A), .LoadCacheRData2B(LoadCacheRData2B), .LoadCacheRData3A(LoadCacheRData3A), .LoadCacheRData3B(LoadCacheRData3B),
		.LoadCacheRFlag0A(LoadCacheRFlag0A), .LoadCacheRFlag0B(LoadCacheRFlag0B), .LoadCacheRFlag1A(LoadCacheRFlag1A), .LoadCacheRFlag1B(LoadCacheRFlag1B), .LoadCacheRFlag2A(LoadCacheRFlag2A), .LoadCacheRFlag2B(LoadCacheRFlag2B), .LoadCacheRFlag3A(LoadCacheRFlag3A), .LoadCacheRFlag3B(LoadCacheRFlag3B),
		.ROBRData0A(ROBRData0A), .ROBRData0B(ROBRData0B), .ROBRData1A(ROBRData1A), .ROBRData1B(ROBRData1B), .ROBRData2A(ROBRData2A), .ROBRData2B(ROBRData2B), .ROBRData3A(ROBRData3A), .ROBRData3B(ROBRData3B),
		.ROBRFlag0A(ROBRFlag0A), .ROBRFlag0B(ROBRFlag0B), .ROBRFlag1A(ROBRFlag1A), .ROBRFlag1B(ROBRFlag1B), .ROBRFlag2A(ROBRFlag2A), .ROBRFlag2B(ROBRFlag2B), .ROBRFlag3A(ROBRFlag3A), .ROBRFlag3B(ROBRFlag3B),
		.ForwardData0A(ForwardData0A), .ForwardData0B(ForwardData0B), .ForwardData1A(ForwardData1A), .ForwardData1B(ForwardData1B), .ForwardData2A(ForwardData2A), .ForwardData2B(ForwardData2B), .ForwardData3A(ForwardData3A), .ForwardData3B(ForwardData3B),
		.ForwardFlag0A(ForwardFlag0A), .ForwardFlag0B(ForwardFlag0B), .ForwardFlag1A(ForwardFlag1A), .ForwardFlag1B(ForwardFlag1B), .ForwardFlag2A(ForwardFlag2A), .ForwardFlag2B(ForwardFlag2B), .ForwardFlag3A(ForwardFlag3A), .ForwardFlag3B(ForwardFlag3B),
		.ALURTag0A(ALURTag0A), .ALURTag0B(ALURTag0B), .ALURTag1A(ALURTag1A), .ALURTag1B(ALURTag1B), .ALURTag2A(ALURTag2A), .ALURTag2B(ALURTag2B), .ALURTag3A(ALURTag3A), .ALURTag3B(ALURTag3B),
		.LoadRTag0A(LoadRTag0A), .LoadRTag0B(LoadRTag0B), .LoadRTag1A(LoadRTag1A), .LoadRTag1B(LoadRTag1B), .LoadRTag2A(LoadRTag2A), .LoadRTag2B(LoadRTag2B), .LoadRTag3A(LoadRTag3A), .LoadRTag3B(LoadRTag3B),
		.LoadCacheRTag0A(LoadCacheRTag0A), .LoadCacheRTag0B(LoadCacheRTag0B), .LoadCacheRTag1A(LoadCacheRTag1A), .LoadCacheRTag1B(LoadCacheRTag1B), .LoadCacheRTag2A(LoadCacheRTag2A), .LoadCacheRTag2B(LoadCacheRTag2B), .LoadCacheRTag3A(LoadCacheRTag3A), .LoadCacheRTag3B(LoadCacheRTag3B),
		.ROBRTag0A(ROBRTag0A), .ROBRTag0B(ROBRTag0B), .ROBRTag1A(ROBRTag1A), .ROBRTag1B(ROBRTag1B), .ROBRTag2A(ROBRTag2A), .ROBRTag2B(ROBRTag2B), .ROBRTag3A(ROBRTag3A), .ROBRTag3B(ROBRTag3B));

/****************************************************************************************/
/* 	Register File																		*/
/****************************************************************************************/
	register_file register_file(
		.CLK(CLK),
		.WE1(RegFileWE1), .WE2(RegFileWE2),
		.A01(RegFileA01), .A02(RegFileA02), .A11(RegFileA11), .A12(RegFileA12), .A21(RegFileA21), .A22(RegFileA22), .A31(RegFileA31), .A32(RegFileA32), .WA1(RegFileWA1), .WA2(RegFileWA2),
		.RD01(RegFileRD01), .RD02(RegFileRD02), .RD11(RegFileRD11), .RD12(RegFileRD12), .RD21(RegFileRD21), .RD22(RegFileRD22), .RD31(RegFileRD31), .RD32(RegFileRD32), .WD1(RegFileWD1), .WD2(RegFileWD2));

/****************************************************************************************/
/* 	Cache																				*/
/****************************************************************************************/
	cache cache(
		.CLK(CLK),
		.RME(CacheRME), .WE(DataMem_WE),
		.WA(DataMem_WA), .RTag(CacheTag),
		.RMD0(CacheRD0), .RMD1(CacheRD1), .RMD2(CacheRD2), .RMD3(CacheRD3), .RMD4(CacheRD4), .RMD5(CacheRD5), .RMD6(CacheRD6), .RMD7(CacheRD7), .RMD8(CacheRD8), .RMD9(CacheRD9), .RMD10(CacheRD10), .RMD11(CacheRD11), .RMD12(CacheRD12), .RMD13(CacheRD13), .RMD14(CacheRD14), .RMD15(CacheRD15),
		.WD(DataMem_WD), .CacheRA(CacheRA), .RHit(CacheHit), .RD(CacheData));
		
endmodule
