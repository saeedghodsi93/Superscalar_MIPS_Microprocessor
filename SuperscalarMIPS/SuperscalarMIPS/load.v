
`timescale 1ns/1ns

module load(
	input 			CLK,
	input			Reset,
	input  [31:0]	A,
	input  [31:0]	Dest,
	input			RegWrite,
	input  [31:0]	DataMem_RD,
	input  [31:0]	LoadRTag0A, LoadRTag0B, LoadRTag1A, LoadRTag1B, LoadRTag2A, LoadRTag2B, LoadRTag3A, LoadRTag3B,
	output [31:0]	DataMem_RA,
	output [31:0]	DataLoad,
	output [31:0]	DestLoad,
	output			RegWriteLoad,
	output [31:0]	LoadRData0A, LoadRData0B, LoadRData1A, LoadRData1B, LoadRData2A, LoadRData2B, LoadRData3A, LoadRData3B,
	output			LoadRFlag0A, LoadRFlag0B, LoadRFlag1A, LoadRFlag1B, LoadRFlag2A, LoadRFlag2B, LoadRFlag3A, LoadRFlag3B);
	
/****************************************************************************************/
/* 	Output Assignments																	*/
/****************************************************************************************/
	assign DataMem_RA = A;
	assign DataLoad = DataMem_RD;
	assign DestLoad = Dest;
	assign RegWriteLoad = RegWrite;
	
	assign LoadRFlag0A = ~(LoadRTag0A==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag0B = ~(LoadRTag0B==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag1A = ~(LoadRTag1A==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag1B = ~(LoadRTag1B==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag2A = ~(LoadRTag2A==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag2B = ~(LoadRTag2B==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag3A = ~(LoadRTag3A==DestLoad && RegWriteLoad==1'b1);
	assign LoadRFlag3B = ~(LoadRTag3B==DestLoad && RegWriteLoad==1'b1);
	
	assign LoadRData0A = (~LoadRFlag0A) ? DataLoad : 32'd0;
	assign LoadRData0B = (~LoadRFlag0B) ? DataLoad : 32'd0;
	assign LoadRData1A = (~LoadRFlag1A) ? DataLoad : 32'd0;
	assign LoadRData1B = (~LoadRFlag1B) ? DataLoad : 32'd0;
	assign LoadRData2A = (~LoadRFlag2A) ? DataLoad : 32'd0;
	assign LoadRData2B = (~LoadRFlag2B) ? DataLoad : 32'd0;
	assign LoadRData3A = (~LoadRFlag3A) ? DataLoad : 32'd0;
	assign LoadRData3B = (~LoadRFlag3B) ? DataLoad : 32'd0;
	
endmodule
