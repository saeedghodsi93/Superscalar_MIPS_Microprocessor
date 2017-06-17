module register #(parameter N = 1) (
	input 			clk,
	input 			clear,
	input 			hold,
	input  [N-1:0] 	in,
	output [N-1:0] 	out);

	reg    [N-1:0] 	out_reg;
	
	always @(posedge clk)
	begin
		if (hold)
			out_reg <= out;
		else if (clear)
			out_reg <= {N{1'b0}};
		else
			out_reg <= in;
	end
	
	assign out = out_reg;
	
endmodule