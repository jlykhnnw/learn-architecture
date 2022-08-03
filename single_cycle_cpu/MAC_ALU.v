
module MAC_ALU #(
parameter REG_DATA_WIDTH=16,
parameter OPCODE_WIDTH = 3
)(
input 										funct	,
input											clk		,
input	[OPCODE_WIDTH-1:0]	opcode,
input [REG_DATA_WIDTH-1:0]rs1		,
input [REG_DATA_WIDTH-1:0]rs2		,
output[REG_DATA_WIDTH-1:0]rd
);
wire[REG_DATA_WIDTH-1:0] product;
wire[REG_DATA_WIDTH-1:0] addend1;
wire[REG_DATA_WIDTH-1:0] addend2;
reg	[REG_DATA_WIDTH-1:0] psum		;

assign product = $signed(rs1) * $signed(rs2);
assign addend1 = funct ? 0 	: product;
assign addend2 = funct ? rs2: psum;
assign rd = addend1 + addend2;

always @(posedge clk) begin
	if(opcode == 3'b100)
		psum <= rd；
	else;
end

endmodule