module adder#(
parameter IMM_WIDTH0 = 5,
parameter REG_DATA_WIDTH = 16
)(
input [IMM_WIDTH0-1:0		 ]addend0,
input [REG_DATA_WIDTH-1:0]addend1,
output[REG_DATA_WIDTH-1:0]sum
);

assign sum = addend0 + addend1;

endmodule