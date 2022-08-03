module icmem #(
parameter PC_WIDTH=16,
parameter ISA_WIDTH=16
)(
input 								clk					,
input 								rst_n				,
input 								inst_wen		,
input [ISA_WIDTH 1:0]input_inst	,
output[ISA_WIDTH 1:0]current_inst
);
reg [PC_WIDTH-1:0] pc;
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		pc <= 0;
	else
		pc <= pc + 1;
end

//icmem write or read
dcmem inst_mem1(
. clk		(clk					),
. MemWEn(inst_wen			),
. addr 	(pc						),
. dataw	(input_inst		),
. datar	(current_inst	)
);


endmodule