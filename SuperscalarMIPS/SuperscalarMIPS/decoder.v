
module decoder(
	input			Reset,
	input   [143:0]	RSEntry,
	input			CacheHit,
	input	[31:0]	CacheData,
	output  [3:0]	ALUControl,
	output  [31:0]	SrcA, SrcB,
	output  [31:0]	Dest,
	output			Write,
	output			Branch,
	output			BranchResolved,
	output  [31:0]	BranchTag,
	output  [31:0]	CacheTag,
	output			CacheRME,
	output  [31:0]	DataLoadCache,
	output  [31:0]	DestLoadCache,
	output			RegWriteLoadCache);

/****************************************************************************************/
/* 	Variables																			*/
/****************************************************************************************/
	wire    [5:0]	EntryOp, EntryFunct;
	wire    [31:0]	EntryTag, EntryRs, EntryRt, EntryRd, EntryImm;
	wire			EntryFlag, EntryRsFlag, EntryRtFlag, EntryRdImmFlag;
	
	reg     [31:0]	SrcA_reg, SrcB_reg, Dest_reg;
	reg				Branch_reg, BranchResolved_reg;
	reg     [31:0]	BranchTag_reg;
	
	reg				CacheRME_reg;
	
	reg     [3:0] 	Controls;
	wire    [2:0] 	ALUOp;
	
	reg     [31:0]	DataLoadCache_reg, DestLoadCache_reg;
	reg				RegWriteLoadCache_reg;
	
