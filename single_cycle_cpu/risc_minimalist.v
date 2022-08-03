//wk2021/03/30
module risc_minimalist#(
parameter ISA_WIDTH=16,
parameter REG_ADDR_WIDTH = 4,
parameter REG_DATA_WIDTH = 16,
parameter OPCODE_WIDTH = 3,
parameter IMM_WIDTH0 = 5,
parameter IMM_WIDTH1 = 9,
parameter MEM_ADDR_WIDTH=5,
parameter MEM_DATA_WIDTH=16,
parameter MEM_NUMBER=32
)(
input 								Clk_i			,
input 								Rst_n_i		,
input 								Inst_wen_i,
input[ISA_WIDTH-1:0]Input_inst_i
);
parameter MUX0_PADD_WORD = {MEM_ADDR_WIDTH{1'b0}};
parameter MUX1_PADD_WORD = {REG_DATA_WIDTH{1'b0}};
wire[ISA_WIDTH-1:0] 			current_inst_s;
wire[REG_ADDR_WIDTH-1:0]	rd_s					;
wire[REG_ADDR_WIDTH-1:0]	rs1_s		  		;
wire[REG_ADDR_WIDTH-1:0]	rs2_s		  		;
wire[IMM_WIDTH0-1:0]			imm0_s				;
wire[IMM_WIDTH1-1:0]			imm1_s				;
wire 											funct_s	  		;
wire[OPCODE_WIDTH-1:0]		opcode_s  		;
wire[REG_DATA_WIDTH-1:0]	rs1_data_s		;
wire[REG_DATA_WIDTH-1:0]	rs2_data_s		;
wire[REG_DATA_WIDTH-1:0]	rd_mac_s			;
wire[MEM_ADDR_WIDTH-1:0]	sum_s					;
wire[REG_DATA_WIDTH-1:0]	mux1_out_s		;
wire[MEM_ADDR_WIDTH-1:0]	mux0_out_s		;
wire[MEM_DATA_WIDTH-1:0]	datar_s				;
wire											RegWEn_s			;			
wire											MemWEn_s			;

ctrl x_ctrl(
	.opcode(opcode_s),
	.RegWEn(RegWEn_s),
	.MemWEn(MemWEn_s)
);

icmem x_icmem(
	.clk					(Clk_i					),
	.rst_n				(Rst_n_i				),
	.inst_wen		  (Inst_wen_i			),
	.input_inst	  (Input_inst_i		),
	.current_inst (current_inst_s	)
);

decoder x_decoder(
	.inst		(current_inst_s	),
	.rd			(rd_s					 	),
	.rs1		(rs1_s				 	),
	.rs2		(rs2_s				 	),
	.imm0		(imm0_s				 	),
	.imm1		(imm1_s				 	),
	.funct	(funct_s				),
	.opcode	(opcode_s				)
);

regfile x_regfile(
	.rs1_addr	(rs1_s			),
	.rs2_addr (rs2_s			),
	.rd_addr	(rd_s				),
	.rd_data	(mux1_out_s	),
	.RegWEn	  (RegWEn_s		),
	.clk			(Clk_i			),
	.rst_n		(Rst_n_i		),
	.rs1_data (rs1_data_s	),
	.rs2_data	(rs2_data_s	)
);

MAC_ALU x_MAC_ALU(
	.funct	(funct_s		),
	.clk		(Clk_i			),	
	.opcode	(opcode_s		),
	.rs1		(rs1_data_s	),	
	.rs2		(rs2_data_s	),	
	.rd   	(rd_mac_s		)
);

adder x_adder(
	.addend0(imm0_s			),
	.addend1(rs1_data_s	),
	.sum    (sum_s			)
);

MUX x_mux0(
	.S(opcode_s[1:0]	),
	.A(sum_s					),
	.B(rs1_data_s			),
	.C(MUX0_PADD_WORD	),
	.D(MUX0_PADD_WORD	),
	.Y(mux0_out_s			)
);

MUX x_mux1(
	.S(opcode_s[2:1]	),
	.A(datar_s				),
	.B(imm1_s					),
	.C(rd_mac_s				),
	.D(MUX1_PADD_WORD	),
	.Y(mux1_out_s			)
);

dcmem x_dcmem(
	.clk		(Clk_i			),
	.MemWEn	(MemWEn_s		),
	.addr		(mux0_out_s	),
	.dataw	(rs2_data_s	),
	.datar  (datar_s		)
);

endmodule