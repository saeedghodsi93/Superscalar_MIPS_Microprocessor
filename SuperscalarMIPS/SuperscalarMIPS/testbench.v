
`timescale 1ns/1ns

module testbench;

	reg clk = 1;
	always @(clk)
		clk <= #5 ~clk;

	reg reset;
	initial
	begin
		reset = 1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		#1;
		reset = 0;
	end
   
	initial
		$readmemh("isort32m.hex", dut.instruction_mem.mem_data);
	parameter end_instr = 32'h1000FFFF;

	integer i;
	always @(dut.mips.Instr0)
	begin
		if(dut.mips.Instr0[31:0]==end_instr)
		begin
			for(i=0; i<96; i=i+1)
			begin
				$write("%x ", dut.data_mem.mem_data[i+32]);
				if(((i+1) % 16) == 0)
					$write("\n");
			end
			$write("\nfinished!\n");
			$stop;
		end
	end
	
	top dut(
		.CLK(clk),
		.Reset(reset));

endmodule
