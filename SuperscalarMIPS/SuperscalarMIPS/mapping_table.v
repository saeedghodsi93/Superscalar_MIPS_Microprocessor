
module mapping_table(
	input			CLK,
	input			Reset,
	input  [2:0]	WE,
	input			WCLK,
	input			Branch,
	input  [63:0]  	Instr0, Instr1, Instr2, Instr3,
	input  [31:0]	InstrROBTag,
	input  [31:0]	RegFileRD01, RegFileRD02, RegFileRD11, RegFileRD12, RegFileRD21, RegFileRD22, RegFileRD31, RegFileRD32,
	input  [4:0]	RegFileWA1, RegFileWA2,
	input			RegFileWE1, RegFileWE2,
	input  [31:0]	RegFileWD1Tag, RegFileWD2Tag,
	output [4:0]	RegFileA01, RegFileA02, RegFileA11, RegFileA12, RegFileA21, RegFileA22, RegFileA31, RegFileA32,
	output [143:0]	RSEntry0, RSEntry1, RSEntry2, RSEntry3,
	output [69:0]	ROBEntry0, ROBEntry1, ROBEntry2, ROBEntry3,
	output			ROBEntryValid0, ROBEntryValid1, ROBEntryValid2, ROBEntryValid3);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	reg    [31:0] 	table_data [0:31];
	reg				table_flag [0:31];
	wire   [31:0]	n_table_data [0:31];
	wire   [31:0]	n_table_flag;
	reg    [31:0] 	table_data_history [0:31];
	reg				table_flag_history [0:31];
	wire   [31:0] 	n_table_data_history [0:31];
	wire			n_table_flag_history [0:31];
	
	reg    [31:0]	InstrROBTag0, InstrROBTag1, InstrROBTag2, InstrROBTag3;
	reg    [143:0]	RSEntry_reg0, RSEntry_reg1, RSEntry_reg2, RSEntry_reg3;
	reg    [69:0]	ROBEntry_reg0, ROBEntry_reg1, ROBEntry_reg2, ROBEntry_reg3;
	reg				ROBEntryValid_reg0, ROBEntryValid_reg1, ROBEntryValid_reg2, ROBEntryValid_reg3;
	
	wire   [31:0]	PC0, PC1, PC2, PC3;
	wire   [5:0]	Op0, Op1, Op2, Op3;
	wire   [4:0]	Rs0, Rs1, Rs2, Rs3;
	wire   [4:0]	Rt0, Rt1, Rt2, Rt3;
	wire   [4:0]	Rd0, Rd1, Rd2, Rd3;
	wire   [15:0]	Imm0, Imm1, Imm2, Imm3;
	wire   [5:0]	Funct0, Funct1, Funct2, Funct3;
	
	reg    [31:0]	EntryTag0, EntryTag1, EntryTag2, EntryTag3;
	reg    [31:0]	EntryRs0, EntryRs1, EntryRs2, EntryRs3;
	reg    [31:0]	EntryRt0, EntryRt1, EntryRt2, EntryRt3;
	reg    [31:0]	EntryRd0, EntryRd1, EntryRd2, EntryRd3;
	reg    [31:0]	EntryImm0, EntryImm1, EntryImm2, EntryImm3;
	reg				EntryFlag0, EntryFlag1, EntryFlag2, EntryFlag3;
	reg				EntryRsFlag0, EntryRsFlag1, EntryRsFlag2, EntryRsFlag3;
	reg				EntryRtFlag0, EntryRtFlag1, EntryRtFlag2, EntryRtFlag3;
	reg				EntryRdFlag0, EntryRdFlag1, EntryRdFlag2, EntryRdFlag3;
	reg				EntryImmFlag0, EntryImmFlag1, EntryImmFlag2, EntryImmFlag3;
	
