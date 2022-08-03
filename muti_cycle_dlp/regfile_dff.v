
module regfile_dff #(
parameter REGAW = 4,
parameter REGDW = 16,
parameter REGN = 16
)
(
input 										Clk_i			,
input											Rst_n_i		,
//w
input 										RegWEn	,
input	[REGAW-1:0]					RdAddr_i	,
input [REGDW-1:0]					RdData_i ,
//r1
input	[REGAW-1:0]					Rs1Addr_i,
output[REGDW-1:0]					Rs1Data_o,
//r2
input	[REGAW-1:0]					Rs2Addr_i,
output[REGDW-1:0]					Rs2Data_o
);

(* keep = "true" *)reg [REGDW-1:0]rf [REGN-1:0];
wire[REGDW-1:0]rs1_data_wire;
wire[REGDW-1:0]rs2_data_wire;
(* keep = "true" *)reg	[REGDW-1:0]rs1_data_reg;
(* keep = "true" *)reg	[REGDW-1:0]rs2_data_reg;

/*port1*/
//rs1_data_wire
assign rs1_data_wire = rf[Rs1Addr_i];

//rs1_data_reg
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		rs1_data_reg <= 0;
	else
		rs1_data_reg <= rs1_data_wire;
end

//Rs1Data_o
assign Rs1Data_o = rs1_data_reg;

/*port2*/
//rs2_data_wire
assign rs2_data_wire = rf[Rs2Addr_i];

//rs2_data_reg
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		rs2_data_reg <= 0;
	else
		rs2_data_reg <= rs2_data_wire;
end

//Rs2Data_o
assign Rs2Data_o = rs2_data_reg;


/*port3*/
//rf
always@(posedge Clk_i or negedge Rst_n_i) begin
	if (~Rst_n_i) begin
		rf[ 0] <= 0;
		rf[ 1] <= 0;
		rf[ 2] <= 0;
		rf[ 3] <= 0;
		rf[ 4] <= 0;
		rf[ 5] <= 0;
		rf[ 6] <= 0;
		rf[ 7] <= 0;
		rf[ 8] <= 0;
		rf[ 9] <= 0;
		rf[10] <= 0;
		rf[11] <= 0;
		rf[12] <= 0;
		rf[13] <= 0;
		rf[14] <= 0;
		rf[15] <= 0;
	end
	else if (RegWEn)
		rf[RdAddr_i] <= RdData_i;
	else
		rf[RdAddr_i] <= rf[RdAddr_i];
end

endmodule