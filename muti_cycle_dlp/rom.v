
module rom #(
parameter AW = 16,
parameter DW = 16,
parameter DN = 512
)(
//port1
input 	[AW-1:0]RAddr1_i,
output 	[DW-1:0]RData1_o,
//port2                 
input 	[AW-1:0]RAddr2_i,
output 	[DW-1:0]RData2_o
);

(* keep = "true" *)reg [DW-1:0]mem[DN-1:0];

//RData1_o
assign RData1_o = mem[RAddr1_i];

//RData1_o
assign RData2_o = mem[RAddr2_i];

endmodule 