/****************************************************************************************/
/* 	Reset																				*/
/****************************************************************************************/	
	integer i;
	always@(Reset) begin
		for (i=0; i<32; i=i+1) begin 
			table_data[i] = 5'd0;
			table_flag[i] = 1'd0;
			table_data_history[i] = 5'd0;
			table_flag_history[i] = 1'd0;
		end
		EntryTag0 = 32'd0;
		EntryRs0 = 32'd0;
		EntryRt0 = 32'd0;
		EntryRd0 = 32'd0;
		EntryImm0 = 32'd0;
		EntryRsFlag0 = 0;
		EntryRtFlag0 = 0;
		EntryRdFlag0 = 0;
		EntryImmFlag0 = 0;
		RSEntry_reg0 = 144'd0;
		ROBEntry_reg0 = 70'd0;
		ROBEntryValid_reg0 = 1'd0;
		EntryTag1 = 32'd0;
		EntryRs1 = 32'd0;
		EntryRt1 = 32'd0;
		EntryRd1 = 32'd0;
		EntryImm1 = 32'd0;
		EntryRsFlag1 = 0;
		EntryRtFlag1 = 0;
		EntryRdFlag1 = 0;
		EntryImmFlag1 = 0;
		RSEntry_reg1 = 144'd0;
		ROBEntry_reg1 = 70'd0;
		ROBEntryValid_reg1 = 1'd0;
		EntryTag2 = 32'd0;
		EntryRs2 = 32'd0;
		EntryRt2 = 32'd0;
		EntryRd2 = 32'd0;
		EntryImm2 = 32'd0;
		EntryRsFlag2 = 0;
		EntryRtFlag2 = 0;
		EntryRdFlag2 = 0;
		EntryImmFlag2 = 0;
		RSEntry_reg2 = 144'd0;
		ROBEntry_reg2 = 70'd0;
		ROBEntryValid_reg2 = 1'd0;
		EntryTag3 = 32'd0;
		EntryRs3 = 32'd0;
		EntryRt3 = 32'd0;
		EntryRd3 = 32'd0;
		EntryImm3 = 32'd0;
		EntryRsFlag3 = 0;
		EntryRtFlag3 = 0;
		EntryRdFlag3 = 0;
		EntryImmFlag3 = 0;
		InstrROBTag0 = 32'd0;
		InstrROBTag1 = 32'd0;
		InstrROBTag2 = 32'd0;
		InstrROBTag3 = 32'd0;
		RSEntry_reg3 = 144'd0;
		ROBEntry_reg3 = 70'd0;
		ROBEntryValid_reg3 = 1'd0;
	end
		
