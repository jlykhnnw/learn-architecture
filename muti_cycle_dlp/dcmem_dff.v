
module dcmem_dff#(
parameter MEMAW	=	5,
parameter MEMDW	=	16,
parameter MEMN	=	32
)(
input 										Clk_i		,
input											Rst_n_i	,
//w
input 										MemWEn_i,
input [MEMAW-1:0]					MemAddr_i	,
input [MEMDW-1:0]					MemData_i	,
//r
output[MEMDW-1:0]					MemData_o
);

(* keep = "true" *)reg 	[MEMDW-1:0]RAM [MEMN-1:0];
wire	[MEMDW-1:0]datar_wire;
(* keep = "true" *)reg		[MEMDW-1:0]datar_reg;

//read
assign datar_wire = RAM[MemAddr_i];

//datar_reg
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		datar_reg <= 0;
	else
		datar_reg	<= datar_wire;
end

//MemData_o
assign MemData_o = datar_reg;

//write
always@(posedge Clk_i)begin
	if (MemWEn_i)
		RAM[MemAddr_i] <= MemData_i;
	else
		RAM[MemAddr_i] <= RAM[MemAddr_i];
end

endmodule