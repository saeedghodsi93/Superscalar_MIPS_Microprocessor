module data_mem(
	input         	CLK,
	input         	WE,
	input  [31:0] 	WA, RA,
	input  [31:0] 	WD,
	input  [31:0]	CacheRA,
	output [31:0] 	RD,
	output [31:0]	CacheRD0, CacheRD1, CacheRD2, CacheRD3, CacheRD4, CacheRD5, CacheRD6, CacheRD7, CacheRD8, CacheRD9, CacheRD10, CacheRD11, CacheRD12, CacheRD13, CacheRD14, CacheRD15);

	reg [31:0] mem_data [0:1023];

	assign RD = mem_data[ RA[31:2] ];

	always @(posedge CLK)
		if(WE)
			mem_data[ WA[31:2] ] <= WD;

	assign CacheRD0 = mem_data[ CacheRA[31:2] ];
	assign CacheRD1 = mem_data[ CacheRA[31:2]+32'd1 ];
	assign CacheRD2 = mem_data[ CacheRA[31:2]+32'd2 ];
	assign CacheRD3 = mem_data[ CacheRA[31:2]+32'd3 ];
	assign CacheRD4 = mem_data[ CacheRA[31:2]+32'd4 ];
	assign CacheRD5 = mem_data[ CacheRA[31:2]+32'd5 ];
	assign CacheRD6 = mem_data[ CacheRA[31:2]+32'd6 ];
	assign CacheRD7 = mem_data[ CacheRA[31:2]+32'd7 ];
	assign CacheRD8 = mem_data[ CacheRA[31:2]+32'd8 ];
	assign CacheRD9 = mem_data[ CacheRA[31:2]+32'd9 ];
	assign CacheRD10= mem_data[ CacheRA[31:2]+32'd10 ];
	assign CacheRD11 = mem_data[ CacheRA[31:2]+32'd11 ];
	assign CacheRD12 = mem_data[ CacheRA[31:2]+32'd12 ];
	assign CacheRD13 = mem_data[ CacheRA[31:2]+32'd13 ];
	assign CacheRD14 = mem_data[ CacheRA[31:2]+32'd14 ];
	assign CacheRD15 = mem_data[ CacheRA[31:2]+32'd15 ];
	
endmodule
