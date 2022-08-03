
module ctrl#(
parameter OPCODE_WIDTH = 3
)(
	input [OPCODE_WIDTH-1:0]opcode,
	output reg							RegWEn,
	output reg							MemWEn
);
parameter  LOAD 	= 3'b000;
parameter  STORE 	= 3'b001;
parameter  MOV 		= 3'b010;
parameter  MAC 		= 3'b100;
always @(*)begin
	case(opcode)
		LOAD 		:{RegWEn,MemWEn} = 2'b10;
		STORE		:{RegWEn,MemWEn} = 2'b01;
		MOV 		:{RegWEn,MemWEn} = 2'b10;
		MAC 		:{RegWEn,MemWEn} = 2'b10;
		default	:{RegWEn,MemWEn} = 2'b00;
	endcase
end

endmodule