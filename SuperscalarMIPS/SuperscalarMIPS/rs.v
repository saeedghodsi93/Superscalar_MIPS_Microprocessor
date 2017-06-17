
module rs #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 3) ( 
	input						wclk, rclk, rst,											// reset, system clock, write enable and read enable. 
	input  [1:0]				we,
	input  [DATA_WIDTH-1:0]		buf_in0, buf_in1, buf_in2, buf_in3,            				// data input to be pushed to buffer
	input						branch,
	input  [31:0]				branch_tag,
	output [DATA_WIDTH-1:0]		buf_out,													// port to output the data using pop.
	output						head_element_flag_a, head_element_flag_b,
	output [31:0]				head_element_data_a, head_element_data_b,
	output [DATA_WIDTH-1:0]		head_element,
	output						buf_empty, buf_full0, buf_full1, buf_full2, buf_full3,		// buffer empty and full indication	
	output [ADDR_WIDTH :0]		fifo_counter);												// number of data pushed in to buffer					  

	wire						buf_next_empty;
	reg    [DATA_WIDTH-1:0]		buf_out_reg;
	reg    [ADDR_WIDTH :0]		fifo_counter_reg; 
	reg    [ADDR_WIDTH-1:0]		rd_ptr, wr_ptr;												// pointers to read and write addresses  
	reg    [DATA_WIDTH-1:0]		buf_mem [0:(1<<ADDR_WIDTH)-1];
	wire   [DATA_WIDTH-1:0]		n_buf_mem [0:(1<<ADDR_WIDTH)-1];

	assign buf_empty = (fifo_counter_reg==0);
	assign buf_next_empty = (fifo_counter_reg<=1);
	assign buf_full0 = (fifo_counter_reg>=(1<<ADDR_WIDTH)  );
	assign buf_full1 = (fifo_counter_reg>=(1<<ADDR_WIDTH)-1);
	assign buf_full2 = (fifo_counter_reg>=(1<<ADDR_WIDTH)-2);
	assign buf_full3 = (fifo_counter_reg>=(1<<ADDR_WIDTH)-3);
	
	integer i;
	always @(posedge rst)
	begin
		if( rst )
		begin
			for (i=0; i<(1<<ADDR_WIDTH); i=i+1)
			begin 
				buf_mem[i] <= 0;
			end
		end
	end
	
	integer j;
	always @(posedge branch)
	begin
		if( branch )
		begin
			for (j=0; j<(1<<ADDR_WIDTH); j=j+1)
			begin 
				if(buf_mem[j][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag)
					buf_mem[j] <= 0;
			end
		end
	end
	
	integer k;
	always @(posedge wclk or posedge rclk or posedge rst or posedge branch)
	begin
		if( rst )
			fifo_counter_reg <= 0;
		else if( (!((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk) && (!buf_empty && rclk) )
			if( we==2'b00 )
				fifo_counter_reg <= fifo_counter_reg;
			else if( we==2'b01 )
				fifo_counter_reg <= fifo_counter_reg+4'd1;
			else if( we==2'b10 )
				fifo_counter_reg <= fifo_counter_reg+4'd2;
			else if( we==2'b11 )
				fifo_counter_reg <= fifo_counter_reg+4'd3;
			else
				fifo_counter_reg <= fifo_counter_reg;
		else if( !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk )
			if( we==2'b00 )
				fifo_counter_reg <= fifo_counter_reg+4'd1;
			else if( we==2'b01 )
				fifo_counter_reg <= fifo_counter_reg+4'd2;
			else if( we==2'b10 )
				fifo_counter_reg <= fifo_counter_reg+4'd3;
			else if( we==2'b11 )
				fifo_counter_reg <= fifo_counter_reg+4'd4;
			else
				fifo_counter_reg <= fifo_counter_reg;
		else if( !buf_next_empty && rclk && branch) begin
			if(buf_mem[wr_ptr-3'd1][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag)
				fifo_counter_reg <= fifo_counter_reg - 4'd1;
			else if(buf_mem[rd_ptr+3'd1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag)
				fifo_counter_reg <= 4'd0;
			else for (k=0; k<(1<<ADDR_WIDTH); k=k+1) begin
				if((buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag) && (buf_mem[k+1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag))
					fifo_counter_reg <= (k+3'd1-(rd_ptr+3'd1));
			end
		end else if( !buf_empty && rclk )
			fifo_counter_reg <= fifo_counter_reg - 4'd1;
		else if( !buf_empty && branch ) begin
			if(buf_mem[wr_ptr-3'd1][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag)
				fifo_counter_reg <= fifo_counter_reg;
			else if(buf_mem[rd_ptr][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag)
				fifo_counter_reg <= 4'd0;
			else for (k=0; k<(1<<ADDR_WIDTH); k=k+1) begin
				if((buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag) && (buf_mem[k+1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag))
					fifo_counter_reg <= (k+3'd1-rd_ptr);
			end
		end else
			fifo_counter_reg <= fifo_counter_reg;
		
	end

	always @( posedge rclk or posedge rst)
	begin
		if( rst )
			buf_out_reg <= 0;
		else
		begin
			if( rclk && !buf_empty )
				buf_out_reg <= buf_mem[rd_ptr];
			else
				buf_out_reg <= buf_out_reg;
		end
	end

	always @(posedge wclk)
	begin
		if( wclk && !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) )
			if( we==2'b00 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
			end else if( we==2'b01 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+3'd1 ] <= buf_in1;
			end else if( we==2'b10 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+3'd1 ] <= buf_in1;
				buf_mem[ wr_ptr+3'd2 ] <= buf_in2;
			end else if( we==2'b11 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+3'd1 ] <= buf_in1;
				buf_mem[ wr_ptr+3'd2 ] <= buf_in2;
				buf_mem[ wr_ptr+3'd3 ] <= buf_in3;
			end else
				buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
		else
			buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
	end

	integer l;
	always@(posedge wclk or posedge rclk or posedge rst or posedge branch)
	begin
		if( rst ) begin
			wr_ptr <= 3'd0;
			rd_ptr <= 3'd0;
		end else begin
			if( !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk )
				if( we==2'b00 )
					wr_ptr <= wr_ptr + 3'd1;
				else if( we==2'b01 )
					wr_ptr <= wr_ptr + 3'd2;
				else if( we==2'b10 )
					wr_ptr <= wr_ptr + 3'd3;
				else if( we==2'b11 )
					wr_ptr <= wr_ptr + 3'd4;
				else
					wr_ptr <= wr_ptr;
			else  
				wr_ptr <= wr_ptr;

			if( !buf_next_empty && rclk && branch) begin
				rd_ptr <= rd_ptr + 3'd1;
				if(buf_mem[wr_ptr-3'd1][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag)
						wr_ptr <= wr_ptr;
					else if(buf_mem[rd_ptr+3'd1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag)
						wr_ptr <= rd_ptr+3'd1;
					else for (k=0; k<(1<<ADDR_WIDTH); k=k+1) begin
						if((buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag) && (buf_mem[k+1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag))
							wr_ptr <= (k+3'd1);
					end
			end else if( !buf_empty && rclk )
				rd_ptr <= rd_ptr + 3'd1;
			else if( !buf_empty && branch ) begin
					if(buf_mem[wr_ptr-3'd1][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag)
						wr_ptr <= wr_ptr;
					else if(buf_mem[rd_ptr][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag)
						wr_ptr <= rd_ptr;
					else for (k=0; k<(1<<ADDR_WIDTH); k=k+1) begin
						if((buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]<branch_tag) && (buf_mem[k+1][DATA_WIDTH-2:DATA_WIDTH-33]>=branch_tag))
							wr_ptr <= (k+1);
					end
			end else
				rd_ptr <= rd_ptr;
				
		end

	end
	
	assign buf_out = buf_out_reg;
	assign fifo_counter = fifo_counter_reg;
	assign head_element_flag_a = (!buf_empty) ? buf_mem[rd_ptr][104] : 1'd0;
	assign head_element_flag_b = (!buf_empty) ? buf_mem[rd_ptr][71] : 1'd0;
	assign head_element_data_a = (!buf_empty) ? buf_mem[rd_ptr][103:72] : 32'd0;
	assign head_element_data_b = (!buf_empty) ? buf_mem[rd_ptr][70:39] : 32'd0;
	assign head_element = (!buf_empty) ? buf_mem[rd_ptr] : 144'd0;
	
	genvar m;        
	generate        
		for (m=0; m<(1<<ADDR_WIDTH); m=m+1) begin     
		  assign n_buf_mem[m] = buf_mem[m];
		end
	endgenerate
	
endmodule
