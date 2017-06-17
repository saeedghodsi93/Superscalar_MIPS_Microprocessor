
module fifo #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 5) ( 
	input						wclk, rclk, rst, flush,																// reset, system clock, write enable and read enable. 
	input  [1:0]				we, re,
	input  [DATA_WIDTH-1:0]		buf_in0, buf_in1, buf_in2, buf_in3,													// data input to be pushed to buffer
	output [DATA_WIDTH-1:0]		buf_out0, buf_out1, buf_out2, buf_out3,												// port to output the data using pop.
	output [31:0]				head_element_data0, head_element_data1, head_element_data2, head_element_data3, head_element_pc,
	output						buf_empty0, buf_empty1, buf_empty2, buf_empty3, buf_full,							// buffer empty and full indication	
	output [ADDR_WIDTH :0]		fifo_counter);																		// number of data pushed in to buffer					  

	reg    [DATA_WIDTH-1:0]		buf_out_reg0, buf_out_reg1, buf_out_reg2, buf_out_reg3;
	reg    [ADDR_WIDTH :0]		fifo_counter_reg; 
	reg    [ADDR_WIDTH -1:0]	rd_ptr, wr_ptr;																		// pointers to read and write addresses  
	reg    [DATA_WIDTH-1:0]		buf_mem [0:(1<<ADDR_WIDTH)-1];

	assign buf_empty0 = (fifo_counter_reg<=0);
	assign buf_empty1 = (fifo_counter_reg<=1);
	assign buf_empty2 = (fifo_counter_reg<=2);
	assign buf_empty3 = (fifo_counter_reg<=3);
	assign buf_full = (fifo_counter_reg>=(1<<ADDR_WIDTH)-3);
	
	always @(posedge flush)
	begin
		if ( flush )
		begin
			fifo_counter_reg <= 0;
			buf_out_reg0 <= 0;
			buf_out_reg1 <= 0;
			buf_out_reg2 <= 0;
			buf_out_reg3 <= 0;
			wr_ptr <= 0;
			rd_ptr <= 0;
		end
	end
	
	always @(posedge wclk or posedge rclk or posedge rst)
	begin
		if( rst )
			fifo_counter_reg <= 0;
		else if( (!buf_full && wclk) && (!((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))||(buf_empty2&&(re==2'b10))||(buf_empty3&&(re==2'b11))) && rclk) ) begin
			if( we==2'b00 && re==2'b11 )
				fifo_counter_reg <= fifo_counter_reg-3;
			else if( (we==2'b00 && re==2'b10) || (we==2'b01 && re==2'b11) )
				fifo_counter_reg <= fifo_counter_reg-2;
			else if( (we==2'b00 && re==2'b01) || (we==2'b01 && re==2'b10) || (we==2'b10 && re==2'b11) )
				fifo_counter_reg <= fifo_counter_reg-1;
			else if( (we==2'b00 && re==2'b00) || (we==2'b01 && re==2'b01) || (we==2'b10 && re==2'b10) || (we==2'b11 && re==2'b11) )
				fifo_counter_reg <= fifo_counter_reg;
			else if( (we==2'b01 && re==2'b00) || (we==2'b10 && re==2'b01) || (we==2'b11 && re==2'b10) )
				fifo_counter_reg <= fifo_counter_reg+1;
			else if( (we==2'b10 && re==2'b00) || (we==2'b11 && re==2'b01) )
				fifo_counter_reg <= fifo_counter_reg+2;
			else if( we==2'b11 && re==2'b00 )
				fifo_counter_reg <= fifo_counter_reg+3;
			else
				fifo_counter_reg <= fifo_counter_reg;
		end else if( !buf_full && wclk ) begin
			if( we==2'b00 )
				fifo_counter_reg <= fifo_counter_reg+1;
			else if( we==2'b01 )
				fifo_counter_reg <= fifo_counter_reg+2;
			else if( we==2'b10 )
				fifo_counter_reg <= fifo_counter_reg+3;
			else if( we==2'b11 )
				fifo_counter_reg <= fifo_counter_reg+4;
			else
				fifo_counter_reg <= fifo_counter_reg;
		end else if( !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))||(buf_empty2&&(re==2'b10))||(buf_empty3&&(re==2'b11))) && rclk )
			if( re==2'b00 )
				fifo_counter_reg <= fifo_counter_reg-1;
			else if( re==2'b01 )
				fifo_counter_reg <= fifo_counter_reg-2;
			else if( re==2'b10 )
				fifo_counter_reg <= fifo_counter_reg-3;
			else if( re==2'b11 )
				fifo_counter_reg <= fifo_counter_reg-4;
			else
				fifo_counter_reg <= fifo_counter_reg;
		else
			fifo_counter_reg <= fifo_counter_reg;
	end

	always @( posedge rclk or posedge rst)
	begin
		if( rst ) begin
			buf_out_reg0 <= 0;
			buf_out_reg1 <= 0;
			buf_out_reg2 <= 0;
			buf_out_reg3 <= 0;
		end else
		begin
			if( rclk && !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))||(buf_empty2&&(re==2'b10))||(buf_empty3&&(re==2'b11))) )
				if( re==2'b00 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
				end else if( re==2'b01 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
					buf_out_reg1 <= buf_mem[ rd_ptr+1 ];
				end else if( re==2'b10 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
					buf_out_reg1 <= buf_mem[ rd_ptr+1 ];
					buf_out_reg2 <= buf_mem[ rd_ptr+2 ];
				end else if( re==2'b11 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
					buf_out_reg1 <= buf_mem[ rd_ptr+1 ];
					buf_out_reg2 <= buf_mem[ rd_ptr+2 ];
					buf_out_reg3 <= buf_mem[ rd_ptr+3 ];
				end else begin
					buf_out_reg0 <= buf_out_reg0;
					buf_out_reg1 <= buf_out_reg1;
					buf_out_reg2 <= buf_out_reg2;
					buf_out_reg3 <= buf_out_reg3;
				end
			else begin
				buf_out_reg0 <= buf_out_reg0;
				buf_out_reg1 <= buf_out_reg1;
				buf_out_reg2 <= buf_out_reg2;
				buf_out_reg3 <= buf_out_reg3;
			end
		end
	end

	always @(posedge wclk)
	begin
		if( wclk && !buf_full ) begin
			if( we==2'b00 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
			end else if( we==2'b01 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+1 ] <= buf_in1;
			end else if( we==2'b10 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+1 ] <= buf_in1;
				buf_mem[ wr_ptr+2 ] <= buf_in2;
			end else if( we==2'b11 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+1 ] <= buf_in1;
				buf_mem[ wr_ptr+2 ] <= buf_in2;
				buf_mem[ wr_ptr+3 ] <= buf_in3;
			end else
				buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
		end else
			buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
	end

	always@(posedge wclk or posedge rclk or posedge rst)
	begin
		if( rst )
		begin
			wr_ptr <= 0;
			rd_ptr <= 0;
		end
		else
		begin
			if( !buf_full && wclk ) begin
				if( we==2'b00 )
					wr_ptr <= wr_ptr + 1;
				else if( we==2'b01 )
					wr_ptr <= wr_ptr + 2;
				else if( we==2'b10 )
					wr_ptr <= wr_ptr + 3;
				else if( we==2'b11 )
					wr_ptr <= wr_ptr + 4;
				else
					wr_ptr <= wr_ptr;
			end else 
				wr_ptr <= wr_ptr;

			if( !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))||(buf_empty2&&(re==2'b10))||(buf_empty3&&(re==2'b11))) && rclk ) begin
				if( re==2'b00 )
					rd_ptr <= rd_ptr + 1;
				else if( re==2'b01 )
					rd_ptr <= rd_ptr + 2;
				else if( re==2'b10 )
					rd_ptr <= rd_ptr + 3;
				else if( re==2'b11 )
					rd_ptr <= rd_ptr + 4;
				else 
					rd_ptr <= rd_ptr;
			end else
				rd_ptr <= rd_ptr;
		end

	end
	
	assign buf_out0 = buf_out_reg0;
	assign buf_out1 = buf_out_reg1;
	assign buf_out2 = buf_out_reg2;
	assign buf_out3 = buf_out_reg3;
	assign fifo_counter = fifo_counter_reg;
	assign head_element_data0 = (fifo_counter_reg>=1) ? buf_mem[rd_ptr  ][31:0]  : 32'd0;
	assign head_element_data1 = (fifo_counter_reg>=2) ? buf_mem[rd_ptr+1][31:0]  : 32'd0;
	assign head_element_data2 = (fifo_counter_reg>=3) ? buf_mem[rd_ptr+2][31:0]  : 32'd0;
	assign head_element_data3 = (fifo_counter_reg>=4) ? buf_mem[rd_ptr+3][31:0]  : 32'd0;
	assign head_element_pc =    (fifo_counter_reg>=1) ? buf_mem[rd_ptr  ][63:32] : 32'd0;
	
endmodule
