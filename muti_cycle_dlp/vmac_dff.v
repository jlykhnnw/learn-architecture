
module vmac_dff #(
parameter VECW = 32,
parameter DW = 8,
parameter SPW = 20,
parameter AW = 4
)(
input 								Clk_i		,
input 								Rst_n_i	,
input [AW-1:0]				Funct4_i	,
input [ VECW-1:0]			Vec1_i	,
input [ VECW-1:0]			Vec2_i	,
output[ VECW-1:0]			Vec3_o
);

wire[ VECW-1 : 0]vec3_wire;
(* keep = "true" *)(* keep = "true" *)reg [ VECW-1 : 0]vec3_reg;

wire signed [2*DW-1 : 0] 		result0;
wire signed [2*DW-1 : 0] 		result1;
wire signed [2*DW-1 : 0] 		result2;
wire signed [2*DW-1 : 0] 		result3;
wire signed [DW-1 : 0] 			bias_o;
wire signed [SPW-1 : 0]accum;

wire signed[VECW-1  : 0]				scratch_pad_i;
(* keep = "true" *)(* keep = "true" *)reg 				[VECW-1 : 0] 			 	bias;										//

(* keep = "true" *)(* keep = "true" *)reg signed[SPW-1 : 0]	scratch_pad0;
(* keep = "true" *)(* keep = "true" *)reg signed[SPW-1 : 0]	scratch_pad1;
(* keep = "true" *)(* keep = "true" *)reg signed[SPW-1 : 0]	scratch_pad2;


wire signed [SPW-1 : 0]scratch_pad0_o;
wire signed [SPW-1 : 0]scratch_pad1_o;
wire signed [SPW-1 : 0]scratch_pad2_o;
wire signed [SPW-1 : 0]scratch_pad3_o;

wire signed [DW-1 : 0] vec1_0 = Vec1_i[1*DW-1:0*DW];
wire signed [DW-1 : 0] vec1_1 = Vec1_i[2*DW-1:1*DW];
wire signed [DW-1 : 0] vec1_2 = Vec1_i[3*DW-1:2*DW];
wire signed [DW-1 : 0] vec1_3 = Vec1_i[4*DW-1:3*DW];

wire signed [DW-1 : 0] vec2_0 = Vec2_i[1*DW-1:0*DW];
wire signed [DW-1 : 0] vec2_1 = Vec2_i[2*DW-1:1*DW];
wire signed [DW-1 : 0] vec2_2 = Vec2_i[3*DW-1:2*DW];
wire signed [DW-1 : 0] vec2_3 = Vec2_i[4*DW-1:3*DW];




//multiply operation
assign result0 = vec1_0 * vec2_0;
assign result1 = vec1_1 * vec2_1;
assign result2 = vec1_2 * vec2_2;
assign result3 = vec1_3 * vec2_3;

//add operation
assign accum	 = result0 + result1 + result2 + result3 + bias_o;

//scratch_pad_i
assign scratch_pad_i = (Funct4_i==4'b1000)? Vec1_i : {12'h0,accum};

//bias
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		bias <= {VECW{1'b0}};
	else if(Funct4_i==4'b1000)
		bias <= scratch_pad_i;
	else;
end

//scratch_pad0
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		scratch_pad0 <= {SPW{1'b0}};
	else if(Funct4_i==4'b0000)
		scratch_pad0 <= scratch_pad_i;
	else;
end

//scratch_pad1
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		scratch_pad1 <= {SPW{1'b0}};
	else if(Funct4_i==4'b0001)
		scratch_pad1 <= scratch_pad_i;
	else;
end

//scratch_pad2
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		scratch_pad2 <= {SPW{1'b0}};
	else if(Funct4_i==4'b0010)
		scratch_pad2 <= scratch_pad_i;
	else;
end

//bias_o
assign bias_o =  (Funct4_i==4'b0000)? bias[1*DW-1:0*DW] : 
								((Funct4_i==4'b0001)? bias[2*DW-1:1*DW] :
								((Funct4_i==4'b0010)? bias[3*DW-1:2*DW] :
								(((Funct4_i==4'b0111)||(Funct4_i==4'b1111))? bias[4*DW-1:3*DW] :
								{DW{1'b0}})));
								

//output
assign scratch_pad0_o = ((Funct4_i==4'b0111)||(Funct4_i==4'b1111))? scratch_pad0 	: {SPW{1'b0}};
assign scratch_pad1_o = ((Funct4_i==4'b0111)||(Funct4_i==4'b1111))? scratch_pad1 	: {SPW{1'b0}};
assign scratch_pad2_o = ((Funct4_i==4'b0111)||(Funct4_i==4'b1111))? scratch_pad2 	: {SPW{1'b0}};
assign scratch_pad3_o = ((Funct4_i==4'b0111)||(Funct4_i==4'b1111))? scratch_pad_i[19:0] : {SPW{1'b0}};

parameter m=8;
//relu activation,trauncate
assign vec3_wire = (Funct4_i==4'b0111)?{((scratch_pad3_o[19] == 1'b1)? {DW{1'b0}} : scratch_pad3_o[SPW-m:SPW-m-7]),
										((scratch_pad2_o[19] == 1'b1)? {DW{1'b0}} : scratch_pad2_o[SPW-m:SPW-m-7]),
										((scratch_pad1_o[19] == 1'b1)? {DW{1'b0}} : scratch_pad1_o[SPW-m:SPW-m-7]),
										((scratch_pad0_o[19] == 1'b1)? {DW{1'b0}} : scratch_pad0_o[SPW-m:SPW-m-7])}:
										((Funct4_i==4'b1111)?{scratch_pad3_o[SPW-1],scratch_pad3_o[SPW-m-1:SPW-m-7],scratch_pad2_o[SPW-1],scratch_pad2_o[SPW-m-1:SPW-m-7],scratch_pad1_o[SPW-1],scratch_pad1_o[SPW-m-1:SPW-m-7],scratch_pad0_o[SPW-1],scratch_pad0_o[SPW-m-1:SPW-m-7]}:
										{DW{1'b0}});

//vec3_reg
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		vec3_reg <= {VECW{1'b0}};
	else
		vec3_reg <= vec3_wire;
end

//Vec3_o
assign Vec3_o = vec3_reg;

endmodule