
`timescale 1ns/1ns

module writeback(
	input 			CLK,
	input			Reset,
	input  [1:0]	ROBWE,
	input			ROBWCLK,
	input  [69:0]	ROBBufIn0, ROBBufIn1, ROBBufIn2, ROBBufIn3,
	input  [31:0]	ALUOut0, ALUOut1, Data2, DataCache,
	input  [31:0]	Dest0, Dest1, Dest2, DestCache,
	input			RegWrite0, RegWrite1, RegWrite2, RegWriteCache,
	input  [31:0]	ROBRTag0A, ROBRTag0B, ROBRTag1A, ROBRTag1B, ROBRTag2A, ROBRTag2B, ROBRTag3A, ROBRTag3B,
	input			Branch, BranchResolved,
	input  [31:0]	BranchTag,
	output 			ROBBufFull0, ROBBufFull1, ROBBufFull2, ROBBufFull3,
	output [31:0]	ROBTag,
	output [4:0]	RegFileWA1, RegFileWA2,
	output [31:0]	RegFileWD1, RegFileWD2,
	output			RegFileWE1, RegFileWE2,
	output [31:0]	RegFileWD1Tag, RegFileWD2Tag,
	output [31:0]	ROBRData0A, ROBRData0B, ROBRData1A, ROBRData1B, ROBRData2A, ROBRData2B, ROBRData3A, ROBRData3B,
	output			ROBRFlag0A, ROBRFlag0B, ROBRFlag1A, ROBRFlag1B, ROBRFlag2A, ROBRFlag2B, ROBRFlag3A, ROBRFlag3B);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	reg    [1:0]	ROBRE;
	reg				ROBRCLK;
	wire   [69:0]	ROBBufOut0, ROBBufOut1;
	wire			ROBBufEmpty0, ROBBufEmpty1;
	reg    [31:0]	ROBTag_reg;

	wire  [31:0]	ParaRData0A, ParaRData0B, ParaRData1A, ParaRData1B, ParaRData2A, ParaRData2B, ParaRData3A, ParaRData3B;
	wire			ParaRFlag0A, ParaRFlag0B, ParaRFlag1A, ParaRFlag1B, ParaRFlag2A, ParaRFlag2B, ParaRFlag3A, ParaRFlag3B;

	wire			WCLK0, WCLK1, WCLK2, WCLK3;
	wire			HeadFlag0, HeadFlag1, HeadZero0, HeadZero1;
	
	reg    [4:0]	RegFileWA1_reg, RegFileWA2_reg;
	reg    [31:0]	RegFileWD1_reg, RegFileWD2_reg;
	reg				RegFileWE1_reg, RegFileWE2_reg;
	reg    [31:0]	RegFileWD1Tag_reg, RegFileWD2Tag_reg;
	
/****************************************************************************************/
/* 	Reset																				*/
/****************************************************************************************/
	always@(Reset) begin
		ROBTag_reg = 32'd0;
		ROBRCLK = 0;
		RegFileWA1_reg = 5'd0;
		RegFileWD1_reg = 32'd0;
		RegFileWE1_reg = 0;
		RegFileWD1Tag_reg = 32'd0;
	end
	
/****************************************************************************************/
/* 	Reorder Buffer																		*/
/****************************************************************************************/
	rob #(.DATA_WIDTH(70), .ADDR_WIDTH(5)) ROB(
		.clk(CLK), .wclk(ROBWCLK), .rclk(ROBRCLK), .rst(Reset), .we(ROBWE), .re(ROBRE),
		.buf_in0(ROBBufIn0), .buf_in1(ROBBufIn1), .buf_in2(ROBBufIn2), .buf_in3(ROBBufIn3), .buf_out0(ROBBufOut0), .buf_out1(ROBBufOut1),
		.head_element_flag0(HeadFlag0), .head_element_flag1(HeadFlag1), .head_element_zero0(HeadZero0), .head_element_zero1(HeadZero1),
		.buf_empty0(ROBBufEmpty0), .buf_empty1(ROBBufEmpty1), .buf_full0(ROBBufFull0), .buf_full1(ROBBufFull1), .buf_full2(ROBBufFull2), .buf_full3(ROBBufFull3),
		.para_wd0(ALUOut0), .para_wd1(ALUOut1), .para_wd2(Data2), .para_wd3(DataCache),
		.para_wt0(Dest0), .para_wt1(Dest1), .para_wt2(Dest2), .para_wt3(DestCache),
		.branch(Branch), .branch_resolved(BranchResolved), .branch_tag(BranchTag),
		.para_rt0A(ROBRTag0A), .para_rt0B(ROBRTag0B), .para_rt1A(ROBRTag1A), .para_rt1B(ROBRTag1B), .para_rt2A(ROBRTag2A), .para_rt2B(ROBRTag2B), .para_rt3A(ROBRTag3A), .para_rt3B(ROBRTag3B),
		.para_wclk0(WCLK0), .para_wclk1(WCLK1), .para_wclk2(WCLK2), .para_wclk3(WCLK3),
		.para_rd0A(ParaRData0A), .para_rd0B(ParaRData0B), .para_rd1A(ParaRData1A), .para_rd1B(ParaRData1B), .para_rd2A(ParaRData2A), .para_rd2B(ParaRData2B), .para_rd3A(ParaRData3A), .para_rd3B(ParaRData3B),
		.para_rf0A(ParaRFlag0A), .para_rf0B(ParaRFlag0B), .para_rf1A(ParaRFlag1A), .para_rf1B(ParaRFlag1B), .para_rf2A(ParaRFlag2A), .para_rf2B(ParaRFlag2B), .para_rf3A(ParaRFlag3A), .para_rf3B(ParaRFlag3B));

/****************************************************************************************/
/* 	Update Tag, when Adding Instructions												*/
/****************************************************************************************/
	always@(posedge ROBWCLK) begin
		ROBTag_reg = ROBTag_reg + 32'd1 + ROBWE;
		
	end

/****************************************************************************************/
/* 	Write to Register File																*/
/****************************************************************************************/
	always@(posedge CLK) begin
		RegFileWE1_reg = 0;
		RegFileWE2_reg = 0;
		if(HeadZero1==1'b1) begin
			ROBRE = 2'd1;
			ROBRCLK = 1;
			#1;
			ROBRCLK = 0;
		end else if(HeadZero0==1'b1) begin
			ROBRE = 2'd0;
			ROBRCLK = 1;
			#1;
			ROBRCLK = 0;
		end
		#1;
		if(!ROBBufEmpty1 && HeadFlag0==0 && HeadFlag1==0) begin
			ROBRE = 2'd1;
			ROBRCLK = 1;
			#1;
			ROBRCLK = 0;
			RegFileWD1Tag_reg = ROBBufOut0[68:37];
			RegFileWA1_reg = ROBBufOut0[36:32];
			RegFileWD1_reg = ROBBufOut0[31:0];
			RegFileWD2Tag_reg = ROBBufOut1[68:37];
			RegFileWA2_reg = ROBBufOut1[36:32];
			RegFileWD2_reg = ROBBufOut1[31:0];
			RegFileWE1_reg = 1;
			RegFileWE2_reg = 1;
		end else if(!ROBBufEmpty0 && HeadFlag0==0) begin
			ROBRE = 2'd0;
			ROBRCLK = 1;
			#1;
			ROBRCLK = 0;
			RegFileWD2Tag_reg = ROBBufOut0[68:37];
			RegFileWA2_reg = ROBBufOut0[36:32];
			RegFileWD2_reg = ROBBufOut0[31:0];
			RegFileWE2_reg = 1;
		end

	end
		
/****************************************************************************************/
/* 	Output Assignments																	*/
/****************************************************************************************/
	assign ROBTag = ROBTag_reg;
	assign WCLK0 = RegWrite0;
	assign WCLK1 = RegWrite1;
	assign WCLK2 = RegWrite2;
	assign WCLK3 = RegWriteCache;
	
	assign RegFileWA1 = RegFileWA1_reg;
	assign RegFileWA2 = RegFileWA2_reg;
	assign RegFileWD1 = RegFileWD1_reg;
	assign RegFileWD2 = RegFileWD2_reg;
	assign RegFileWE1 = RegFileWE1_reg;
	assign RegFileWE2 = RegFileWE2_reg;
	assign RegFileWD1Tag = RegFileWD1Tag_reg;
	assign RegFileWD2Tag = RegFileWD2Tag_reg;
	
	assign ROBRFlag0A = ~((ROBRTag0A==Dest0 && RegWrite0==1'b1) || (ROBRTag0A==Dest1 && RegWrite1==1'b1) || (ROBRTag0A==Dest2 && RegWrite2==1'b1) || (ROBRTag0A==DestCache && RegWriteCache==1'b1) || !ParaRFlag0A);
	assign ROBRFlag0B = ~((ROBRTag0B==Dest0 && RegWrite0==1'b1) || (ROBRTag0B==Dest1 && RegWrite1==1'b1) || (ROBRTag0B==Dest2 && RegWrite2==1'b1) || (ROBRTag0B==DestCache && RegWriteCache==1'b1) || !ParaRFlag0B);
	assign ROBRFlag1A = ~((ROBRTag1A==Dest0 && RegWrite0==1'b1) || (ROBRTag1A==Dest1 && RegWrite1==1'b1) || (ROBRTag1A==Dest2 && RegWrite2==1'b1) || (ROBRTag1A==DestCache && RegWriteCache==1'b1) || !ParaRFlag1A);
	assign ROBRFlag1B = ~((ROBRTag1B==Dest0 && RegWrite0==1'b1) || (ROBRTag1B==Dest1 && RegWrite1==1'b1) || (ROBRTag1B==Dest2 && RegWrite2==1'b1) || (ROBRTag1B==DestCache && RegWriteCache==1'b1) || !ParaRFlag1B);
	assign ROBRFlag2A = ~((ROBRTag2A==Dest0 && RegWrite0==1'b1) || (ROBRTag2A==Dest1 && RegWrite1==1'b1) || (ROBRTag2A==Dest2 && RegWrite2==1'b1) || (ROBRTag2A==DestCache && RegWriteCache==1'b1) || !ParaRFlag2A);
	assign ROBRFlag2B = ~((ROBRTag2B==Dest0 && RegWrite0==1'b1) || (ROBRTag2B==Dest1 && RegWrite1==1'b1) || (ROBRTag2B==Dest2 && RegWrite2==1'b1) || (ROBRTag2B==DestCache && RegWriteCache==1'b1) || !ParaRFlag2B);
	assign ROBRFlag3A = ~((ROBRTag3A==Dest0 && RegWrite0==1'b1) || (ROBRTag3A==Dest1 && RegWrite1==1'b1) || (ROBRTag3A==Dest2 && RegWrite2==1'b1) || (ROBRTag3A==DestCache && RegWriteCache==1'b1) || !ParaRFlag3A);
	assign ROBRFlag3B = ~((ROBRTag3B==Dest0 && RegWrite0==1'b1) || (ROBRTag3B==Dest1 && RegWrite1==1'b1) || (ROBRTag3B==Dest2 && RegWrite2==1'b1) || (ROBRTag3B==DestCache && RegWriteCache==1'b1) || !ParaRFlag3B);
	
	assign ROBRData0A = (ROBRTag0A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag0A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag0A==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag0A==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag0A==1'b0) ? ParaRData0A : 32'd0;
	assign ROBRData0B = (ROBRTag0B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag0B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag0B==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag0B==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag0B==1'b0) ? ParaRData0B : 32'd0;
	assign ROBRData1A = (ROBRTag1A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag1A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag1A==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag1A==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag1A==1'b0) ? ParaRData1A : 32'd0;
	assign ROBRData1B = (ROBRTag1B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag1B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag1B==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag1B==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag1B==1'b0) ? ParaRData1B : 32'd0;
	assign ROBRData2A = (ROBRTag2A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag2A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag2A==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag2A==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag2A==1'b0) ? ParaRData2A : 32'd0;
	assign ROBRData2B = (ROBRTag2B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag2B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag2B==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag2B==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag2B==1'b0) ? ParaRData2B : 32'd0;
	assign ROBRData3A = (ROBRTag3A==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag3A==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag3A==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag3A==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag3A==1'b0) ? ParaRData3A : 32'd0;
	assign ROBRData3B = (ROBRTag3B==Dest0 && RegWrite0==1'b1) ? ALUOut0 : (ROBRTag3B==Dest1 && RegWrite1==1'b1) ? ALUOut1 : (ROBRTag3B==Dest2 && RegWrite2==1'b1) ? Data2 : (ROBRTag3B==DestCache && RegWriteCache==1'b1) ? DataCache : (ParaRFlag3B==1'b0) ? ParaRData3B : 32'd0;
	
endmodule
