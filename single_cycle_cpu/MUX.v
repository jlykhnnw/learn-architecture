module MUX#(
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
	input 		[1:0] 								S,
	input 		[REG_DATA_WIDTH-1:0]	A,
	input 		[REG_DATA_WIDTH-1:0]	B,
	input 		[REG_DATA_WIDTH-1:0]	C,
	input 		[REG_DATA_WIDTH-1:0]	D,
	output reg[REG_DATA_WIDTH-1:0]	Y
);

always@(*) begin
	case(S)
		2'b00		:Y = A;
		2'b01		:Y = B;
		2'b10		:Y = C;
		2'b11		:Y = D;
		default	:Y = A;
	endcase
end

endmodule