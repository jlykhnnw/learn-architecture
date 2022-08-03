
module mux2s1 #(
parameter DW = 16,
parameter SW = 1
)(
input					S,
input	[DW-1:0]A,
input [DW-1:0]B,
output[DW-1:0]Y
);
assign Y = S ? B : A;
endmodule