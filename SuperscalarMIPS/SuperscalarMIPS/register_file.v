module register_file(
	input			CLK,
	input         	WE1, WE2, 
	input  [4:0] 	A01, A02, A11, A12, A21, A22, A31, A32, WA1, WA2, 
	input  [31:0] 	WD1, WD2,
	output [31:0] 	RD01, RD02, RD11, RD12, RD21, RD22, RD31, RD32);

	reg [31:0] registers [0:31];

	assign RD01 = (A01 == 5'd0) ? 32'd0 :
						 ((A01 == WA1) && WE1) ? WD1 : ((A01 == WA2) && WE2) ? WD2 :registers[ A01 ];
	assign RD02 = (A02 == 5'd0) ? 32'd0 :
						 ((A02 == WA1) && WE1) ? WD1 : ((A02 == WA2) && WE2) ? WD2 :registers[ A02 ];

	assign RD11 = (A11 == 5'd0) ? 32'd0 :
						 ((A11 == WA1) && WE1) ? WD1 : ((A11 == WA2) && WE2) ? WD2 :registers[ A11 ];
	assign RD12 = (A12 == 5'd0) ? 32'd0 :
						 ((A12 == WA1) && WE1) ? WD1 : ((A12 == WA2) && WE2) ? WD2 :registers[ A12 ];

	assign RD21 = (A21 == 5'd0) ? 32'd0 :
						 ((A21 == WA1) && WE1) ? WD1 : ((A21 == WA2) && WE2) ? WD2 :registers[ A21 ];
	assign RD22 = (A22 == 5'd0) ? 32'd0 :
						 ((A22 == WA1) && WE1) ? WD1 : ((A22 == WA2) && WE2) ? WD2 :registers[ A22 ];

	assign RD31 = (A31 == 5'd0) ? 32'd0 :
						 ((A31 == WA1) && WE1) ? WD1 : ((A31 == WA2) && WE2) ? WD2 :registers[ A31 ];
	assign RD32 = (A32 == 5'd0) ? 32'd0 :
						 ((A32 == WA1) && WE1) ? WD1 : ((A32 == WA2) && WE2) ? WD2 :registers[ A32 ];

	always @(posedge CLK)
	begin
		if(WE1)
		begin
			registers[ WA1 ] <= WD1;
		end
		if(WE2)
		begin
			registers[ WA2 ] <= WD2;
		end
		registers[5'd0] <= 32'd0;
	end

endmodule
