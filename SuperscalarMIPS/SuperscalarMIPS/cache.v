module cache(
	input         	CLK,
	input			RME, WE,
	input  [31:0] 	WA, RTag,
	input  [31:0] 	RMD0, RMD1, RMD2, RMD3, RMD4, RMD5, RMD6, RMD7, RMD8, RMD9, RMD10, RMD11, RMD12, RMD13, RMD14, RMD15,
	input  [31:0]	WD,
	output [31:0]	CacheRA,
	output			RHit,
	output [31:0] 	RD);

	// 1'b Valid + 32'b Imm + 32'b Rs + 32'b Data
	reg    [63:0] 	mem_data [0:15];

	wire   [31:0]	RMA0, RMA1, RMA2, RMA3, RMA4, RMA5, RMA6, RMA7, RMA8, RMA9, RMA10, RMA11, RMA12, RMA13, RMA14, RMA15;
	wire   [31:0]	Tag0, Tag1, Tag2, Tag3, Tag4, Tag5, Tag6, Tag7, Tag8, Tag9, Tag10, Tag11, Tag12, Tag13, Tag14, Tag15;
	wire   [31:0]	Data0, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11, Data12, Data13, Data14, Data15;
	
	assign RHit = ((RTag==Tag0&&~(Data0===32'dx)) || (RTag==Tag1&&~(Data1===32'dx)) || (RTag==Tag2&&~(Data2===32'dx)) || (RTag==Tag3&&~(Data3===32'dx)) || 
				  (RTag==Tag4&&~(Data4===32'dx)) || (RTag==Tag5&&~(Data5===32'dx)) || (RTag==Tag6&&~(Data6===32'dx)) || (RTag==Tag7&&~(Data7===32'dx)) || 
				  (RTag==Tag8&&~(Data8===32'dx)) || (RTag==Tag9&&~(Data9===32'dx)) || (RTag==Tag10&&~(Data10===32'dx)) || (RTag==Tag11&&~(Data11===32'dx)) || 
				  (RTag==Tag12&&~(Data12===32'dx)) || (RTag==Tag13&&~(Data13===32'dx)) || (RTag==Tag14&&~(Data14===32'dx)) || (RTag==Tag15&&~(Data15===32'dx))) ? 1'b1 : 1'b0;
	assign RD =   (RTag==Tag0) ? Data0 : (RTag==Tag1) ? Data1 : (RTag==Tag2) ? Data2 : (RTag==Tag3) ? Data3 : 
				  (RTag==Tag4) ? Data4 : (RTag==Tag5) ? Data5 : (RTag==Tag6) ? Data6 : (RTag==Tag7) ? Data7 : 
				  (RTag==Tag8) ? Data8 : (RTag==Tag9) ? Data9 : (RTag==Tag10) ? Data10 : (RTag==Tag11) ? Data11 : 
				  (RTag==Tag12) ? Data12 : (RTag==Tag13) ? Data13 : (RTag==Tag14) ? Data14 : (RTag==Tag15) ? Data15 : 32'd0;
				  
	always @(posedge CLK)
	begin
		if(RME) begin
			mem_data[ 4'd0 ] <= {RMA0,RMD0};
			mem_data[ 4'd1 ] <= {RMA1,RMD1};
			mem_data[ 4'd2 ] <= {RMA2,RMD2};
			mem_data[ 4'd3 ] <= {RMA3,RMD3};
			mem_data[ 4'd4 ] <= {RMA4,RMD4};
			mem_data[ 4'd5 ] <= {RMA5,RMD5};
			mem_data[ 4'd6 ] <= {RMA6,RMD6};
			mem_data[ 4'd7 ] <= {RMA7,RMD7};
			mem_data[ 4'd8 ] <= {RMA8,RMD8};
			mem_data[ 4'd9 ] <= {RMA9,RMD9};
			mem_data[ 4'd10 ] <= {RMA10,RMD10};
			mem_data[ 4'd11 ] <= {RMA11,RMD11};
			mem_data[ 4'd12 ] <= {RMA12,RMD12};
			mem_data[ 4'd13 ] <= {RMA13,RMD13};
			mem_data[ 4'd14 ] <= {RMA14,RMD14};
			mem_data[ 4'd15 ] <= {RMA15,RMD15};
		end
		
		if(WE) begin
			if(WA==Tag0)
				mem_data[ 4'd0 ] <= {WA,WD};
			else if(WA==Tag1)
				mem_data[ 4'd1 ] <= {WA,WD};
			else if(WA==Tag2)
				mem_data[ 4'd2 ] <= {WA,WD};
			else if(WA==Tag3)
				mem_data[ 4'd3 ] <= {WA,WD};
			else if(WA==Tag4)
				mem_data[ 4'd4 ] <= {WA,WD};
			else if(WA==Tag5)
				mem_data[ 4'd5 ] <= {WA,WD};
			else if(WA==Tag6)
				mem_data[ 4'd6 ] <= {WA,WD};
			else if(WA==Tag7)
				mem_data[ 4'd7 ] <= {WA,WD};
			else if(WA==Tag8)
				mem_data[ 4'd8 ] <= {WA,WD};
			else if(WA==Tag9)
				mem_data[ 4'd9 ] <= {WA,WD};
			else if(WA==Tag10)
				mem_data[ 4'd10 ] <= {WA,WD};
			else if(WA==Tag11)
				mem_data[ 4'd11 ] <= {WA,WD};
			else if(WA==Tag12)
				mem_data[ 4'd12 ] <= {WA,WD};
			else if(WA==Tag13)
				mem_data[ 4'd13 ] <= {WA,WD};
			else if(WA==Tag14)
				mem_data[ 4'd14 ] <= {WA,WD};
			else if(WA==Tag15)
				mem_data[ 4'd15 ] <= {WA,WD};	
		end
	end
	
	assign CacheRA = {RTag[31:6],6'd0};
	assign RMA0 = CacheRA;
	assign RMA1 = CacheRA+32'd4;
	assign RMA2 = CacheRA+32'd8;
	assign RMA3 = CacheRA+32'd12;
	assign RMA4 = CacheRA+32'd16;
	assign RMA5 = CacheRA+32'd20;
	assign RMA6 = CacheRA+32'd24;
	assign RMA7 = CacheRA+32'd28;
	assign RMA8 = CacheRA+32'd32;
	assign RMA9 = CacheRA+32'd36;
	assign RMA10 = CacheRA+32'd40;
	assign RMA11 = CacheRA+32'd44;
	assign RMA12 = CacheRA+32'd48;
	assign RMA13 = CacheRA+32'd52;
	assign RMA14 = CacheRA+32'd56;
	assign RMA15 = CacheRA+32'd60;
	
	assign Tag0 = mem_data[4'd0][63:32];
	assign Tag1 = mem_data[4'd1][63:32];
	assign Tag2 = mem_data[4'd2][63:32];
	assign Tag3 = mem_data[4'd3][63:32];
	assign Tag4 = mem_data[4'd4][63:32];
	assign Tag5 = mem_data[4'd5][63:32];
	assign Tag6 = mem_data[4'd6][63:32];
	assign Tag7 = mem_data[4'd7][63:32];
	assign Tag8 = mem_data[4'd8][63:32];
	assign Tag9 = mem_data[4'd9][63:32];
	assign Tag10 = mem_data[4'd10][63:32];
	assign Tag11 = mem_data[4'd11][63:32];
	assign Tag12 = mem_data[4'd12][63:32];
	assign Tag13 = mem_data[4'd13][63:32];
	assign Tag14 = mem_data[4'd14][63:32];
	assign Tag15 = mem_data[4'd15][63:32];
	
	assign Data0 = mem_data[4'd0][31:0];
	assign Data1 = mem_data[4'd1][31:0];
	assign Data2 = mem_data[4'd2][31:0];
	assign Data3 = mem_data[4'd3][31:0];
	assign Data4 = mem_data[4'd4][31:0];
	assign Data5 = mem_data[4'd5][31:0];
	assign Data6 = mem_data[4'd6][31:0];
	assign Data7 = mem_data[4'd7][31:0];
	assign Data8 = mem_data[4'd8][31:0];
	assign Data9 = mem_data[4'd9][31:0];
	assign Data10 = mem_data[4'd10][31:0];
	assign Data11 = mem_data[4'd11][31:0];
	assign Data12 = mem_data[4'd12][31:0];
	assign Data13 = mem_data[4'd13][31:0];
	assign Data14 = mem_data[4'd14][31:0];
	assign Data15 = mem_data[4'd15][31:0];
	
endmodule
