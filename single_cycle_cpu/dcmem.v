module dcmem #(
parameter MEM_ADDR_WIDTH=5,
parameter MEM_DATA_WIDTH=16,
parameter MEM_NUMBER=32
)(
input 										clk		,
input 										MemWEn,
input [MEM_ADDR_WIDTH-1:0]addr	,
input [MEM_DATA_WIDTH-1:0]dataw	,
output[MEM_DATA_WIDTH-1:0]datar
);

reg 	[MEM_DATA_WIDTH-1:0]RAM [MEM_NUMBER-1:0];

//read
assign datar = RAM[addr];

//write
always@(posedge clk)begin
	if (MemWEn) 
		RAM[addr]<=dataw;
	else;
end

endmodule