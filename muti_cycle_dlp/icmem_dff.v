
module icmem_dff #(
parameter PCW  = 16,
parameter ISAW = 16
)(
input 	wire					Clk_i			,
input 	wire					Rst_n_i		,
input 	wire[PCW -1:0]Addr_i 		,
input		wire					ML_en_i		,
output  reg [ISAW-1:0]InsCurr_o	,
output  reg [ISAW-1:0]InsNext_o
);
wire [ISAW-1:0] inst_wire1;
wire [ISAW-1:0] inst_wire2;

rom #(.AW(16),.DW(16)) x_rom(
	.RAddr1_i (Addr_i				),
	.RData1_o	(inst_wire1		),
	.RAddr2_i	((Addr_i+1)		),
	.RData2_o	(inst_wire2		)
);

//InsNext_o
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		InsNext_o <= 0;
	else if(ML_en_i)
		InsNext_o <= inst_wire2;
	else
		InsNext_o <= inst_wire1;
end

//InsCurr_o
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		InsCurr_o <= 0;
	else if(ML_en_i)
		InsCurr_o <= inst_wire1;
	else
		InsCurr_o <= InsNext_o;
end

endmodule