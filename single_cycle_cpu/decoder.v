module decoder#(
parameter ISA_WIDTH = 16,
parameter REG_ADDR_WIDTH = 4,
parameter OPCODE_WIDTH = 3,
parameter IMM_WIDTH0 = 5,
parameter IMM_WIDTH1 = 9
)(
input [ISA_WIDTH-1:0]					inst		,
output reg[REG_ADDR_WIDTH-1:0]rd			,
output reg[REG_ADDR_WIDTH-1:0]rs1			,
output reg[REG_ADDR_WIDTH-1:0]rs2			,
output reg[IMM_WIDTH0-1:0]		imm0		,
output reg[IMM_WIDTH1-1:0]		imm1		,
output reg 										funct		,
output reg[OPCODE_WIDTH-1:0]	opcode
);

parameter  LOAD 	= 3'b000;
parameter  STORE 	= 3'b001;
parameter  MOV 		= 3'b010;
parameter  MAC 		= 3'b100;

assign opcode = inst[ISA_WIDTH-1:ISA_WIDTH-3];

always @(*)begin
	case(opcode)
		LOAD 		:{rd,rs1,imm0} 								= inst[ISA_WIDTH-4:0];
		STORE		:{rs1,rs2}										= inst[ISA_WIDTH-4:ISA_WIDTH-11];
		MOV 		:{rd,imm1}										= inst[ISA_WIDTH-4:0];
		MAC 		:{rd,rs1,rs2,funct} = (inst[0] == 1'b0)? inst[ISA_WIDTH-4:0] : {inst[ISA_WIDTH-4:ISA_WIDTH-7], 4'b0000, inst[ISA_WIDTH-8:ISA_WIDTH-11], inst[0]};
		default	:{rd,rs1,rs2,imm0,imm1,funct} = {0,0,0,0,0,0};
	endcase
end

endmodule