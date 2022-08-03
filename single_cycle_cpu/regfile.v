module regfile #(
parameter REG_ADDR_WIDTH = 4,
parameter REG_DATA_WIDTH = 16,
parameter REG_NUMBER = 16
)
(
input [REG_ADDR_WIDTH-1:0]rs1_addr,
input [REG_ADDR_WIDTH-1:0]rs2_addr,
input [REG_ADDR_WIDTH-1:0]rd_addr	,
input [REG_DATA_WIDTH-1:0]rd_data	,
input 										RegWEn	,
input 										clk			,
input											rst_n			,
output[REG_DATA_WIDTH-1:0]rs1_data,
output[REG_DATA_WIDTH-1:0]rs2_data
);
reg 	[REG_DATA_WIDTH-1:0]rf [REG_NUMBER-1:0];

//read combination logic
assign rs1_data = (rs1_addr==0) ? 0:rf[rs1_addr];
assign rs2_data = (rs2_addr==0) ? 0:rf[rs2_addr];

//write sequential logic
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		begin
			integer i;
			for (i=0;i<REG_NUMBER;i=i+1) begin
				rf[i] <=0;
			end
		end
	else if (RegWEn && rd_addr != 0)
		rf[rd_addr] <= rd_data;
	else;
end

endmodule