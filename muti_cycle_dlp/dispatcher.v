
module dispatcher #(
parameter PCW  = 16,
parameter ISAW = 16
)(
input 	wire					Clk_i				,
input 	wire					Rst_n_i			,
input		wire					ML_en_i			,
output	reg [PCW-1:0]	PC_o
);

//PC_o
always@(posedge Clk_i or negedge Rst_n_i) begin
	if (~Rst_n_i)
		PC_o <= 0;
	else if(ML_en_i)
		PC_o <= PC_o + 2;
	else
		PC_o <= PC_o + 1;
end

endmodule