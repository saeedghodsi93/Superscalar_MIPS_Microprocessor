
`timescale 1ns/1ns

module fetch(
	input 			CLK,
	input			Reset,
	input  [31:0]	RDF0, RDF1, RDF2, RDF3,
	input  [31:0]	JumpRDF0, JumpRDF1, JumpRDF2, JumpRDF3,
	input  [1:0]	InstrQueueRE,
	input			InstrQueueRCLK,
	input			Branch,
	input  [31:0]	BranchDest,
	input			Jump,
	input  [31:0]	JumpDest,
	output [63:0]	InstrQueueBufOut0, InstrQueueBufOut1, InstrQueueBufOut2, InstrQueueBufOut3,
	output [31:0]	InstrQueueHeadData0, InstrQueueHeadData1, InstrQueueHeadData2, InstrQueueHeadData3, InstrQueueHeadPC,
	output 			InstrQueueBufEmpty0, InstrQueueBufEmpty1, InstrQueueBufEmpty2, InstrQueueBufEmpty3,
	output [31:0]	AF, JumpAF);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	wire			InstrValid0, InstrValid1, InstrValid2, InstrValid3;
	wire			JumpInstrValid0, JumpInstrValid1, JumpInstrValid2, JumpInstrValid3;
	
	wire   [1:0]	InstrQueueWE;
	wire   [63:0]	InstrQueueBufIn0, InstrQueueBufIn1, InstrQueueBufIn2, InstrQueueBufIn3;
	wire			InstrQueueWCLK;
	wire   [5:0]	InstrQueueBufCounter;
	reg    [1:0]	InstrQueueWE_reg;
	reg    [63:0]	InstrQueueBufIn0_reg, InstrQueueBufIn1_reg, InstrQueueBufIn2_reg, InstrQueueBufIn3_reg;
	reg				InstrQueueWCLK_reg;
	
	reg    [31:0] 	TempPC, PC;
	wire   [31:0]	PCF;
	wire   [31:0] 	InstrF0, InstrF1, InstrF2, InstrF3;
	wire   [31:0]	JumpInstrF0, JumpInstrF1, JumpInstrF2, JumpInstrF3;

/****************************************************************************************/
/* 	Reset																				*/
/****************************************************************************************/
	always@(Reset) begin
		InstrQueueWE_reg = 0;
		InstrQueueBufIn0_reg = 0;
		InstrQueueBufIn1_reg = 0;
		InstrQueueBufIn2_reg = 0;
		InstrQueueBufIn3_reg = 0;
		InstrQueueWCLK_reg = 0;
		
	end

/****************************************************************************************/
/* 	Instruction Queue																	*/
/****************************************************************************************/
	fifo #(.DATA_WIDTH(64), .ADDR_WIDTH(5)) InstrQueue(
		.wclk(InstrQueueWCLK), .rclk(InstrQueueRCLK), .rst(Reset), .flush(Flush), .we(InstrQueueWE), .re(InstrQueueRE),
		.buf_in0(InstrQueueBufIn0), .buf_in1(InstrQueueBufIn1), .buf_in2(InstrQueueBufIn2), .buf_in3(InstrQueueBufIn3),
		.buf_out0(InstrQueueBufOut0), .buf_out1(InstrQueueBufOut1), .buf_out2(InstrQueueBufOut2), .buf_out3(InstrQueueBufOut3),
		.head_element_data0(InstrQueueHeadData0), .head_element_data1(InstrQueueHeadData1), .head_element_data2(InstrQueueHeadData2), .head_element_data3(InstrQueueHeadData3), .head_element_pc(InstrQueueHeadPC),
		.buf_empty0(InstrQueueBufEmpty0), .buf_empty1(InstrQueueBufEmpty1), .buf_empty2(InstrQueueBufEmpty2), .buf_empty3(InstrQueueBufEmpty3), .buf_full(InstrQueueBufFull), .fifo_counter(InstrQueueBufCounter));	

/****************************************************************************************/
/* 	Fetch																				*/
/****************************************************************************************/
	always@(posedge CLK) begin
		
		if(Reset)
			PC = 0;
		else begin
			if(!InstrQueueBufFull) begin
				if(InstrValid0) begin
					InstrQueueBufIn0_reg = {PCF+32'd4,InstrF0};
					TempPC = PCF + 32'd4;
					InstrQueueWE_reg = 2'd0;
				end
				if(InstrValid1) begin
					InstrQueueBufIn1_reg = {PCF+32'd8,InstrF1};
					TempPC = PCF + 32'd8;
					InstrQueueWE_reg = 2'd1;
				end
				if(InstrValid2) begin
					InstrQueueBufIn2_reg = {PCF+32'd12,InstrF2};
					TempPC = PCF + 32'd12;
					InstrQueueWE_reg = 2'd2;
				end
				if(InstrValid3) begin
					InstrQueueBufIn3_reg = {PCF+32'd16,InstrF3};
					TempPC = PCF + 32'd16;
					InstrQueueWE_reg = 2'd3;
				end
				PC = TempPC;
				InstrQueueWCLK_reg = 1;
				#1;
				InstrQueueWCLK_reg = 0;
			end
		end
	end

/****************************************************************************************/
/* 	Jump																				*/
/****************************************************************************************/
	always@(posedge Jump) begin
	
		if(!Branch) begin
			#1;
			if(!InstrQueueBufFull) begin
				if(JumpInstrValid0) begin
					InstrQueueBufIn0_reg = {JumpDest+32'd4,JumpInstrF0};
					TempPC = JumpDest + 32'd4;
					InstrQueueWE_reg = 2'd0;
				end
				if(JumpInstrValid1) begin
					InstrQueueBufIn1_reg = {JumpDest+32'd8,JumpInstrF1};
					TempPC = JumpDest + 32'd8;
					InstrQueueWE_reg = 2'd1;
				end
				if(JumpInstrValid2) begin
					InstrQueueBufIn2_reg = {JumpDest+32'd12,JumpInstrF2};
					TempPC = JumpDest + 32'd12;
					InstrQueueWE_reg = 2'd2;
				end
				if(JumpInstrValid3) begin
					InstrQueueBufIn3_reg = {JumpDest+32'd16,JumpInstrF3};
					TempPC = JumpDest + 32'd16;
					InstrQueueWE_reg = 2'd3;
				end
				PC = TempPC;
				InstrQueueWCLK_reg = 1;
				#1;
				InstrQueueWCLK_reg = 0;
			end
		end
		
	end
	
/****************************************************************************************/
/* 	Output Assignment																	*/
/****************************************************************************************/
	assign AF = PCF;
	assign JumpAF = JumpDest;
	assign InstrF0 = RDF0;
	assign InstrF1 = RDF1;
	assign InstrF2 = RDF2;
	assign InstrF3 = RDF3;
	assign JumpInstrF0 = JumpRDF0;
	assign JumpInstrF1 = JumpRDF1;
	assign JumpInstrF2 = JumpRDF2;
	assign JumpInstrF3 = JumpRDF3;
	assign Flush = Branch || Jump;
	assign PCF = Branch ? BranchDest : PC;
	
	assign InstrValid0 = !(InstrF0===32'dx);
	assign InstrValid1 = !(InstrF1===32'dx);
	assign InstrValid2 = !(InstrF2===32'dx);
	assign InstrValid3 = !(InstrF3===32'dx);
	assign JumpInstrValid0 = !(JumpInstrF0===32'dx);
	assign JumpInstrValid1 = !(JumpInstrF1===32'dx);
	assign JumpInstrValid2 = !(JumpInstrF2===32'dx);
	assign JumpInstrValid3 = !(JumpInstrF3===32'dx);
	assign InstrQueueWE = InstrQueueWE_reg;
	assign InstrQueueBufIn0 = InstrQueueBufIn0_reg;
	assign InstrQueueBufIn1 = InstrQueueBufIn1_reg;
	assign InstrQueueBufIn2 = InstrQueueBufIn2_reg;
	assign InstrQueueBufIn3 = InstrQueueBufIn3_reg;
	assign InstrQueueWCLK = InstrQueueWCLK_reg;
	
endmodule
