module reservation_station(
	input			Reset,
	input  [143:0]	RSBufIn0, RSBufIn1, RSBufIn2, RSBufIn3,
	input  [1:0]	RSWE,
	input			RSWCLK,
	input			RSRCLK,
	input			Branch,
	input  [31:0]	BranchTag,
	output [143:0]	RSBufOut,
	output			RSHeadFlagA, RSHeadFlagB,
	output [31:0]	RSHeadDataA, RSHeadDataB,
	output [143:0]	RSHeadElement,
	output			RSBufEmpty,
	output 			RSBufFull0, RSBufFull1, RSBufFull2, RSBufFull3,
	output [3:0]	RSBufCounter);
	
/****************************************************************************************/
/* 	RS Logic																			*/
/****************************************************************************************/
	rs #(.DATA_WIDTH(144), .ADDR_WIDTH(3)) rs(
		.wclk(RSWCLK), .rclk(RSRCLK), .rst(Reset), .we(RSWE),
		.buf_in0(RSBufIn0), .buf_in1(RSBufIn1), .buf_in2(RSBufIn2), .buf_in3(RSBufIn3), .buf_out(RSBufOut),
		.branch(Branch), .branch_tag(BranchTag),
		.head_element_flag_a(RSHeadFlagA), .head_element_flag_b(RSHeadFlagB), .head_element_data_a(RSHeadDataA), .head_element_data_b(RSHeadDataB), .head_element(RSHeadElement),
		.buf_empty(RSBufEmpty), .buf_full0(RSBufFull0), .buf_full1(RSBufFull1), .buf_full2(RSBufFull2), .buf_full3(RSBufFull3), .fifo_counter(RSBufCounter));
	
endmodule
