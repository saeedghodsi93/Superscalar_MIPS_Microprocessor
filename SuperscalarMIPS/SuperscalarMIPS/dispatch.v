
`timescale 1ns/1ns

module dispatch(
	input 			CLK,
	input			Reset,
	input 			InstrQueueBufEmpty0, InstrQueueBufEmpty1, InstrQueueBufEmpty2, InstrQueueBufEmpty3,
	input  [63:0]	InstrQueueBufOut0, InstrQueueBufOut1, InstrQueueBufOut2, InstrQueueBufOut3,
	input  [31:0]	InstrQueueHeadData0, InstrQueueHeadData1, InstrQueueHeadData2, InstrQueueHeadData3, InstrQueueHeadPC,
	input			ROBBufFull0, ROBBufFull1, ROBBufFull2, ROBBufFull3,
	input  [31:0]	ROBTag,
	input  [143:0]	RSEntry0, RSEntry1, RSEntry2, RSEntry3,
	input  [69:0]	ROBEntry0, ROBEntry1, ROBEntry2, ROBEntry3,
	input			ROBEntryValid0, ROBEntryValid1, ROBEntryValid2, ROBEntryValid3,
	input  [31:0]	ForwardData0A, ForwardData0B, ForwardData1A, ForwardData1B, ForwardData2A, ForwardData2B, ForwardData3A, ForwardData3B,
	input			ForwardFlag0A, ForwardFlag0B, ForwardFlag1A, ForwardFlag1B, ForwardFlag2A, ForwardFlag2B, ForwardFlag3A, ForwardFlag3B,
	input			D2CacheHit,
	input  [31:0]	D2CacheData,
	input  [31:0]	LoadCacheRTag0A, LoadCacheRTag0B, LoadCacheRTag1A, LoadCacheRTag1B, LoadCacheRTag2A, LoadCacheRTag2B, LoadCacheRTag3A, LoadCacheRTag3B,output [1:0]	InstrQueueRE,
	output			InstrQueueRCLK,
	output [69:0]	ROBBufIn0, ROBBufIn1, ROBBufIn2, ROBBufIn3,
	output [1:0]	ROBWE,
	output			ROBWCLK,
	output [63:0]	Instr0, Instr1, Instr2, Instr3,
	output [31:0]	InstrROBTag,
	output [2:0]	MappingTableWE,
	output			MappingTableWCLK,
	output [3:0]	D0ALUControl, D1ALUControl,
	output [31:0]	D0SrcA, D0SrcB, D1SrcA, D1SrcB, D2SrcA, D2SrcB, D3SrcA, D3SrcB,
	output [31:0]	D0Dest, D1Dest, D2Dest, D3Data,
	output			D0RegWrite, D1RegWrite, D2RegWrite, D3MemWrite,
	output			Branch, BranchResolved,
	output [31:0]	BranchTag,
	output [31:0]	BranchDest,
	output 			Jump,
	output [31:0]	JumpDest,
	output [31:0]	ForwardTag0A, ForwardTag0B, ForwardTag1A, ForwardTag1B, ForwardTag2A, ForwardTag2B, ForwardTag3A, ForwardTag3B,
	output			D2CacheRME,
	output [31:0]	D2CacheTag,
	output [31:0]	D2DataLoadCache,
	output [31:0]	D2DestLoadCache,
	output			D2RegWriteLoadCache,
	output [31:0]	LoadCacheRData0A, LoadCacheRData0B, LoadCacheRData1A, LoadCacheRData1B, LoadCacheRData2A, LoadCacheRData2B, LoadCacheRData3A, LoadCacheRData3B,
	output			LoadCacheRFlag0A, LoadCacheRFlag0B, LoadCacheRFlag1A, LoadCacheRFlag1B, LoadCacheRFlag2A, LoadCacheRFlag2B, LoadCacheRFlag3A, LoadCacheRFlag3B);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	reg				JumpIssued;
	reg    [31:0]	JumpPC;
	reg    [4:0]	JumpRs, JumpRt;
	reg    [31:0]	JumpImm;
	reg    [31:0]	JumpDest_reg;
	reg				Jump_reg;
	
	reg    [1:0]	InstrQueueRE_reg;
	reg				InstrQueueRCLK_reg;
	reg				BranchStall;
	reg    [2:0]	InstrQueueCounter_temp;
	reg    [3:0]	RS0BufCounter_temp, RS1BufCounter_temp, RS2BufCounter_temp, RS3BufCounter_temp;
	wire   [1:0]	RS0BufFull, RS1BufFull, RS2BufFull, RS3BufFull;
	
	reg    [69:0]	ROBBufIn_reg0, ROBBufIn_reg1, ROBBufIn_reg2, ROBBufIn_reg3;
	reg    [2:0]	ROBCounter_temp;
	reg    [1:0]	ROBWE_reg;
	reg				ROBWCLK_reg;
	reg    [2:0]	MappingTableWE_reg;
	reg  			MappingTableWCLK_reg;
	
	reg    [143:0]	RS0BufIn0, RS0BufIn1, RS0BufIn2, RS0BufIn3;
	reg    [143:0]	RS1BufIn0, RS1BufIn1, RS1BufIn2, RS1BufIn3;
	reg    [143:0]	RS2BufIn0, RS2BufIn1, RS2BufIn2, RS2BufIn3;
	reg    [143:0]	RS3BufIn0, RS3BufIn1, RS3BufIn2, RS3BufIn3;
	reg    [1:0]	RS0WE, RS1WE, RS2WE, RS3WE;
	reg				RS0WCLK, RS1WCLK, RS2WCLK, RS3WCLK, RS0RCLK, RS1RCLK, RS2RCLK, RS3RCLK;
	wire   [143:0]	RS0BufOut, RS1BufOut, RS2BufOut, RS3BufOut;
	wire			RS0HeadFlagA, RS0HeadFlagB, RS1HeadFlagA, RS1HeadFlagB, RS2HeadFlagA, RS2HeadFlagB, RS3HeadFlagA, RS3HeadFlagB;
	wire   [31:0]	RS0HeadDataA, RS0HeadDataB, RS1HeadDataA, RS1HeadDataB, RS2HeadDataA, RS2HeadDataB, RS3HeadDataA, RS3HeadDataB;
	wire   [143:0]	RS0HeadElement, RS1HeadElement, RS2HeadElement, RS3HeadElement;
	wire			RS0BufFull0, RS0BufFull1, RS0BufFull2, RS0BufFull3;
	wire			RS1BufFull0, RS1BufFull1, RS1BufFull2, RS1BufFull3;
	wire			RS2BufFull0, RS2BufFull1, RS2BufFull2, RS2BufFull3;
	wire			RS3BufFull0, RS3BufFull1, RS3BufFull2, RS3BufFull3;
	wire			RS0BufEmpty, RS1BufEmpty, RS2BufEmpty, RS3BufEmpty;
	wire   [3:0]	RS0BufCounter, RS1BufCounter, RS2BufCounter, RS3BufCounter;
	reg    [31:0]	ForwardData0A_temp, ForwardData0B_temp, ForwardData1A_temp, ForwardData1B_temp, ForwardData2A_temp, ForwardData2B_temp, ForwardData3A_temp, ForwardData3B_temp;
	reg    [143:0]	D0RSEntry, D1RSEntry, D2RSEntry, D3RSEntry;
	wire			D0CacheRME, D1CacheRME, D3CacheRME;
	wire   [31:0]	D0CacheTag, D1CacheTag, D3CacheTag;
	wire			D0CacheHit, D1CacheHit, D3CacheHit;
	wire   [31:0]	D0CacheData, D1CacheData, D3CacheData;
	wire   [31:0]	D0DataLoadCache, D1DataLoadCache, D3DataLoadCache;
	wire   [31:0]	D0DestLoadCache, D1DestLoadCache, D3DestLoadCache;
	wire			D0RegWriteLoadCache, D1RegWriteLoadCache, D3RegWriteLoadCache;
	wire   [3:0]	D2ALUControl, D3ALUControl;
	wire   			D0Branch, D1Branch, D2Branch, D3Branch, D0BranchResolved, D1BranchResolved, D2BranchResolved, D3BranchResolved;
	wire   [31:0]	D0BranchTag, D1BranchTag, D2BranchTag, D3BranchTag;
	
/****************************************************************************************/
/* 	Reset																				*/
/****************************************************************************************/
	always@(Reset) begin
		JumpIssued = 0;
		JumpPC = 32'd0;
		JumpRs = 5'd0;
		JumpRt = 5'd0;
		JumpImm = 16'd0;
		JumpDest_reg = 32'd0;
		Jump_reg = 0;
		
		InstrQueueRE_reg = 0;
		InstrQueueRCLK_reg = 0;
		BranchStall = 0;
		InstrQueueCounter_temp = 0;
		RS0BufCounter_temp = 0;
		RS1BufCounter_temp = 0;
		RS2BufCounter_temp = 0;
		RS3BufCounter_temp = 0;
		
		RS0BufIn0 = 0;
		RS0BufIn1 = 0;
		RS0BufIn2 = 0;
		RS0BufIn3 = 0;
		RS1BufIn0 = 0;
		RS1BufIn1 = 0;
		RS1BufIn2 = 0;
		RS1BufIn3 = 0;
		RS2BufIn0 = 0;
		RS2BufIn1 = 0;
		RS2BufIn2 = 0;
		RS2BufIn3 = 0;
		RS3BufIn0 = 0;
		RS3BufIn1 = 0;
		RS3BufIn2 = 0;
		RS3BufIn3 = 0;
		RS0WE = 2'd0;
		RS1WE = 2'd0;
		RS2WE = 2'd0;
		RS3WE = 2'd0;
		RS0WCLK = 0;
		RS1WCLK = 0;
		RS2WCLK = 0;
		RS3WCLK = 0;
		D0RSEntry = 144'd0;
		D1RSEntry = 144'd0;
		D2RSEntry = 144'd0;
		D3RSEntry = 144'd0;
		
		ROBBufIn_reg0 = 70'd0;
		ROBBufIn_reg1 = 70'd0;
		ROBBufIn_reg2 = 70'd0;
		ROBBufIn_reg3 = 70'd0;
		ROBWE_reg = 2'd0;
		ROBWCLK_reg = 0;
		ROBCounter_temp = 0;
		MappingTableWE_reg = 3'd0;
		MappingTableWCLK_reg = 0;
		
		ForwardData0A_temp = 32'd0;
		ForwardData0B_temp = 32'd0;
		ForwardData1A_temp = 32'd0;
		ForwardData1B_temp = 32'd0;
		ForwardData2A_temp = 32'd0;
		ForwardData2B_temp = 32'd0;
		ForwardData3A_temp = 32'd0;
		ForwardData3B_temp = 32'd0;
		
	end		

/****************************************************************************************/
/* 	Reservation Stations																*/
/****************************************************************************************/
	reservation_station reservation_station_0(
		.Reset(Reset),
		.RSBufIn0(RS0BufIn0), .RSBufIn1(RS0BufIn1), .RSBufIn2(RS0BufIn2), .RSBufIn3(RS0BufIn3), 
		.RSWE(RS0WE),
		.RSWCLK(RS0WCLK),
		.RSRCLK(RS0RCLK),
		.Branch(Branch),
		.BranchTag(BranchTag),
		.RSBufOut(RS0BufOut),
		.RSHeadFlagA(RS0HeadFlagA), .RSHeadFlagB(RS0HeadFlagB),
		.RSHeadDataA(RS0HeadDataA), .RSHeadDataB(RS0HeadDataB),
		.RSHeadElement(RS0HeadElement),
		.RSBufEmpty(RS0BufEmpty),
		.RSBufFull0(RS0BufFull0), .RSBufFull1(RS0BufFull1), .RSBufFull2(RS0BufFull2), .RSBufFull3(RS0BufFull3),
		.RSBufCounter(RS0BufCounter));
	reservation_station reservation_station_1(
		.Reset(Reset),
		.RSBufIn0(RS1BufIn0), .RSBufIn1(RS1BufIn1), .RSBufIn2(RS1BufIn2), .RSBufIn3(RS1BufIn3), 
		.RSWE(RS1WE),
		.RSWCLK(RS1WCLK),
		.RSRCLK(RS1RCLK),
		.Branch(Branch),
		.BranchTag(BranchTag),
		.RSBufOut(RS1BufOut),
		.RSHeadFlagA(RS1HeadFlagA), .RSHeadFlagB(RS1HeadFlagB),
		.RSHeadDataA(RS1HeadDataA), .RSHeadDataB(RS1HeadDataB),
		.RSHeadElement(RS1HeadElement),
		.RSBufEmpty(RS1BufEmpty),
		.RSBufFull0(RS1BufFull0), .RSBufFull1(RS1BufFull1), .RSBufFull2(RS1BufFull2), .RSBufFull3(RS1BufFull3),
		.RSBufCounter(RS1BufCounter));
	reservation_station reservation_station_2(
		.Reset(Reset),
		.RSBufIn0(RS2BufIn0), .RSBufIn1(RS2BufIn1), .RSBufIn2(RS2BufIn2), .RSBufIn3(RS2BufIn3), 
		.RSWE(RS2WE),
		.RSWCLK(RS2WCLK),
		.RSRCLK(RS2RCLK),
		.Branch(Branch),
		.BranchTag(BranchTag),
		.RSBufOut(RS2BufOut),
		.RSHeadFlagA(RS2HeadFlagA), .RSHeadFlagB(RS2HeadFlagB),
		.RSHeadDataA(RS2HeadDataA), .RSHeadDataB(RS2HeadDataB),
		.RSHeadElement(RS2HeadElement),
		.RSBufEmpty(RS2BufEmpty),
		.RSBufFull0(RS2BufFull0), .RSBufFull1(RS2BufFull1), .RSBufFull2(RS2BufFull2), .RSBufFull3(RS2BufFull3),
		.RSBufCounter(RS2BufCounter));
	reservation_station reservation_station_3(
		.Reset(Reset),
		.RSBufIn0(RS3BufIn0), .RSBufIn1(RS3BufIn1), .RSBufIn2(RS3BufIn2), .RSBufIn3(RS3BufIn3), 
		.RSWE(RS3WE),
		.RSWCLK(RS3WCLK),
		.RSRCLK(RS3RCLK),
		.Branch(Branch),
		.BranchTag(BranchTag),
		.RSBufOut(RS3BufOut),
		.RSHeadFlagA(RS3HeadFlagA), .RSHeadFlagB(RS3HeadFlagB),
		.RSHeadDataA(RS3HeadDataA), .RSHeadDataB(RS3HeadDataB),
		.RSHeadElement(RS3HeadElement),
		.RSBufEmpty(RS3BufEmpty),
		.RSBufFull0(RS3BufFull0), .RSBufFull1(RS3BufFull1), .RSBufFull2(RS3BufFull2), .RSBufFull3(RS3BufFull3),
		.RSBufCounter(RS3BufCounter));
		
/****************************************************************************************/
/* 	Instruction Queue to Reservation Stations Logic										*/
/****************************************************************************************/		
	always@(posedge CLK) begin

		JumpIssued = 0;
		Jump_reg = 0;
		JumpDest_reg = 0;
		RS0BufCounter_temp = 0;
		RS1BufCounter_temp = 0;
		RS2BufCounter_temp = 0;
		RS3BufCounter_temp = 0;
		
		InstrQueueCounter_temp = RS0BufCounter_temp+RS1BufCounter_temp+RS2BufCounter_temp+RS3BufCounter_temp;
		if(!InstrQueueBufEmpty0 && !ROBBufFull0 && InstrQueueCounter_temp>=0) begin
			if(InstrQueueHeadData0[31:26]==6'b100011) begin
				if(!RS2BufFull) begin
					InstrQueueRE_reg = 2'd0;
					RS2BufCounter_temp = RS2BufCounter_temp + 1;
				end
			end else if(InstrQueueHeadData0[31:26]==6'b101011) begin
				if(!RS3BufFull) begin
					InstrQueueRE_reg = 2'd0;
					RS3BufCounter_temp = RS3BufCounter_temp + 1;
				end
			end else if(InstrQueueHeadData0[31:26]==6'b000100 || InstrQueueHeadData0[31:26]==6'b000101) begin
				if(!RS0BufFull) begin
					if(!BranchStall) begin
						BranchStall = 1;
						InstrQueueRE_reg = 2'd0;
						RS0BufCounter_temp = RS0BufCounter_temp + 1;
					end
				end
			end else if(RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
				if(!RS0BufFull) begin
					InstrQueueRE_reg = 2'd0;
					RS0BufCounter_temp = RS0BufCounter_temp + 1;
				end
			end else begin
				if(!RS1BufFull) begin
					InstrQueueRE_reg = 2'd0;
					RS1BufCounter_temp = RS1BufCounter_temp + 1;
				end
			end
			
			InstrQueueCounter_temp = RS0BufCounter_temp+RS1BufCounter_temp+RS2BufCounter_temp+RS3BufCounter_temp;
			if(!InstrQueueBufEmpty1 && !ROBBufFull1 && InstrQueueCounter_temp>=1) begin
				if(InstrQueueHeadData1[31:26]==6'b100011) begin
					if(!RS2BufFull) begin
						InstrQueueRE_reg = 2'd1;
						RS2BufCounter_temp = RS2BufCounter_temp + 1;
					end
				end else if(InstrQueueHeadData1[31:26]==6'b101011) begin
					if(!RS3BufFull) begin
						InstrQueueRE_reg = 2'd1;
						RS3BufCounter_temp = RS3BufCounter_temp + 1;
					end
				end else if(InstrQueueHeadData1[31:26]==6'b000100 || InstrQueueHeadData1[31:26]==6'b000101) begin
					if(!RS0BufFull) begin
						if(!BranchStall) begin
							BranchStall = 1;
							InstrQueueRE_reg = 2'd1;
							RS0BufCounter_temp = RS0BufCounter_temp + 1;
						end
					end
				end else if(RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
					if(!RS0BufFull) begin
						InstrQueueRE_reg = 2'd1;
						RS0BufCounter_temp = RS0BufCounter_temp + 1;
					end
				end else begin
					if(!RS1BufFull) begin
						InstrQueueRE_reg = 2'd1;
						RS1BufCounter_temp = RS1BufCounter_temp + 1;
					end
				end
				
				InstrQueueCounter_temp = RS0BufCounter_temp+RS1BufCounter_temp+RS2BufCounter_temp+RS3BufCounter_temp;
				if(!InstrQueueBufEmpty2 && !ROBBufFull2 && InstrQueueCounter_temp>=2) begin
					if(InstrQueueHeadData2[31:26]==6'b100011) begin
						if(!RS2BufFull) begin
							InstrQueueRE_reg = 2'd2;
							RS2BufCounter_temp = RS2BufCounter_temp + 1;
						end
					end else if(InstrQueueHeadData2[31:26]==6'b101011) begin
						if(!RS3BufFull) begin
							InstrQueueRE_reg = 2'd2;
							RS3BufCounter_temp = RS3BufCounter_temp + 1;
						end
					end else if(InstrQueueHeadData2[31:26]==6'b000100 || InstrQueueHeadData2[31:26]==6'b000101) begin
						if(!RS0BufFull) begin
							if(!BranchStall) begin
								BranchStall = 1;
								InstrQueueRE_reg = 2'd2;
								RS0BufCounter_temp = RS0BufCounter_temp + 1;
							end
						end 
					end else if(RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
						if(!RS0BufFull) begin
							InstrQueueRE_reg = 2'd2;
							RS0BufCounter_temp = RS0BufCounter_temp + 1;
						end
					end else begin
						if(!RS1BufFull) begin
							InstrQueueRE_reg = 2'd2;
							RS1BufCounter_temp = RS1BufCounter_temp + 1;
						end
					end
					
					InstrQueueCounter_temp = RS0BufCounter_temp+RS1BufCounter_temp+RS2BufCounter_temp+RS3BufCounter_temp;
					if(!InstrQueueBufEmpty3 && !ROBBufFull3 && InstrQueueCounter_temp>=3) begin
						if(InstrQueueHeadData3[31:26]==6'b100011) begin
							if(!RS2BufFull) begin
								InstrQueueRE_reg = 2'd3;
								RS2BufCounter_temp = RS2BufCounter_temp + 1;
							end
						end else if(InstrQueueHeadData3[31:26]==6'b101011) begin
							if(!RS3BufFull) begin
								InstrQueueRE_reg = 2'd3;
								RS3BufCounter_temp = RS3BufCounter_temp + 1;
							end
						end else if(InstrQueueHeadData3[31:26]==6'b000100 || InstrQueueHeadData3[31:26]==6'b000101) begin
							if(!RS0BufFull) begin
								if(!BranchStall) begin
									BranchStall = 1;
									InstrQueueRE_reg = 2'd3;
									RS0BufCounter_temp = RS0BufCounter_temp + 1;
								end
							end 
						end else if(RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
							if(!RS0BufFull) begin
								InstrQueueRE_reg = 2'd3;
								RS0BufCounter_temp = RS0BufCounter_temp + 1;
							end
						end else begin
							if(!RS1BufFull) begin
								InstrQueueRE_reg = 2'd3;
								RS1BufCounter_temp = RS1BufCounter_temp + 1;
							end
						end
						
					end
				end
			end
		end
		
		InstrQueueCounter_temp = RS0BufCounter_temp+RS1BufCounter_temp+RS2BufCounter_temp+RS3BufCounter_temp;
		if(InstrQueueCounter_temp>=1) begin
			InstrQueueRCLK_reg = 1;
			#1;
			InstrQueueRCLK_reg = 0;
			
			MappingTableWE_reg = InstrQueueCounter_temp;
			MappingTableWCLK_reg = 1;
			#1;
			MappingTableWCLK_reg = 0;
			
			RS0BufCounter_temp = 0;
			RS1BufCounter_temp = 0;
			RS2BufCounter_temp = 0;
			RS3BufCounter_temp = 0;
			RS0WCLK = 0;
			RS1WCLK = 0;
			RS2WCLK = 0;
			RS3WCLK = 0;
			ROBWE_reg = 2'd0;
			ROBWCLK_reg	= 0;
			ROBCounter_temp = 3'd0;
		
			if(Instr0[31:26]==6'b100011) begin
				if(RS2BufCounter_temp==0) begin
					RS2BufIn0 = RSEntry0;
					RS2WE = 2'd0;
				end else if(RS2BufCounter_temp==1) begin
					RS2BufIn1 = RSEntry0;
					RS2WE = 2'd1;
				end else if(RS2BufCounter_temp==2) begin
					RS2BufIn2 = RSEntry0;
					RS2WE = 2'd2;
				end else if(RS2BufCounter_temp==3) begin
					RS2BufIn3 = RSEntry0;
					RS2WE = 2'd3;
				end
				RS2BufCounter_temp = RS2BufCounter_temp + 1;
			end else if(Instr0[31:26]==6'b101011) begin
				if(RS3BufCounter_temp==0) begin
					RS3BufIn0 = RSEntry0;
					RS3WE = 2'd0;
				end else if(RS3BufCounter_temp==1) begin
					RS3BufIn1 = RSEntry0;
					RS3WE = 2'd1;
				end else if(RS3BufCounter_temp==2) begin
					RS3BufIn2 = RSEntry0;
					RS3WE = 2'd2;
				end else if(RS3BufCounter_temp==3) begin
					RS3BufIn3 = RSEntry0;
					RS3WE = 2'd3;
				end
				RS3BufCounter_temp = RS3BufCounter_temp + 1;
			end else if(Instr0[31:26]==6'b000100 || Instr0[31:26]==6'b000101 || RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
				if(RS0BufCounter_temp==0) begin
					RS0BufIn0 = RSEntry0;
					RS0WE = 2'd0;
				end else if(RS0BufCounter_temp==1) begin
					RS0BufIn1 = RSEntry0;
					RS0WE = 2'd1;
				end else if(RS0BufCounter_temp==2) begin
					RS0BufIn2 = RSEntry0;
					RS0WE = 2'd2;
				end else if(RS0BufCounter_temp==3) begin
					RS0BufIn3 = RSEntry0;
					RS0WE = 2'd3;
				end
				RS0BufCounter_temp = RS0BufCounter_temp + 1;
			end else begin
				if(RS1BufCounter_temp==0) begin
					RS1BufIn0 = RSEntry0;
					RS1WE = 2'd0;
				end else if(RS1BufCounter_temp==1) begin
					RS1BufIn1 = RSEntry0;
					RS1WE = 2'd1;
				end else if(RS1BufCounter_temp==2) begin
					RS1BufIn2 = RSEntry0;
					RS1WE = 2'd2;
				end else if(RS1BufCounter_temp==3) begin
					RS1BufIn3 = RSEntry0;
					RS1WE = 2'd3;
				end
				RS1BufCounter_temp = RS1BufCounter_temp + 1;
			end
			
			if(ROBEntryValid0==1) begin
				ROBBufIn_reg0 = ROBEntry0;
				ROBWE_reg = 2'd0;
				ROBCounter_temp = 3'd1;
			end
			
			if(InstrQueueCounter_temp>=2) begin
				if(Instr1[31:26]==6'b100011) begin
					if(RS2BufCounter_temp==0) begin
						RS2BufIn0 = RSEntry1;
						RS2WE = 2'd0;
					end else if(RS2BufCounter_temp==1) begin
						RS2BufIn1 = RSEntry1;
						RS2WE = 2'd1;
					end else if(RS2BufCounter_temp==2) begin
						RS2BufIn2 = RSEntry1;
						RS2WE = 2'd2;
					end else if(RS2BufCounter_temp==3) begin
						RS2BufIn3 = RSEntry1;
						RS2WE = 2'd3;
					end
					RS2BufCounter_temp = RS2BufCounter_temp + 1;
				end else if(Instr1[31:26]==6'b101011) begin
					if(RS3BufCounter_temp==0) begin
						RS3BufIn0 = RSEntry1;
						RS3WE = 2'd0;
					end else if(RS3BufCounter_temp==1) begin
						RS3BufIn1 = RSEntry1;
						RS3WE = 2'd1;
					end else if(RS3BufCounter_temp==2) begin
						RS3BufIn2 = RSEntry1;
						RS3WE = 2'd2;
					end else if(RS3BufCounter_temp==3) begin
						RS3BufIn3 = RSEntry1;
						RS3WE = 2'd3;
					end
					RS3BufCounter_temp = RS3BufCounter_temp + 1;
				end else if(Instr1[31:26]==6'b000100 || Instr1[31:26]==6'b000101 || RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
					if(RS0BufCounter_temp==0) begin
						RS0BufIn0 = RSEntry1;
						RS0WE = 2'd0;
					end else if(RS0BufCounter_temp==1) begin
						RS0BufIn1 = RSEntry1;
						RS0WE = 2'd1;
					end else if(RS0BufCounter_temp==2) begin
						RS0BufIn2 = RSEntry1;
						RS0WE = 2'd2;
					end else if(RS0BufCounter_temp==3) begin
						RS0BufIn3 = RSEntry1;
						RS0WE = 2'd3;
					end
					RS0BufCounter_temp = RS0BufCounter_temp + 1;
				end else begin
					if(RS1BufCounter_temp==0) begin
						RS1BufIn0 = RSEntry1;
						RS1WE = 2'd0;
					end else if(RS1BufCounter_temp==1) begin
						RS1BufIn1 = RSEntry1;
						RS1WE = 2'd1;
					end else if(RS1BufCounter_temp==2) begin
						RS1BufIn2 = RSEntry1;
						RS1WE = 2'd2;
					end else if(RS1BufCounter_temp==3) begin
						RS1BufIn3 = RSEntry1;
						RS1WE = 2'd3;
					end
					RS1BufCounter_temp = RS1BufCounter_temp + 1;
				end
				
				if(ROBEntryValid1==1) begin
					if(ROBCounter_temp==3'd0) begin
						ROBBufIn_reg0 = ROBEntry1;
						ROBWE_reg = 2'd0;
					end else if(ROBCounter_temp==3'd1) begin
						ROBBufIn_reg1 = ROBEntry1;
						ROBWE_reg = 2'd1;
					end
					ROBCounter_temp = ROBCounter_temp + 1;
				end
				
				if(InstrQueueCounter_temp>=3) begin
					if(Instr2[31:26]==6'b100011) begin
						if(RS2BufCounter_temp==0) begin
							RS2BufIn0 = RSEntry2;
							RS2WE = 2'd0;
						end else if(RS2BufCounter_temp==1) begin
							RS2BufIn1 = RSEntry2;
							RS2WE = 2'd1;
						end else if(RS2BufCounter_temp==2) begin
							RS2BufIn2 = RSEntry2;
							RS2WE = 2'd2;
						end else if(RS2BufCounter_temp==3) begin
							RS2BufIn3 = RSEntry2;
							RS2WE = 2'd3;
						end
						RS2BufCounter_temp = RS2BufCounter_temp + 1;
					end else if(Instr2[31:26]==6'b101011) begin
						if(RS3BufCounter_temp==0) begin
							RS3BufIn0 = RSEntry2;
							RS3WE = 2'd0;
						end else if(RS3BufCounter_temp==1) begin
							RS3BufIn1 = RSEntry2;
							RS3WE = 2'd1;
						end else if(RS3BufCounter_temp==2) begin
							RS3BufIn2 = RSEntry2;
							RS3WE = 2'd2;
						end else if(RS3BufCounter_temp==3) begin
							RS3BufIn3 = RSEntry2;
							RS3WE = 2'd3;
						end
						RS3BufCounter_temp = RS3BufCounter_temp + 1;
					end else if(Instr2[31:26]==6'b000100 || Instr2[31:26]==6'b000101 || RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
						if(RS0BufCounter_temp==0) begin
							RS0BufIn0 = RSEntry2;
							RS0WE = 2'd0;
						end else if(RS0BufCounter_temp==1) begin
							RS0BufIn1 = RSEntry2;
							RS0WE = 2'd1;
						end else if(RS0BufCounter_temp==2) begin
							RS0BufIn2 = RSEntry2;
							RS0WE = 2'd2;
						end else if(RS0BufCounter_temp==3) begin
							RS0BufIn3 = RSEntry2;
							RS0WE = 2'd3;
						end
						RS0BufCounter_temp = RS0BufCounter_temp + 1;
					end else begin
						if(RS1BufCounter_temp==0) begin
							RS1BufIn0 = RSEntry2;
							RS1WE = 2'd0;
						end else if(RS1BufCounter_temp==1) begin
							RS1BufIn1 = RSEntry2;
							RS1WE = 2'd1;
						end else if(RS1BufCounter_temp==2) begin
							RS1BufIn2 = RSEntry2;
							RS1WE = 2'd2;
						end else if(RS1BufCounter_temp==3) begin
							RS1BufIn3 = RSEntry2;
							RS1WE = 2'd3;
						end
						RS1BufCounter_temp = RS1BufCounter_temp + 1;
					end
					
					if(ROBEntryValid2==1) begin
						if(ROBCounter_temp==3'd0) begin
							ROBBufIn_reg0 = ROBEntry2;
							ROBWE_reg = 2'd0;
						end else if(ROBCounter_temp==3'd1) begin
							ROBBufIn_reg1 = ROBEntry2;
							ROBWE_reg = 2'd1;
						end else if(ROBCounter_temp==3'd2) begin
							ROBBufIn_reg2 = ROBEntry2;
							ROBWE_reg = 2'd2;
						end
						ROBCounter_temp = ROBCounter_temp + 1;
					end
					
					if(InstrQueueCounter_temp>=4) begin
						if(Instr3[31:26]==6'b100011) begin
							if(RS2BufCounter_temp==0) begin
								RS2BufIn0 = RSEntry3;
								RS2WE = 2'd0;
							end else if(RS2BufCounter_temp==1) begin
								RS2BufIn1 = RSEntry3;
								RS2WE = 2'd1;
							end else if(RS2BufCounter_temp==2) begin
								RS2BufIn2 = RSEntry3;
								RS2WE = 2'd2;
							end else if(RS2BufCounter_temp==3) begin
								RS2BufIn3 = RSEntry3;
								RS2WE = 2'd3;
							end
							RS2BufCounter_temp = RS2BufCounter_temp + 1;
						end else if(Instr3[31:26]==6'b101011) begin
							if(RS3BufCounter_temp==0) begin
								RS3BufIn0 = RSEntry3;
								RS3WE = 2'd0;
							end else if(RS3BufCounter_temp==1) begin
								RS3BufIn1 = RSEntry3;
								RS3WE = 2'd1;
							end else if(RS3BufCounter_temp==2) begin
								RS3BufIn2 = RSEntry3;
								RS3WE = 2'd2;
							end else if(RS3BufCounter_temp==3) begin
								RS3BufIn3 = RSEntry3;
								RS3WE = 2'd3;
							end
							RS3BufCounter_temp = RS3BufCounter_temp + 1;
						end else if(Instr3[31:26]==6'b000100 || Instr3[31:26]==6'b000101 || RS1BufCounter+RS1BufCounter_temp >= RS0BufCounter+RS0BufCounter_temp) begin
							if(RS0BufCounter_temp==0) begin
								RS0BufIn0 = RSEntry3;
								RS0WE = 2'd0;
							end else if(RS0BufCounter_temp==1) begin
								RS0BufIn1 = RSEntry3;
								RS0WE = 2'd1;
							end else if(RS0BufCounter_temp==2) begin
								RS0BufIn2 = RSEntry3;
								RS0WE = 2'd2;
							end else if(RS0BufCounter_temp==3) begin
								RS0BufIn3 = RSEntry3;
								RS0WE = 2'd3;
							end
							RS0BufCounter_temp = RS0BufCounter_temp + 1;
						end else begin
							if(RS1BufCounter_temp==0) begin
								RS1BufIn0 = RSEntry3;
								RS1WE = 2'd0;
							end else if(RS1BufCounter_temp==1) begin
								RS1BufIn1 = RSEntry3;
								RS1WE = 2'd1;
							end else if(RS1BufCounter_temp==2) begin
								RS1BufIn2 = RSEntry3;
								RS1WE = 2'd2;
							end else if(RS1BufCounter_temp==3) begin
								RS1BufIn3 = RSEntry3;
								RS1WE = 2'd3;
							end
							RS1BufCounter_temp = RS1BufCounter_temp + 1;
						end
						
						if(ROBEntryValid3==1) begin
							if(ROBCounter_temp==3'd0) begin
								ROBBufIn_reg0 = ROBEntry3;
								ROBWE_reg = 2'd0;
							end else if(ROBCounter_temp==3'd1) begin
								ROBBufIn_reg1 = ROBEntry3;
								ROBWE_reg = 2'd1;
							end else if(ROBCounter_temp==3'd2) begin
								ROBBufIn_reg2 = ROBEntry3;
								ROBWE_reg = 2'd2;
							end else if(ROBCounter_temp==3'd3) begin
								ROBBufIn_reg3 = ROBEntry3;
								ROBWE_reg = 2'd3;
							end
							ROBCounter_temp = ROBCounter_temp + 1;
						end
						
					end
				end
			end
		
			if(RS0BufCounter_temp>=1)
				RS0WCLK = 1;
			if(RS1BufCounter_temp>=1)
				RS1WCLK = 1;
			if(RS2BufCounter_temp>=1)
				RS2WCLK = 1;
			if(RS3BufCounter_temp>=1)
				RS3WCLK = 1;
			if(ROBCounter_temp>=1)
				ROBWCLK_reg = 1;
			#1;
			RS0WCLK = 0;
			RS1WCLK = 0;
			RS2WCLK = 0;
			RS3WCLK = 0;
			ROBWE_reg = 0;
			ROBWCLK_reg = 0;
			
		end
		
		if(InstrQueueHeadData0[31:26]==6'b000100 || InstrQueueHeadData0[31:26]==6'b000101) begin
			JumpPC = InstrQueueHeadPC;
			JumpRs = InstrQueueHeadData0[25:21];
			JumpRt = InstrQueueHeadData0[20:16];
			JumpImm = InstrQueueHeadData0[15:0];	
			if(JumpRs==JumpRt) begin
				JumpIssued = 1;
				JumpDest_reg = {{14{JumpImm[15]}}, JumpImm[15:0], 2'b00} + JumpPC;
			end
		end
		
	end

	always@(posedge BranchResolved) begin
		BranchStall = 0;
		if(JumpIssued)
			Jump_reg = 1;
	end
	
/****************************************************************************************/
/* 	Reservation Stations Decoders														*/
/****************************************************************************************/
	decoder decoder0(
		.Reset(Reset),
		.RSEntry(D0RSEntry),
		.CacheHit(D0CacheHit),
		.CacheData(D0CacheData),
		.ALUControl(D0ALUControl),
		.SrcA(D0SrcA), .SrcB(D0SrcB),
		.Dest(D0Dest),
		.Write(D0RegWrite),
		.Branch(D0Branch),
		.BranchResolved(D0BranchResolved),
		.BranchTag(D0BranchTag),
		.CacheRME(D0CacheRME),
		.CacheTag(D0CacheTag),
		.DataLoadCache(D0DataLoadCache),
		.DestLoadCache(D0DestLoadCache),
		.RegWriteLoadCache(D0RegWriteLoadCache));
	decoder decoder1(
		.Reset(Reset),
		.RSEntry(D1RSEntry),
		.CacheHit(D1CacheHit),
		.CacheData(D1CacheData),
		.ALUControl(D1ALUControl),
		.SrcA(D1SrcA), .SrcB(D1SrcB),
		.Dest(D1Dest),
		.Write(D1RegWrite),
		.Branch(D1Branch),
		.BranchResolved(D1BranchResolved),
		.BranchTag(D1BranchTag),
		.CacheRME(D1CacheRME),
		.CacheTag(D1CacheTag),
		.DataLoadCache(D1DataLoadCache),
		.DestLoadCache(D1DestLoadCache),
		.RegWriteLoadCache(D1RegWriteLoadCache));
	decoder decoder2(
		.Reset(Reset),
		.RSEntry(D2RSEntry),
		.CacheHit(D2CacheHit),
		.CacheData(D2CacheData),
		.ALUControl(D2ALUControl),
		.SrcA(D2SrcA), .SrcB(D2SrcB),
		.Dest(D2Dest),
		.Write(D2RegWrite),
		.Branch(D2Branch),
		.BranchResolved(D2BranchResolved),
		.BranchTag(D2BranchTag),
		.CacheRME(D2CacheRME),
		.CacheTag(D2CacheTag),
		.DataLoadCache(D2DataLoadCache),
		.DestLoadCache(D2DestLoadCache),
		.RegWriteLoadCache(D2RegWriteLoadCache));
	decoder decoder3(
		.Reset(Reset),
		.RSEntry(D3RSEntry),
		.CacheHit(D3CacheHit),
		.CacheData(D3CacheData),
		.ALUControl(D3ALUControl),
		.SrcA(D3SrcA), .SrcB(D3SrcB),
		.Dest(D3Data),
		.Write(D3MemWrite),
		.Branch(D3Branch),
		.BranchResolved(D3BranchResolved),
		.BranchTag(D3BranchTag),
		.CacheRME(D3CacheRME),
		.CacheTag(D3CacheTag),
		.DataLoadCache(D3DataLoadCache),
		.DestLoadCache(D3DestLoadCache),
		.RegWriteLoadCache(D3RegWriteLoadCache));
		
/****************************************************************************************/
/* 	Reservation Stations to Functional Units Logic										*/
/****************************************************************************************/
	always@(posedge CLK) begin
		D0RSEntry = 144'd0;
		D1RSEntry = 144'd0;
		D2RSEntry = 144'd0;
		D3RSEntry = 144'd0;
	end
	
	always@(negedge CLK) begin
		if(!RS2BufEmpty) begin
			if(!((RS2HeadFlagA&&ForwardFlag2A)||(RS2HeadFlagB&&ForwardFlag2B))) begin
				ForwardData2A_temp = ForwardData2A;
				ForwardData2B_temp = ForwardData2B;
				D2RSEntry[143:0] = RS2HeadElement;
				if(D2RSEntry[104]==1)
					D2RSEntry[103:72] = ForwardData2A_temp;
				if(D2RSEntry[71]==1)
					D2RSEntry[70:39] = ForwardData2B_temp;
				RS2RCLK = 1;
			end
		end
		#1;
		if(!RS3BufEmpty) begin
			if(!((RS3HeadFlagA&&ForwardFlag3A)||(RS3HeadFlagB&&ForwardFlag3B))) begin
				ForwardData3A_temp = ForwardData3A;
				ForwardData3B_temp = ForwardData3B;
				D3RSEntry[143:0] = RS3HeadElement;
				if(D3RSEntry[104]==1)
					D3RSEntry[103:72] = ForwardData3A_temp;
				if(D3RSEntry[71]==1)
					D3RSEntry[70:39] = ForwardData3B_temp;
				RS3RCLK = 1;
			end
		end
		if(!RS0BufEmpty) begin
			if(!((RS0HeadFlagA&&ForwardFlag0A)||(RS0HeadFlagB&&ForwardFlag0B))) begin
				ForwardData0A_temp = ForwardData0A;
				ForwardData0B_temp = ForwardData0B;
				D0RSEntry[143:0] = RS0HeadElement;
				if(D0RSEntry[104]==1)
					D0RSEntry[103:72] = ForwardData0A_temp;
				if(D0RSEntry[71]==1)
					D0RSEntry[70:39] = ForwardData0B_temp;
				RS0RCLK = 1;
			end
		end
		if(!RS1BufEmpty) begin
			if(!((RS1HeadFlagA&&ForwardFlag1A)||(RS1HeadFlagB&&ForwardFlag1B))) begin
				ForwardData1A_temp = ForwardData1A;
				ForwardData1B_temp = ForwardData1B;
				D1RSEntry[143:0] = RS1HeadElement;
				if(D1RSEntry[104]==1)
					D1RSEntry[103:72] = ForwardData1A_temp;
				if(D1RSEntry[71]==1)
					D1RSEntry[70:39] = ForwardData1B_temp;
				RS1RCLK = 1;
			end
		end
		#1;
		RS0RCLK = 0;
		RS1RCLK = 0;
		RS2RCLK = 0;
		RS3RCLK = 0;
	end
	
/****************************************************************************************/
/* 	Output Assignments																	*/
/****************************************************************************************/
	assign InstrQueueRE = InstrQueueRE_reg;
	assign InstrQueueRCLK = InstrQueueRCLK_reg;
	
	assign RS0BufFull = (RS0BufCounter_temp==0) ? RS0BufFull0 : (RS0BufCounter_temp==1) ? RS0BufFull1 : (RS0BufCounter_temp==2) ? RS0BufFull2 : RS0BufFull3;
	assign RS1BufFull = (RS1BufCounter_temp==0) ? RS1BufFull0 : (RS1BufCounter_temp==1) ? RS1BufFull1 : (RS1BufCounter_temp==2) ? RS1BufFull2 : RS1BufFull3;
	assign RS2BufFull = (RS2BufCounter_temp==0) ? RS2BufFull0 : (RS2BufCounter_temp==1) ? RS2BufFull1 : (RS2BufCounter_temp==2) ? RS2BufFull2 : RS2BufFull3;
	assign RS3BufFull = (RS3BufCounter_temp==0) ? RS3BufFull0 : (RS3BufCounter_temp==1) ? RS3BufFull1 : (RS3BufCounter_temp==2) ? RS3BufFull2 : RS3BufFull3;
	
	assign Branch = D0Branch || D1Branch;
	assign BranchResolved = D0BranchResolved || D1BranchResolved;
	assign BranchTag = 
		(D0BranchResolved) ? D0BranchTag :
		(D1BranchResolved) ? D1BranchTag : 32'd0;
	assign BranchDest =
		(D0Branch) ? D0Dest :
		(D1Branch) ? D1Dest : 32'd0;
		
	assign Jump = Jump_reg;
	assign JumpDest = JumpDest_reg;
	
	assign Instr0 = InstrQueueBufOut0;
	assign Instr1 = InstrQueueBufOut1;
	assign Instr2 = InstrQueueBufOut2;
	assign Instr3 = InstrQueueBufOut3;
	assign InstrROBTag = ROBTag;
	assign MappingTableWE = MappingTableWE_reg;
	assign MappingTableWCLK = MappingTableWCLK_reg;
	
	assign ROBBufIn0 = ROBBufIn_reg0;
	assign ROBBufIn1 = ROBBufIn_reg1;
	assign ROBBufIn2 = ROBBufIn_reg2;
	assign ROBBufIn3 = ROBBufIn_reg3;
	assign ROBWE = ROBWE_reg;
	assign ROBWCLK = ROBWCLK_reg;
	
	assign ForwardTag0A = RS0HeadDataA;
	assign ForwardTag0B = RS0HeadDataB;
	assign ForwardTag1A = RS1HeadDataA;
	assign ForwardTag1B = RS1HeadDataB;
	assign ForwardTag2A = RS2HeadDataA;
	assign ForwardTag2B = RS2HeadDataB;
	assign ForwardTag3A = RS3HeadDataA;
	assign ForwardTag3B = RS3HeadDataB;
		
	assign LoadCacheRFlag0A = ~(LoadCacheRTag0A==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag0B = ~(LoadCacheRTag0B==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag1A = ~(LoadCacheRTag1A==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag1B = ~(LoadCacheRTag1B==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag2A = ~(LoadCacheRTag2A==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag2B = ~(LoadCacheRTag2B==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag3A = ~(LoadCacheRTag3A==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	assign LoadCacheRFlag3B = ~(LoadCacheRTag3B==D2DestLoadCache && D2RegWriteLoadCache==1'b1);
	
	assign LoadCacheRData0A = (~LoadCacheRFlag0A) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData0B = (~LoadCacheRFlag0B) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData1A = (~LoadCacheRFlag1A) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData1B = (~LoadCacheRFlag1B) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData2A = (~LoadCacheRFlag2A) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData2B = (~LoadCacheRFlag2B) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData3A = (~LoadCacheRFlag3A) ? D2DataLoadCache : 32'd0;
	assign LoadCacheRData3B = (~LoadCacheRFlag3B) ? D2DataLoadCache : 32'd0;
	
endmodule