/****************************************************************************************/
/* 	Decoder																				*/
/****************************************************************************************/
	assign EntryFlag = RSEntry[143];
	assign EntryTag = RSEntry[142:111];
	assign EntryOp = RSEntry[110:105];
	assign EntryRsFlag = RSEntry[104];
	assign EntryRs = RSEntry[103:72];
	assign EntryRtFlag = RSEntry[71];
	assign EntryRt = RSEntry[70:39];
	assign EntryRdImmFlag = RSEntry[38];
	assign EntryRd = RSEntry[37:6];
	assign EntryImm = RSEntry[37:6];
	assign EntryFunct = RSEntry[5:0];

	always @(RSEntry or Reset)
	begin
		if(Reset) begin
			SrcA_reg = 32'd0;
			SrcB_reg = 32'd0;
			Dest_reg = 32'd0;
			Branch_reg = 1'd0;
			BranchResolved_reg = 1'd0;
			BranchTag_reg = 32'd0;
			CacheRME_reg = 0;
			Controls = 4'b0000;
			
		end else begin
			if(EntryFlag==1) begin
				if(EntryOp==6'b000000) begin															//R-Type
					SrcA_reg = EntryRs;
					SrcB_reg = EntryRt;
					Dest_reg = EntryRd;
					Branch_reg = 1'd0;
					BranchResolved_reg = 1'd0;
					BranchTag_reg = 32'd0;
					CacheRME_reg = 0;
				end else if(EntryOp==6'b000100 || EntryOp==6'b000101) begin								//beq, bne
					SrcA_reg = EntryRs;
					SrcB_reg = EntryRt;
					Dest_reg = EntryImm;
					Branch_reg = (((EntryOp==6'b000100) && (SrcA_reg==SrcB_reg)) || ((EntryOp==6'b000101) && (SrcA_reg!=SrcB_reg)));
					BranchResolved_reg = 1'd1;
					BranchTag_reg = EntryTag;
					CacheRME_reg = 0;
				end else if(EntryOp==6'b100011) begin													//lw
					if(CacheHit==1'b1) begin
						SrcA_reg = 32'd0;
						SrcB_reg = 32'd0;
						Dest_reg = 32'd0;
						Branch_reg = 1'd0;
						BranchResolved_reg = 1'd0;
						BranchTag_reg = 32'd0;
						CacheRME_reg = 0;
						DataLoadCache_reg = CacheData;
						DestLoadCache_reg = EntryRt;
						RegWriteLoadCache_reg = 1'b1;
					end else begin
						SrcA_reg = EntryRs;
						SrcB_reg = EntryImm;
						Dest_reg = EntryRt;
						Branch_reg = 1'd0;
						BranchResolved_reg = 1'd0;
						BranchTag_reg = 32'd0;
						CacheRME_reg = 1;
						DataLoadCache_reg = 32'd0;
						DestLoadCache_reg = 32'd0;
						RegWriteLoadCache_reg = 1'b0;
					end
				end else if(EntryOp==6'b101011) begin													//sw
					SrcA_reg = EntryRs;
					SrcB_reg = EntryImm;
					Dest_reg = EntryRt;
					Branch_reg = 1'd0;
					BranchResolved_reg = 1'd0;
					BranchTag_reg = 32'd0;
					CacheRME_reg = 0;
				end else begin																			//addi, addiu, slti, sltiu, andi, ori, xori, lui
					SrcA_reg = EntryRs;
					SrcB_reg = EntryImm;
					Dest_reg = EntryRt;
					Branch_reg = 1'd0;
					BranchResolved_reg = 1'd0;
					BranchTag_reg = 32'd0;
					CacheRME_reg = 0;
				end
				
				case(EntryOp)
					6'b000000: Controls = 4'b1000; // R-type
					6'b000100: Controls = 4'b0001; // beq
					6'b000101: Controls = 4'b0001; // bne
					6'b001000: Controls = 4'b1001; // addi
					6'b001001: Controls = 4'b1001; // addiu
					6'b001010: Controls = 4'b1101; // slti
					6'b001011: Controls = 4'b1110; // sltiu
					6'b001100: Controls = 4'b1010; // andi
					6'b001101: Controls = 4'b1011; // ori
					6'b001110: Controls = 4'b1100; // xori
					6'b001111: Controls = 4'b1111; // lui
					6'b100011:  if(CacheHit==1'b0) Controls = 4'b1001; // lw
								else Controls = 4'b0000; //cache hit
					6'b101011: Controls = 4'b1001; // sw
					default:   Controls = 4'b0000; // ???
				endcase
				
			end else begin
				SrcA_reg = 32'd0;
				SrcB_reg = 32'd0;
				Dest_reg = 32'd0;
				Branch_reg = 1'd0;
				BranchResolved_reg = 1'd0;
				BranchTag_reg = 32'd0;
				CacheRME_reg = 0;
				DataLoadCache_reg = 32'd0;
				DestLoadCache_reg = 32'd0;
				RegWriteLoadCache_reg = 1'b0;
				Controls = 4'b0000;
			end
			
		end
	end
	
/****************************************************************************************/
/* 	Output Assignments																	*/
/****************************************************************************************/
	assign {Write, ALUOp} = Controls;
	assign SrcA = SrcA_reg;
	assign SrcB = SrcB_reg;
	assign Dest = Dest_reg;
	assign Branch = Branch_reg;
	assign BranchResolved = BranchResolved_reg;
	assign BranchTag = BranchTag_reg;
	assign CacheRME = CacheRME_reg;
	assign CacheTag = EntryRs + EntryImm;
	assign DataLoadCache = DataLoadCache_reg;
	assign DestLoadCache = DestLoadCache_reg;
	assign RegWriteLoadCache = RegWriteLoadCache_reg;
	
/****************************************************************************************/
/* 	ALU Decoder																			*/
/****************************************************************************************/	
	alu_decoder alu_decoder(Reset, EntryFunct, ALUOp, ALUControl);

endmodule


/****************************************************************************************/
/* 	ALU Decoder	Modeule	 																*/
/****************************************************************************************/
module alu_decoder(
	input			Reset,
	input  [5:0] 	Funct,
	input  [2:0] 	ALUOp,
	output [3:0] 	ALUControl);

	reg    [3:0] 	Control;
	
	always @(Funct or ALUOp or Reset)
	begin
		if(Reset) begin
			Control <= 4'd0;
			
		end else begin
			case(ALUOp)
				3'b000:
				begin 
					case(Funct) // R-type instructions
						6'b100000: Control <= 4'b0010; // add
						6'b100001: Control <= 4'b0010; // addu
						6'b100010: Control <= 4'b0110; // sub
						6'b100011: Control <= 4'b0110; // subu
						6'b100100: Control <= 4'b0000; // and
						6'b100101: Control <= 4'b0001; // or
						6'b100110: Control <= 4'b0011; // xor
						6'b100111: Control <= 4'b0100; // nor
						6'b101010: Control <= 4'b0111; // slt
						6'b101011: Control <= 4'b0101; // sltu
						default:   Control <= 4'b0000; // ???
					endcase
				end
				3'b001: Control <= 4'b0010; // add
				3'b010: Control <= 4'b0000; // and
				3'b011: Control <= 4'b0001; // or
				3'b100: Control <= 4'b0011; // xor
				3'b101: Control <= 4'b0111; // slt
				3'b110: Control <= 4'b0101; // sltu
				3'b111: Control <= 4'b1000; // lu
				default: Control <= 4'b0000; // ???
			endcase
			
		end
	end
	
	assign ALUControl = Control;
	
endmodule
