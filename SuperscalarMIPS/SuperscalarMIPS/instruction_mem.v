module instruction_mem(
	input  [31:0] A, JumpA,
	output [31:0] RD0, RD1, RD2, RD3,
	output [31:0] JumpRD0, JumpRD1, JumpRD2, JumpRD3);

	reg [31:0] mem_data [0:127];
	
	assign RD0 = mem_data[ A[31:2]        ];
	assign RD1 = mem_data[ A[31:2]+32'd1  ];
	assign RD2 = mem_data[ A[31:2]+32'd2  ];
	assign RD3 = mem_data[ A[31:2]+32'd3 ];

	assign JumpRD0 = mem_data[ JumpA[31:2]        ];
	assign JumpRD1 = mem_data[ JumpA[31:2]+32'd1  ];
	assign JumpRD2 = mem_data[ JumpA[31:2]+32'd2  ];
	assign JumpRD3 = mem_data[ JumpA[31:2]+32'd3 ];

endmodule