/****************************************************************************************/
/* 	Output Logic																		*/
/****************************************************************************************/
	integer k;
	always@(posedge WCLK) begin
	
		if(WE>=3'd1) begin
			InstrROBTag0 = InstrROBTag;
		
			EntryFlag0 = 1'b1;
			EntryTag0 = InstrROBTag0;
			if(Op0==6'b000000) begin																//R-Type
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				if(table_flag[Rt0]==1'b0) begin
					EntryRt0 = RegFileRD02;
					EntryRtFlag0 = 1'b0;
				end else begin
					EntryRt0 = table_data[Rt0];
					EntryRtFlag0 = 1'b1;
				end
				EntryRd0 = InstrROBTag0;
				EntryRdFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryRdFlag0, EntryRd0, Funct0};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, Rd0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				table_data[Rd0] = InstrROBTag0;
				table_flag[Rd0] = 1'b1;
				
			end else if(Op0==6'b000100 || Op0==6'b000101) begin										//beq, bne
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				if(table_flag[Rt0]==1'b0) begin
					EntryRt0 = RegFileRD02;
					EntryRtFlag0 = 1'b0;
				end else begin
					EntryRt0 = table_data[Rt0];
					EntryRtFlag0 = 1'b1;
				end
				EntryImm0 = {{14{Imm0[15]}}, Imm0[15:0], 2'b00};
				EntryImm0 = EntryImm0 + PC0;
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, 5'd0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				for (k=0; k<32; k=k+1) begin 
					table_data_history[k] = table_data[k];
					table_flag_history[k] = table_flag[k];
				end
		
			end else if(Op0==6'b100011) begin														//lw
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				EntryRt0 = InstrROBTag0;
				EntryRtFlag0 = 1'b0;
				EntryImm0 = {{16{Imm0[15]}}, Imm0[15:0]};
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, Rt0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				table_data[Rt0] = InstrROBTag0;
				table_flag[Rt0] = 1'b1;
			
			end else if(Op0==6'b101011) begin														//sw
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				if(table_flag[Rt0]==1'b0) begin
					EntryRt0 = RegFileRD02;
					EntryRtFlag0 = 1'b0;
				end else begin
					EntryRt0 = table_data[Rt0];
					EntryRtFlag0 = 1'b1;
				end
				EntryImm0 = {{16{Imm0[15]}}, Imm0[15:0]};
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = 70'd0;
				ROBEntryValid_reg0 = 0;
				
			end else if(Op0==6'b001000 || Op0==6'b001001 || Op0==6'b001010 || Op0==6'b001011) begin		//addi, addiu, slti, sltiu
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				EntryRt0 = InstrROBTag0;
				EntryRtFlag0 = 1'b0;
				EntryImm0 = {{16{Imm0[15]}}, Imm0[15:0]};
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, Rt0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				table_data[Rt0] = InstrROBTag0;
				table_flag[Rt0] = 1'b1;
			
			end else if(Op0==6'b001100 || Op0==6'b001101 || Op0==6'b001110) begin						//andi, ori, xori
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				EntryRt0 = InstrROBTag0;
				EntryRtFlag0 = 1'b0;
				EntryImm0 = {16'd0, Imm0[15:0]};
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, Rt0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				table_data[Rt0] = InstrROBTag0;
				table_flag[Rt0] = 1'b1;
			
			end else if(Op0==6'b001111) begin														//lui
				if(table_flag[Rs0]==1'b0) begin
					EntryRs0 = RegFileRD01;
					EntryRsFlag0 = 1'b0;
				end else begin
					EntryRs0 = table_data[Rs0];
					EntryRsFlag0 = 1'b1;
				end
				EntryRt0 = InstrROBTag0;
				EntryRtFlag0 = 1'b0;
				EntryImm0 = {Imm0[15:0], 16'd0};
				EntryImmFlag0 = 1'b0;
				RSEntry_reg0 = {EntryFlag0, EntryTag0, Op0, EntryRsFlag0, EntryRs0, EntryRtFlag0, EntryRt0, EntryImmFlag0, EntryImm0, 6'b000000};
				ROBEntry_reg0 = {1'b1, InstrROBTag0, Rt0, 32'd0};
				ROBEntryValid_reg0 = 1;
				
				table_data[Rt0] = InstrROBTag0;
				table_flag[Rt0] = 1'b1;
			
			end else begin
				RSEntry_reg0 = 144'd0;
				ROBEntry_reg0 = 70'd0;
				ROBEntryValid_reg0 = 0;
				
			end
		end
		
		if(WE>=3'd2) begin
			if(ROBEntryValid_reg0==0)
				InstrROBTag1 = InstrROBTag;
			else
				InstrROBTag1 = InstrROBTag+32'd1;
		
			EntryFlag1 = 1'b1;
			EntryTag1 = InstrROBTag1;
			if(Op1==6'b000000) begin																	//R-Type
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				if(table_flag[Rt1]==1'b0) begin
					EntryRt1 = RegFileRD12;
					EntryRtFlag1 = 1'b0;
				end else begin
					EntryRt1 = table_data[Rt1];
					EntryRtFlag1 = 1'b1;
				end
				EntryRd1 = InstrROBTag1;
				EntryRdFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryRdFlag1, EntryRd1, Funct1};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, Rd1, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				table_data[Rd1] = InstrROBTag1;
				table_flag[Rd1] = 1'b1;
				
			end else if(Op1==6'b000100 || Op1==6'b000101) begin										//beq, bne
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				if(table_flag[Rt1]==1'b0) begin
					EntryRt1 = RegFileRD12;
					EntryRtFlag1 = 1'b0;
				end else begin
					EntryRt1 = table_data[Rt1];
					EntryRtFlag1 = 1'b1;
				end
				EntryImm1 = {{14{Imm1[15]}}, Imm1[15:0], 2'b00};
				EntryImm1 = EntryImm1 + PC1;
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, 5'd0, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				for (k=0; k<32; k=k+1) begin 
					table_data_history[k] = table_data[k];
					table_flag_history[k] = table_flag[k];
				end
				
			end else if(Op1==6'b100011) begin														//lw
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				EntryRt1 = InstrROBTag1;
				EntryRtFlag1 = 1'b0;
				EntryImm1 = {{16{Imm1[15]}}, Imm1[15:0]};
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, Rt1, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				table_data[Rt1] = InstrROBTag1;
				table_flag[Rt1] = 1'b1;
			
			end else if(Op1==6'b101011) begin														//sw
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				if(table_flag[Rt1]==1'b0) begin
					EntryRt1 = RegFileRD12;
					EntryRtFlag1 = 1'b0;
				end else begin
					EntryRt1 = table_data[Rt1];
					EntryRtFlag1 = 1'b1;
				end
				EntryImm1 = {{16{Imm1[15]}}, Imm1[15:0]};
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = 70'd0;
				ROBEntryValid_reg1 = 0;
				
			end else if(Op1==6'b001000 || Op1==6'b001001 || Op1==6'b001010 || Op1==6'b001011) begin		//addi, addiu, slti, sltiu
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				EntryRt1 = InstrROBTag1;
				EntryRtFlag1 = 1'b0;
				EntryImm1 = {{16{Imm1[15]}}, Imm1[15:0]};
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, Rt1, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				table_data[Rt1] = InstrROBTag1;
				table_flag[Rt1] = 1'b1;
			
			end else if(Op1==6'b001100 || Op1==6'b001101 || Op1==6'b001110) begin						//andi, ori, xori
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				EntryRt1 = InstrROBTag1;
				EntryRtFlag1 = 1'b0;
				EntryImm1 = {16'd0, Imm1[15:0]};
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, Rt1, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				table_data[Rt1] = InstrROBTag1;
				table_flag[Rt1] = 1'b1;
			
			end else if(Op1==6'b001111) begin														//lui
				if(table_flag[Rs1]==1'b0) begin
					EntryRs1 = RegFileRD11;
					EntryRsFlag1 = 1'b0;
				end else begin
					EntryRs1 = table_data[Rs1];
					EntryRsFlag1 = 1'b1;
				end
				EntryRt1 = InstrROBTag1;
				EntryRtFlag1 = 1'b0;
				EntryImm1 = {Imm1[15:0], 16'd0};
				EntryImmFlag1 = 1'b0;
				RSEntry_reg1 = {EntryFlag1, EntryTag1, Op1, EntryRsFlag1, EntryRs1, EntryRtFlag1, EntryRt1, EntryImmFlag1, EntryImm1, 6'b000000};
				ROBEntry_reg1 = {1'b1, InstrROBTag1, Rt1, 32'd0};
				ROBEntryValid_reg1 = 1;
				
				table_data[Rt1] = InstrROBTag1;
				table_flag[Rt1] = 1'b1;
			
			end else begin
				RSEntry_reg1 = 144'd0;
				ROBEntry_reg1 = 70'd0;
				ROBEntryValid_reg1 = 0;
				
			end
		end
		
		if(WE>=3'd3) begin
			if(ROBEntryValid_reg0==0 && ROBEntryValid_reg1==0)
				InstrROBTag2 = InstrROBTag;
			else if((ROBEntryValid_reg0==0 && ROBEntryValid_reg1==1) || (ROBEntryValid_reg0==1 && ROBEntryValid_reg1==0))
				InstrROBTag2 = InstrROBTag+32'd1;
			else
				InstrROBTag2 = InstrROBTag+32'd2;
				
			EntryFlag2 = 1'b1;
			EntryTag2 = InstrROBTag2;
			if(Op2==6'b000000) begin																	//R-Type
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				if(table_flag[Rt2]==1'b0) begin
					EntryRt2 = RegFileRD22;
					EntryRtFlag2 = 1'b0;
				end else begin
					EntryRt2 = table_data[Rt2];
					EntryRtFlag2 = 1'b1;
				end
				EntryRd2 = InstrROBTag2;
				EntryRdFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryRdFlag2, EntryRd2, Funct2};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, Rd2, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				table_data[Rd2] = InstrROBTag2;
				table_flag[Rd2] = 1'b1;
				
			end else if(Op2==6'b000100 || Op2==6'b000101) begin										//beq, bne
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				if(table_flag[Rt2]==1'b0) begin
					EntryRt2 = RegFileRD22;
					EntryRtFlag2 = 1'b0;
				end else begin
					EntryRt2 = table_data[Rt2];
					EntryRtFlag2 = 1'b1;
				end
				EntryImm2 = {{14{Imm2[15]}}, Imm2[15:0], 2'b00};
				EntryImm2 = EntryImm2 + PC2;
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, 5'd0, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				for (k=0; k<32; k=k+1) begin 
					table_data_history[k] = table_data[k];
					table_flag_history[k] = table_flag[k];
				end
				
			end else if(Op2==6'b100011) begin														//lw
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				EntryRt2 = InstrROBTag2;
				EntryRtFlag2 = 1'b0;
				EntryImm2 = {{16{Imm2[15]}}, Imm2[15:0]};
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, Rt2, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				table_data[Rt2] = InstrROBTag2;
				table_flag[Rt2] = 1'b1;
			
			end else if(Op2==6'b101011) begin														//sw
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				if(table_flag[Rt2]==1'b0) begin
					EntryRt2 = RegFileRD22;
					EntryRtFlag2 = 1'b0;
				end else begin
					EntryRt2 = table_data[Rt2];
					EntryRtFlag2 = 1'b1;
				end
				EntryImm2 = {{16{Imm2[15]}}, Imm2[15:0]};
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = 70'd0;
				ROBEntryValid_reg2 = 0;
				
			end else if(Op2==6'b001000 || Op2==6'b001001 || Op2==6'b001010 || Op2==6'b001011) begin		//addi, addiu, slti, sltiu
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				EntryRt2 = InstrROBTag2;
				EntryRtFlag2 = 1'b0;
				EntryImm2 = {{16{Imm2[15]}}, Imm2[15:0]};
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, Rt2, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				table_data[Rt2] = InstrROBTag2;
				table_flag[Rt2] = 1'b1;
			
			end else if(Op2==6'b001100 || Op2==6'b001101 || Op2==6'b001110) begin						//andi, ori, xori
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				EntryRt2 = InstrROBTag2;
				EntryRtFlag2 = 1'b0;
				EntryImm2 = {16'd0, Imm2[15:0]};
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, Rt2, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				table_data[Rt2] = InstrROBTag2;
				table_flag[Rt2] = 1'b1;
			
			end else if(Op2==6'b001111) begin														//lui
				if(table_flag[Rs2]==1'b0) begin
					EntryRs2 = RegFileRD21;
					EntryRsFlag2 = 1'b0;
				end else begin
					EntryRs2 = table_data[Rs2];
					EntryRsFlag2 = 1'b1;
				end
				EntryRt2 = InstrROBTag2;
				EntryRtFlag2 = 1'b0;
				EntryImm2 = {Imm2[15:0], 16'd0};
				EntryImmFlag2 = 1'b0;
				RSEntry_reg2 = {EntryFlag2, EntryTag2, Op2, EntryRsFlag2, EntryRs2, EntryRtFlag2, EntryRt2, EntryImmFlag2, EntryImm2, 6'b000000};
				ROBEntry_reg2 = {1'b1, InstrROBTag2, Rt2, 32'd0};
				ROBEntryValid_reg2 = 1;
				
				table_data[Rt2] = InstrROBTag2;
				table_flag[Rt2] = 1'b1;
			
			end else begin
				RSEntry_reg2 = 144'd0;
				ROBEntry_reg2 = 70'd0;
				ROBEntryValid_reg2 = 0;
				
			end
		end

		if(WE>=3'd4) begin
			if((ROBEntryValid_reg0==0 && ROBEntryValid_reg1==0 && ROBEntryValid_reg1==0))
				InstrROBTag3 = InstrROBTag;
			else if((ROBEntryValid_reg0==1 && ROBEntryValid_reg1==0 && ROBEntryValid_reg1==0) || (ROBEntryValid_reg0==0 && ROBEntryValid_reg1==1 && ROBEntryValid_reg1==0) || (ROBEntryValid_reg0==0 && ROBEntryValid_reg1==0 && ROBEntryValid_reg1==1))
				InstrROBTag3 = InstrROBTag+32'd1;
			else if((ROBEntryValid_reg0==1 && ROBEntryValid_reg1==1 && ROBEntryValid_reg1==0) || (ROBEntryValid_reg0==1 && ROBEntryValid_reg1==0 && ROBEntryValid_reg1==1) || (ROBEntryValid_reg0==0 && ROBEntryValid_reg1==1 && ROBEntryValid_reg1==1))
				InstrROBTag3 = InstrROBTag+32'd2;
			else
				InstrROBTag3 = InstrROBTag+32'd3;
			
			EntryFlag3 = 1'b1;
			EntryTag3 = InstrROBTag3;
			if(Op3==6'b000000) begin																	//R-Type
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				if(table_flag[Rt3]==1'b0) begin
					EntryRt3 = RegFileRD32;
					EntryRtFlag3 = 1'b0;
				end else begin
					EntryRt3 = table_data[Rt3];
					EntryRtFlag3 = 1'b1;
				end
				EntryRd3 = InstrROBTag3;
				EntryRdFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryRdFlag3, EntryRd3, Funct3};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, Rd3, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				table_data[Rd3] = InstrROBTag3;
				table_flag[Rd3] = 1'b1;
				
			end else if(Op3==6'b000100 || Op3==6'b000101) begin										//beq, bne
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				if(table_flag[Rt3]==1'b0) begin
					EntryRt3 = RegFileRD32;
					EntryRtFlag3 = 1'b0;
				end else begin
					EntryRt3 = table_data[Rt3];
					EntryRtFlag3 = 1'b1;
				end
				EntryImm3 = {{14{Imm3[15]}}, Imm3[15:0], 2'b00};
				EntryImm3 = EntryImm3 + PC3;
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, 5'd0, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				for (k=0; k<32; k=k+1) begin 
					table_data_history[k] = table_data[k];
					table_flag_history[k] = table_flag[k];
				end
				
			end else if(Op3==6'b100011) begin														//lw
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				EntryRt3 = InstrROBTag3;
				EntryRtFlag3 = 1'b0;
				EntryImm3 = {{16{Imm3[15]}}, Imm3[15:0]};
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, Rt3, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				table_data[Rt3] = InstrROBTag3;
				table_flag[Rt3] = 1'b1;
			
			end else if(Op3==6'b101011) begin														//sw
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				if(table_flag[Rt3]==1'b0) begin
					EntryRt3 = RegFileRD32;
					EntryRtFlag3 = 1'b0;
				end else begin
					EntryRt3 = table_data[Rt3];
					EntryRtFlag3 = 1'b1;
				end
				EntryImm3 = {{16{Imm3[15]}}, Imm3[15:0]};
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = 70'd0;
				ROBEntryValid_reg3 = 0;
				
			end else if(Op3==6'b001000 || Op3==6'b001001 || Op3==6'b001010 || Op3==6'b001011) begin		//addi, addiu, slti, sltiu
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				EntryRt3 = InstrROBTag3;
				EntryRtFlag3 = 1'b0;
				EntryImm3 = {{16{Imm3[15]}}, Imm3[15:0]};
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, Rt3, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				table_data[Rt3] = InstrROBTag3;
				table_flag[Rt3] = 1'b1;
			
			end else if(Op3==6'b001100 || Op3==6'b001101 || Op3==6'b001110) begin						//andi, ori, xori
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				EntryRt3 = InstrROBTag3;
				EntryRtFlag3 = 1'b0;
				EntryImm3 = {16'd0, Imm3[15:0]};
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, Rt3, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				table_data[Rt3] = InstrROBTag3;
				table_flag[Rt3] = 1'b1;
			
			end else if(Op3==6'b001111) begin														//lui
				if(table_flag[Rs3]==1'b0) begin
					EntryRs3 = RegFileRD31;
					EntryRsFlag3 = 1'b0;
				end else begin
					EntryRs3 = table_data[Rs3];
					EntryRsFlag3 = 1'b1;
				end
				EntryRt3 = InstrROBTag3;
				EntryRtFlag3 = 1'b0;
				EntryImm3 = {Imm3[15:0], 16'd0};
				EntryImmFlag3 = 1'b0;
				RSEntry_reg3 = {EntryFlag3, EntryTag3, Op3, EntryRsFlag3, EntryRs3, EntryRtFlag3, EntryRt3, EntryImmFlag3, EntryImm3, 6'b000000};
				ROBEntry_reg3 = {1'b1, InstrROBTag3, Rt3, 32'd0};
				ROBEntryValid_reg3 = 1;
				
				table_data[Rt3] = InstrROBTag3;
				table_flag[Rt3] = 1'b1;
			
			end else begin
				RSEntry_reg3 = 144'd0;
				ROBEntry_reg3 = 70'd0;
				ROBEntryValid_reg3 = 0;
				
			end
		end
		
		table_data[5'd0] = 32'd0;
		table_flag[5'd0] = 1'b0;
			
	end
	
	assign PC0 = Instr0[63:32];
	assign PC1 = Instr1[63:32];
	assign PC2 = Instr2[63:32];
	assign PC3 = Instr3[63:32];
	assign Op0 = Instr0[31:26];
	assign Op1 = Instr1[31:26];
	assign Op2 = Instr2[31:26];
	assign Op3 = Instr3[31:26];
	assign Rs0 = Instr0[25:21];
	assign Rs1 = Instr1[25:21];
	assign Rs2 = Instr2[25:21];
	assign Rs3 = Instr3[25:21];
	assign Rt0 = Instr0[20:16];
	assign Rt1 = Instr1[20:16];
	assign Rt2 = Instr2[20:16];
	assign Rt3 = Instr3[20:16];
	assign Rd0 = Instr0[15:11];
	assign Rd1 = Instr1[15:11];
	assign Rd2 = Instr2[15:11];
	assign Rd3 = Instr3[15:11];
	assign Imm0 = Instr0[15:0];
	assign Imm1 = Instr1[15:0];
	assign Imm2 = Instr2[15:0];
	assign Imm3 = Instr3[15:0];
	assign Funct0 = Instr0[5:0];
	assign Funct1 = Instr1[5:0];
	assign Funct2 = Instr2[5:0];
	assign Funct3 = Instr3[5:0];

/****************************************************************************************/
/* 	Rollback, When Branch Happens														*/
/****************************************************************************************/
	integer l;
	always@(posedge Branch) begin
		if(Branch) begin
			for (k=0; k<32; k=k+1) begin 
				if(!(table_data[k]==32'd0&&table_flag[k]==1'd0)) begin
					table_data[k] = table_data_history[k];
					table_flag[k] = table_flag_history[k];
				end
			end
		end
	
	end
	
/****************************************************************************************/
/* 	Table Update																		*/
/****************************************************************************************/	
	always@(posedge CLK) begin
		if(RegFileWE1==1) begin
			if(RegFileWD1Tag==table_data[RegFileWA1]) begin
				table_data[RegFileWA1] = 32'd0;
				table_flag[RegFileWA1] = 1'd0;
			end
		end
		if(RegFileWE2==1) begin
			if(RegFileWD2Tag==table_data[RegFileWA2]) begin
				table_data[RegFileWA2] = 32'd0;
				table_flag[RegFileWA2] = 1'd0;
			end
		end
		
		table_data[5'd0] = 32'd0;
		table_flag[5'd0] = 1'b0;
		
	end

/****************************************************************************************/
/* 	Output Assignments																	*/
/****************************************************************************************/
	assign RegFileA01 = Rs0;
	assign RegFileA02 = Rt0;
	assign RegFileA11 = Rs1;
	assign RegFileA12 = Rt1;
	assign RegFileA21 = Rs2;
	assign RegFileA22 = Rt2;
	assign RegFileA31 = Rs3;
	assign RegFileA32 = Rt3;
	
	assign RSEntry0 = RSEntry_reg0;
	assign RSEntry1 = RSEntry_reg1;
	assign RSEntry2 = RSEntry_reg2;
	assign RSEntry3 = RSEntry_reg3;

	assign ROBEntry0 = ROBEntry_reg0;
	assign ROBEntry1 = ROBEntry_reg1;
	assign ROBEntry2 = ROBEntry_reg2;
	assign ROBEntry3 = ROBEntry_reg3;
	assign ROBEntryValid0 = ROBEntryValid_reg0;
	assign ROBEntryValid1 = ROBEntryValid_reg1;
	assign ROBEntryValid2 = ROBEntryValid_reg2;
	assign ROBEntryValid3 = ROBEntryValid_reg3;
	
	genvar j;        
	generate        
		for (j = 0; j < 32 ; j=j+1) begin     
		  assign n_table_data[j] = table_data[j];
		  assign n_table_flag[j] = table_flag[j];
		  assign n_table_data_history[j] = table_data_history[j];
		  assign n_table_flag_history[j] = table_flag_history[j];
		end
	endgenerate

endmodule
