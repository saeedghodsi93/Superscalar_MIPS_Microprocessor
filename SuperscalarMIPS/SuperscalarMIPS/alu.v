module alu(
	input  [31:0] SrcA, SrcB,
	input  [3:0]  ALUControl,
	output [31:0] ALUOut);

	reg  [31:0] 	result;
	
	wire [31:0] 	sum, diff;
	wire			carry;
	
	// use subtraction carry to calculate sltu
	assign sum = SrcA + SrcB;
	assign {carry, diff} = SrcA + ~SrcB + 32'd1;
	
	// use subtraction overflow flag to calculate slt
	assign subtraction_overflow = (SrcA[31] != SrcB[31] && diff[31] != SrcA[31]) ? 1 : 0;
	assign slt = subtraction_overflow ? ~(diff[31]) : diff[31];
	
	always @(*)
	begin
		case (ALUControl)
			4'b0000: result = (SrcA & SrcB); // and
			4'b0001: result = (SrcA | SrcB); // or
			4'b0010: result = sum; // add
			4'b0011: result = (SrcA ^ SrcB); // xor
			4'b0100: result = ~(SrcA | SrcB); // nor
			4'b0101: result = SrcA < SrcB; // unsigned set less than
			4'b0110: result = diff; // subtract
			4'b0111: result =  // set less than
						(SrcA[31]==1 && SrcB[31]==0) ? 32'd1 :
						(SrcA[31]==0 && SrcB[31]==1) ? 32'd0 :
						(SrcA[31]==0 && SrcB[31]==0) ? (SrcA < SrcB) : (SrcB < SrcA);
			4'b1000: result = SrcB; // b
		endcase
	end
		
	assign ALUOut = result;
	
endmodule
