
module rob #(parameter DATA_WIDTH = 70, parameter ADDR_WIDTH = 5) ( 
	input						clk, wclk, rclk, rst,													// reset, system clock, write enable and read enable. 
	input  [1:0]				we, re,
	input  [DATA_WIDTH-1:0]		buf_in0, buf_in1, buf_in2, buf_in3,            							// data input to be pushed to buffer
	input  [31:0]				para_wd0, para_wd1, para_wd2, para_wd3,
	input  [31:0]				para_wt0, para_wt1, para_wt2, para_wt3,
	input						para_wclk0, para_wclk1, para_wclk2, para_wclk3,
	input  [31:0]				para_rt0A, para_rt0B, para_rt1A, para_rt1B, para_rt2A, para_rt2B, para_rt3A, para_rt3B,
	input						branch, branch_resolved,
	input  [31:0]				branch_tag,
	output [DATA_WIDTH-1:0]		buf_out0, buf_out1,														// port to output the data using pop.
	output						head_element_flag0, head_element_flag1,									// flag of current element in the head of the queue
	output						head_element_zero0, head_element_zero1,									// indicating zero in the head of the queue
	output						buf_empty0, buf_empty1, buf_full0, buf_full1, buf_full2, buf_full3,		// buffer empty and full indication	
	output [31:0]				para_rd0A, para_rd0B, para_rd1A, para_rd1B, para_rd2A, para_rd2B, para_rd3A, para_rd3B,
	output						para_rf0A, para_rf0B, para_rf1A, para_rf1B, para_rf2A, para_rf2B, para_rf3A, para_rf3B);
	
	reg    [DATA_WIDTH-1:0]		buf_out_reg0, buf_out_reg1;
	reg    [ADDR_WIDTH :0]		fifo_counter;															// number of data pushed in to buffer	
	reg    [ADDR_WIDTH -1:0]	rd_ptr, wr_ptr;															// pointers to read and write addresses
	reg    [DATA_WIDTH-1:0]		buf_mem [0:(1<<ADDR_WIDTH)-1];
	wire   [DATA_WIDTH-1:0]		n_buf_mem [0:(1<<ADDR_WIDTH)-1];
	
	assign buf_empty0 = (fifo_counter<=0);
	assign buf_empty1 = (fifo_counter<=1);
	assign buf_full0 = (fifo_counter>=(1<<ADDR_WIDTH)  );
	assign buf_full1 = (fifo_counter>=(1<<ADDR_WIDTH)-1);
	assign buf_full2 = (fifo_counter>=(1<<ADDR_WIDTH)-2);
	assign buf_full3 = (fifo_counter>=(1<<ADDR_WIDTH)-3);
	
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
	always @(posedge branch_resolved)
	begin
		if( branch_resolved )
		begin
			for (j=0; j<(1<<ADDR_WIDTH); j=j+1)
			begin 
				if(buf_mem[j][DATA_WIDTH-2:DATA_WIDTH-33]==branch_tag)
					buf_mem[j] <= 0;
			end
		end
	end
	
	integer k;
	always @(posedge branch)
	begin
		if( branch )
		begin
			for (k=0; k<(1<<ADDR_WIDTH); k=k+1)
			begin 
				if(buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]>branch_tag)
					buf_mem[k] <= 0;
			end
		end
	end
	
	//always @(posedge wclk or posedge rclk or posedge rst or posedge branch)
	always @(posedge wclk or posedge rclk or posedge rst)
	begin
		if( rst )
			fifo_counter <= 0;
		/* else if( branch )
		begin
			for (k=0; k<(1<<ADDR_WIDTH); k=k+1)
			begin
				if((buf_mem[k][DATA_WIDTH-2:DATA_WIDTH-33]==branch_tag))
					fifo_counter <= (k-rd_ptr);
			end
		end */
		else if( (!((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk) && (!((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))) && rclk) )
			if( (we==2'b00 && re==2'b01) )
				fifo_counter <= fifo_counter-6'd1;
			else if( (we==2'b00 && re==2'b00) || (we==2'b01 && re==2'b01) )
				fifo_counter <= fifo_counter;
			else if( (we==2'b01 && re==2'b00) || (we==2'b10 && re==2'b01) )
				fifo_counter <= fifo_counter+6'd1;
			else if( (we==2'b10 && re==2'b00) || (we==2'b11 && re==2'b01) )
				fifo_counter <= fifo_counter+6'd2;
			else if( we==2'b11 && re==2'b00 )
				fifo_counter <= fifo_counter+6'd3;
			else
				fifo_counter <= fifo_counter;
		else if( !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk )
			if( we==2'b00 )
				fifo_counter <= fifo_counter+6'd1;
			else if( we==2'b01 )
				fifo_counter <= fifo_counter+6'd2;
			else if( we==2'b10 )
				fifo_counter <= fifo_counter+6'd3;
			else if( we==2'b11 )
				fifo_counter <= fifo_counter+6'd4;
			else
				fifo_counter <= fifo_counter;
		else if( !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))) && rclk )
			if( re==2'b00 )
				fifo_counter <= fifo_counter-6'd1;
			else if( re==2'b01 )
				fifo_counter <= fifo_counter-6'd2;
			else
				fifo_counter <= fifo_counter;
		else
			fifo_counter <= fifo_counter;
	end

	always @(posedge rclk or posedge rst)
	begin
		if( rst ) begin
			buf_out_reg0 <= 0;
			buf_out_reg1 <= 0;
		end else begin
			if( rclk && !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))) )
				if( re==2'b00 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
				end else if( re==2'b01 ) begin
					buf_out_reg0 <= buf_mem[ rd_ptr   ];
					buf_out_reg1 <= buf_mem[ rd_ptr+5'd1 ];
				end else begin
					buf_out_reg0 <= buf_out_reg0;
					buf_out_reg1 <= buf_out_reg1;
				end
			else begin
				buf_out_reg0 <= buf_out_reg0;
				buf_out_reg1 <= buf_out_reg1;
			end
		end
	end

	always @(posedge wclk)
	begin
		if( wclk && !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) )
			if( we==2'b00 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
			end else if( we==2'b01 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+5'd1 ] <= buf_in1;
			end else if( we==2'b10 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+5'd1 ] <= buf_in1;
				buf_mem[ wr_ptr+5'd2 ] <= buf_in2;
			end else if( we==2'b11 ) begin
				buf_mem[ wr_ptr   ] <= buf_in0;
				buf_mem[ wr_ptr+5'd1 ] <= buf_in1;
				buf_mem[ wr_ptr+5'd2 ] <= buf_in2;
				buf_mem[ wr_ptr+5'd3 ] <= buf_in3;
			end else
				buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
		else
			buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
	end

	integer l;
	//always@(posedge wclk or posedge rclk or posedge rst or posedge branch)
	always@(posedge wclk or posedge rclk or posedge rst)
	begin
		if( rst ) begin
			wr_ptr <= 0;
			rd_ptr <= 0;
		end
		/* else if( branch )
		begin
			for (l=0; l<(1<<ADDR_WIDTH); l=l+1)
			begin
				if((buf_mem[l][DATA_WIDTH-2:DATA_WIDTH-33]==branch_tag))
					wr_ptr <= l;
			end
		end */
		else begin if( !((buf_full0&&(we==2'b00))||(buf_full1&&(we==2'b01))||(buf_full2&&(we==2'b10))||(buf_full3&&(we==2'b11))) && wclk )
				if( we==2'b00 )
					wr_ptr <= wr_ptr + 5'd1;
				else if( we==2'b01 )
					wr_ptr <= wr_ptr + 5'd2;
				else if( we==2'b10 )
					wr_ptr <= wr_ptr + 5'd3;
				else if( we==2'b11 )
					wr_ptr <= wr_ptr + 5'd4;
				else
					wr_ptr <= wr_ptr;
			else  
				wr_ptr <= wr_ptr;

			if( !((buf_empty0&&(re==2'b00))||(buf_empty1&&(re==2'b01))) && rclk ) begin
				if( re==2'b00 )
					rd_ptr <= rd_ptr + 5'd1;
				else if( re==2'b01 )
					rd_ptr <= rd_ptr + 5'd2;
				else 
					rd_ptr <= rd_ptr;
			end else
				rd_ptr <= rd_ptr;
		end

	end
	
	always@(posedge clk)
	begin
		if( !rst ) begin
			if(para_wclk0) begin
				if((buf_mem[para_wt0[ADDR_WIDTH-1:0]][DATA_WIDTH-1]==1'b1) && (buf_mem[para_wt0[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_wt0)) begin
					buf_mem[para_wt0[ADDR_WIDTH-1:0]][DATA_WIDTH-1] <= 1'b0;
					buf_mem[para_wt0[ADDR_WIDTH-1:0]][31:0] <= para_wd0;
				end
				buf_mem[para_wt0[ADDR_WIDTH-1:0]][31:0] <= para_wd0;
			end	
			if(para_wclk1) begin
				if((buf_mem[para_wt1[ADDR_WIDTH-1:0]][DATA_WIDTH-1]==1'b1) && (buf_mem[para_wt1[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_wt1)) begin
					buf_mem[para_wt1[ADDR_WIDTH-1:0]][DATA_WIDTH-1] <= 1'b0;
					buf_mem[para_wt1[ADDR_WIDTH-1:0]][31:0] <= para_wd1;
				end
				buf_mem[para_wt1[ADDR_WIDTH-1:0]][31:0] <= para_wd1;
			end
			if(para_wclk2) begin
				if((buf_mem[para_wt2[ADDR_WIDTH-1:0]][DATA_WIDTH-1]==1'b1) && (buf_mem[para_wt2[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_wt2)) begin
					buf_mem[para_wt2[ADDR_WIDTH-1:0]][DATA_WIDTH-1] <= 1'b0;
					buf_mem[para_wt2[ADDR_WIDTH-1:0]][31:0] <= para_wd2;
				end
				buf_mem[para_wt2[ADDR_WIDTH-1:0]][31:0] <= para_wd2;
			end
			if(para_wclk3) begin
				if((buf_mem[para_wt3[ADDR_WIDTH-1:0]][DATA_WIDTH-1]==1'b1) && (buf_mem[para_wt3[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_wt3)) begin
					buf_mem[para_wt3[ADDR_WIDTH-1:0]][DATA_WIDTH-1] <= 1'b0;
					buf_mem[para_wt3[ADDR_WIDTH-1:0]][31:0] <= para_wd3;
				end
				buf_mem[para_wt3[ADDR_WIDTH-1:0]][31:0] <= para_wd3;
			end
		end
	
	end
	
	assign buf_out0 = buf_out_reg0;
	assign buf_out1 = buf_out_reg1;
	assign head_element_flag0 = buf_mem[rd_ptr     ][DATA_WIDTH-1];
	assign head_element_flag1 = buf_mem[rd_ptr+5'd1][DATA_WIDTH-1];
	assign head_element_zero0 = (buf_mem[rd_ptr]==70'd0);
	assign head_element_zero1 = (buf_mem[rd_ptr]==70'd0 && buf_mem[rd_ptr+5'd1]==70'd0);
	assign para_rd0A = (buf_mem[para_rt0A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt0A) ? buf_mem[para_rt0A[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rd0B = (buf_mem[para_rt0B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt0B) ? buf_mem[para_rt0B[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rf0A = (buf_mem[para_rt0A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt0A) ? buf_mem[para_rt0A[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rf0B = (buf_mem[para_rt0B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt0B) ? buf_mem[para_rt0B[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rd1A = (buf_mem[para_rt1A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt1A) ? buf_mem[para_rt1A[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rd1B = (buf_mem[para_rt1B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt1B) ? buf_mem[para_rt1B[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rf1A = (buf_mem[para_rt1A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt1A) ? buf_mem[para_rt1A[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rf1B = (buf_mem[para_rt1B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt1B) ? buf_mem[para_rt1B[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rd2A = (buf_mem[para_rt2A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt2A) ? buf_mem[para_rt2A[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rd2B = (buf_mem[para_rt2B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt2B) ? buf_mem[para_rt2B[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rf2A = (buf_mem[para_rt2A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt2A) ? buf_mem[para_rt2A[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rf2B = (buf_mem[para_rt2B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt2B) ? buf_mem[para_rt2B[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rd3A = (buf_mem[para_rt3A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt3A) ? buf_mem[para_rt3A[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rd3B = (buf_mem[para_rt3B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt3B) ? buf_mem[para_rt3B[ADDR_WIDTH-1:0]][31:0] : 32'd0;
	assign para_rf3A = (buf_mem[para_rt3A[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt3A) ? buf_mem[para_rt3A[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	assign para_rf3B = (buf_mem[para_rt3B[ADDR_WIDTH-1:0]][DATA_WIDTH-2:DATA_WIDTH-33]==para_rt3B) ? buf_mem[para_rt3B[ADDR_WIDTH-1:0]][DATA_WIDTH-1] : 1'd1;
	
	genvar m;        
	generate        
		for (m=0; m<(1<<ADDR_WIDTH); m=m+1) begin     
		  assign n_buf_mem[m] = buf_mem[m];
		end
	endgenerate
	
endmodule
