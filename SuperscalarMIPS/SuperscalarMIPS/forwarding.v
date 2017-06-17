
`timescale 1ns/1ns

module forwarding(
	input   [31:0]	ForwardTag0A, ForwardTag0B, ForwardTag1A, ForwardTag1B, ForwardTag2A, ForwardTag2B, ForwardTag3A, ForwardTag3B,
	input   [31:0]	ALURData0A, ALURData0B, ALURData1A, ALURData1B, ALURData2A, ALURData2B, ALURData3A, ALURData3B,
	input			ALURFlag0A, ALURFlag0B, ALURFlag1A, ALURFlag1B, ALURFlag2A, ALURFlag2B, ALURFlag3A, ALURFlag3B,
	input   [31:0]	LoadRData0A, LoadRData0B, LoadRData1A, LoadRData1B, LoadRData2A, LoadRData2B, LoadRData3A, LoadRData3B,
	input			LoadRFlag0A, LoadRFlag0B, LoadRFlag1A, LoadRFlag1B, LoadRFlag2A, LoadRFlag2B, LoadRFlag3A, LoadRFlag3B,
	input   [31:0]	LoadCacheRData0A, LoadCacheRData0B, LoadCacheRData1A, LoadCacheRData1B, LoadCacheRData2A, LoadCacheRData2B, LoadCacheRData3A, LoadCacheRData3B,
	input			LoadCacheRFlag0A, LoadCacheRFlag0B, LoadCacheRFlag1A, LoadCacheRFlag1B, LoadCacheRFlag2A, LoadCacheRFlag2B, LoadCacheRFlag3A, LoadCacheRFlag3B,
	input   [31:0]	ROBRData0A, ROBRData0B, ROBRData1A, ROBRData1B, ROBRData2A, ROBRData2B, ROBRData3A, ROBRData3B,
	input			ROBRFlag0A, ROBRFlag0B, ROBRFlag1A, ROBRFlag1B, ROBRFlag2A, ROBRFlag2B, ROBRFlag3A, ROBRFlag3B,
	output  [31:0]	ForwardData0A, ForwardData0B, ForwardData1A, ForwardData1B, ForwardData2A, ForwardData2B, ForwardData3A, ForwardData3B,
	output			ForwardFlag0A, ForwardFlag0B, ForwardFlag1A, ForwardFlag1B, ForwardFlag2A, ForwardFlag2B, ForwardFlag3A, ForwardFlag3B,
	output  [31:0]	ALURTag0A, ALURTag0B, ALURTag1A, ALURTag1B, ALURTag2A, ALURTag2B, ALURTag3A, ALURTag3B,
	output  [31:0]	LoadRTag0A, LoadRTag0B, LoadRTag1A, LoadRTag1B, LoadRTag2A, LoadRTag2B, LoadRTag3A, LoadRTag3B,
	output  [31:0]	LoadCacheRTag0A, LoadCacheRTag0B, LoadCacheRTag1A, LoadCacheRTag1B, LoadCacheRTag2A, LoadCacheRTag2B, LoadCacheRTag3A, LoadCacheRTag3B,
	output  [31:0]	ROBRTag0A, ROBRTag0B, ROBRTag1A, ROBRTag1B, ROBRTag2A, ROBRTag2B, ROBRTag3A, ROBRTag3B);
	
/****************************************************************************************/
/* 	Data Forwarding Logic																*/
/****************************************************************************************/
	assign ALURTag0A = ForwardTag0A;
	assign ALURTag0B = ForwardTag0B;
	assign ALURTag1A = ForwardTag1A;
	assign ALURTag1B = ForwardTag1B;
	assign ALURTag2A = ForwardTag2A;
	assign ALURTag2B = ForwardTag2B;
	assign ALURTag3A = ForwardTag3A;
	assign ALURTag3B = ForwardTag3B;
	
	assign LoadRTag0A = ForwardTag0A;
	assign LoadRTag0B = ForwardTag0B;
	assign LoadRTag1A = ForwardTag1A;
	assign LoadRTag1B = ForwardTag1B;
	assign LoadRTag2A = ForwardTag2A;
	assign LoadRTag2B = ForwardTag2B;
	assign LoadRTag3A = ForwardTag3A;
	assign LoadRTag3B = ForwardTag3B;
	
	assign LoadCacheRTag0A = ForwardTag0A;
	assign LoadCacheRTag0B = ForwardTag0B;
	assign LoadCacheRTag1A = ForwardTag1A;
	assign LoadCacheRTag1B = ForwardTag1B;
	assign LoadCacheRTag2A = ForwardTag2A;
	assign LoadCacheRTag2B = ForwardTag2B;
	assign LoadCacheRTag3A = ForwardTag3A;
	assign LoadCacheRTag3B = ForwardTag3B;
	
	assign ROBRTag0A = ForwardTag0A;
	assign ROBRTag0B = ForwardTag0B;
	assign ROBRTag1A = ForwardTag1A;
	assign ROBRTag1B = ForwardTag1B;
	assign ROBRTag2A = ForwardTag2A;
	assign ROBRTag2B = ForwardTag2B;
	assign ROBRTag3A = ForwardTag3A;
	assign ROBRTag3B = ForwardTag3B;
	
	assign ForwardFlag0A = ALURFlag0A && LoadRFlag0A && LoadCacheRFlag0A && ROBRFlag0A;
	assign ForwardFlag0B = ALURFlag0B && LoadRFlag0B && LoadCacheRFlag0B && ROBRFlag0B;
	assign ForwardFlag1A = ALURFlag1A && LoadRFlag1A && LoadCacheRFlag1A && ROBRFlag1A;
	assign ForwardFlag1B = ALURFlag1B && LoadRFlag1B && LoadCacheRFlag1B && ROBRFlag1B;
	assign ForwardFlag2A = ALURFlag2A && LoadRFlag2A && LoadCacheRFlag2A && ROBRFlag2A;
	assign ForwardFlag2B = ALURFlag2B && LoadRFlag2B && LoadCacheRFlag2B && ROBRFlag2B;
	assign ForwardFlag3A = ALURFlag3A && LoadRFlag3A && LoadCacheRFlag3A && ROBRFlag3A;
	assign ForwardFlag3B = ALURFlag3B && LoadRFlag3B && LoadCacheRFlag3B && ROBRFlag3B;
	
	assign ForwardData0A = (!ALURFlag0A ? ALURData0A : (!LoadRFlag0A ? LoadRData0A : (!LoadCacheRFlag0A ? LoadCacheRData0A : (!ROBRFlag0A ? ROBRData0A : 32'd0))));
	assign ForwardData0B = (!ALURFlag0B ? ALURData0B : (!LoadRFlag0B ? LoadRData0B : (!LoadCacheRFlag0B ? LoadCacheRData0B : (!ROBRFlag0B ? ROBRData0B : 32'd0))));
	assign ForwardData1A = (!ALURFlag1A ? ALURData1A : (!LoadRFlag1A ? LoadRData1A : (!LoadCacheRFlag1A ? LoadCacheRData1A : (!ROBRFlag1A ? ROBRData1A : 32'd0))));
	assign ForwardData1B = (!ALURFlag1B ? ALURData1B : (!LoadRFlag1B ? LoadRData1B : (!LoadCacheRFlag1B ? LoadCacheRData1B : (!ROBRFlag1B ? ROBRData1B : 32'd0))));
	assign ForwardData2A = (!ALURFlag2A ? ALURData2A : (!LoadRFlag2A ? LoadRData2A : (!LoadCacheRFlag2A ? LoadCacheRData2A : (!ROBRFlag2A ? ROBRData2A : 32'd0))));
	assign ForwardData2B = (!ALURFlag2B ? ALURData2B : (!LoadRFlag2B ? LoadRData2B : (!LoadCacheRFlag2B ? LoadCacheRData2B : (!ROBRFlag2B ? ROBRData2B : 32'd0))));
	assign ForwardData3A = (!ALURFlag3A ? ALURData3A : (!LoadRFlag3A ? LoadRData3A : (!LoadCacheRFlag3A ? LoadCacheRData3A : (!ROBRFlag3A ? ROBRData3A : 32'd0))));
	assign ForwardData3B = (!ALURFlag3B ? ALURData3B : (!LoadRFlag3B ? LoadRData3B : (!LoadCacheRFlag3B ? LoadCacheRData3B : (!ROBRFlag3B ? ROBRData3B : 32'd0))));

endmodule
