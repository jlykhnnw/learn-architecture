module decode#(
parameter ISAW		= 16,
parameter OPW 		= 3 ,

parameter REGAW 	= 4 ,
parameter REGDW 	= 16,
parameter VREGAW 	= 3,

parameter IMMW5 	= 5 ,
parameter IMMW8 	= 8 ,

parameter MEMAW 		= 5 ,
parameter MEMDW 		= 16,
parameter MEMN			= 32,

parameter MOV 			= 3'b000,
parameter M_MOV 		= 3'b001,

parameter VLOAD 		= 3'b010,
parameter M_VLOAD 	= 3'b011,

parameter VSTORE 		= 3'b100,
parameter M_VSTORE 	= 3'b101,

parameter VMAC			= 3'b110,
parameter M_VMAC		= 3'b111
)(

input							Clk_i			,
input							Rst_n_i		,
input [ISAW-1	 :0]Inst_c_i	,
input [ISAW-1	 :0]Inst_n_i	,

//Multiply Launch 
output reg				ML_en_o		,

//Ctrl
output 						Mux2_s_o 	,
output						VRegwen_o	,
output						Dcmwen_o 	,
output						VDcmwen_o	,
output 						Mux1_s_o	,
output 						Funct1_o	,
output[3:0] 			Funct4_o	,
output						Regwen_o 	,
output[REGAW-1 :0]RdAddr_o	,
output[REGAW-1 :0]RsAddr_o	,
output[VREGAW-1:0]VRdAddr_o	,
output[VREGAW-1:0]VRs1Addr_o,
output[VREGAW-1:0]VRs2Addr_o,
output[IMMW8-1 :0]Imm8_o		,
output[IMMW5-1 :0]Imm5_o
);

//decode
wire 		[OPW-1:0]			 opcode_c	;
wire 		[OPW-1:0]			 opcode_n	;
(* keep = "true" *)reg[REGAW-1 :0]RdAddr		;
(* keep = "true" *)reg[REGAW-1 :0]RsAddr		;

(* keep = "true" *)reg[VREGAW-1:0]VRs1Addr	;
(* keep = "true" *)reg[VREGAW-1:0]VRs2Addr	;
(* keep = "true" *)reg[IMMW8-1 :0]Imm8			;

//access_mem
(* keep = "true" *)reg[IMMW5-1 :0]Imm5			;
(* keep = "true" *)reg[IMMW5-1 :0]Imm5_d		;
(* keep = "true" *)reg						 Dcmwen 	;
(* keep = "true" *)reg						 Dcmwen_d ;
(* keep = "true" *)reg						 VDcmwen	;
(* keep = "true" *)reg						 VDcmwen_d;

//execute
(* keep = "true" *)reg 					Funct1		;
(* keep = "true" *)reg[3:0] 			Funct4		;
(* keep = "true" *)reg[3:0] 			Funct4_d	;

//write_back
(* keep = "true" *)reg 					Mux1_s		;
(* keep = "true" *)reg 					Mux2_s 		;
(* keep = "true" *)reg 					Mux2_s_d 	;
(* keep = "true" *)reg 					Mux2_s_2d ;
(* keep = "true" *)reg 					Mux2_s_3d ;
(* keep = "true" *)reg						Regwen 		;
(* keep = "true" *)reg						VRegwen		;
(* keep = "true" *)reg						VRegwen_d	;
(* keep = "true" *)reg						VRegwen_2d;
(* keep = "true" *)reg						VRegwen_3d;

(* keep = "true" *)reg[VREGAW-1:0]VRdAddr		;
(* keep = "true" *)reg[VREGAW-1:0]VRdAddr_d	;
(* keep = "true" *)reg[VREGAW-1:0]VRdAddr_2d;
(* keep = "true" *)reg[VREGAW-1:0]VRdAddr_3d;

//opcode_c
assign opcode_c = Inst_c_i[ISAW-1:ISAW-3];

//opcode_n
assign opcode_n = Inst_n_i[ISAW-1:ISAW-3];

//ML_en_o
always @(*) begin
	case(opcode_c)
		MOV 		:ML_en_o = 1'b0;
		VLOAD 	:ML_en_o = 1'b0;
		VSTORE 	:ML_en_o = 1'b0;
		VMAC		:ML_en_o = 1'b0;
    M_VLOAD	:ML_en_o = (Inst_n_i[3:0] == 4'b1000) && (opcode_n == VMAC);
		default :ML_en_o = 1'b0;
	endcase
end

/*decode*/
always @(*)begin
		case(opcode_c)
			MOV 		:	begin
									RdAddr[3:0] 	= Inst_c_i[12:9];
									Imm8[7:0]			= Inst_c_i[8:1];
									Funct1				= Inst_c_i[0];
									Mux1_s      	= 1'b1;
									Regwen      	= 1'b1;
									VRdAddr[2:0] 	= 3'b000;
									VRs1Addr[2:0] = 3'b000;
									VRs2Addr[2:0] = 3'b000;
									Funct4  [3:0] = 4'b0000;
									Imm5	 [4:0] 	= 5'b00000;
									RsAddr [3:0] 	= 4'b0000;
									Mux2_s 				= 1'b0;
									VRegwen	      = 1'b0;
									Dcmwen 	      = 1'b0;
									VDcmwen	      = 1'b0;	
								end
			VLOAD		:	begin
									VRdAddr[2:0] = Inst_c_i[12:10];
									RsAddr [3:0] = Inst_c_i[9:6];
									Imm5	 [4:0] = Inst_c_i[5:1];
									Mux2_s 				= 1'b0;
									VRegwen				= 1'b1;
									//other
									Mux1_s      	= 1'b0;
									Regwen      	= 1'b0;
									RdAddr[3:0] 	= 4'b0000;
									Imm8[7:0]			= 8'h00;
									Funct1				= 1'b0;
									VRs1Addr[2:0] = 3'b000;
									VRs2Addr[2:0] = 3'b000;
									Funct4  [3:0] = 4'b0000;
									Dcmwen 				= 1'b0;
									VDcmwen				= 1'b0;
								end
			VSTORE	: begin
									Imm5	 [4:0] = Inst_c_i[12:8];
									RsAddr [3:0] = Inst_c_i[7:4];
									VRs1Addr[2:0]= Inst_c_i[3:1];
									VDcmwen	      = 1'b1;
									//other
									Mux1_s      	= 1'b0;
									Regwen      	= 1'b0;
									RdAddr[3:0] 	= 4'b0000;
									Imm8[7:0]			= 8'h00;
									Funct1				= 1'b0;
									VRdAddr[2:0] 	= 3'b000;
									VRs2Addr[2:0] = 3'b000;
									Funct4  [3:0] = 4'b0000;	
									Mux2_s 				= 1'b0;     
									VRegwen	      = 1'b0;
									Dcmwen 	      = 1'b0;	
								end
			VMAC		:	begin
									if((Inst_c_i[3:0] == 4'b0000) || (Inst_c_i[3:0] == 4'b0001) || (Inst_c_i[3:0] == 4'b0010))begin
										Funct4  [3:0] = Inst_c_i[3:0];
										VRs1Addr[2:0] = Inst_c_i[9:7];
										VRs2Addr[2:0] = Inst_c_i[6:4];
										//others
										VRdAddr[2:0] 	= 3'b000;
										RdAddr[3:0] 	= 4'b0000;
										Imm8[7:0]			= 8'h00;
										Funct1				= 1'b0;
										Mux1_s      	= 1'b0;
										Regwen      	= 1'b0;
										RsAddr [3:0] 	= 4'b0000;
										Imm5	 [4:0] 	= 5'b00000;
										Mux2_s 				= 1'b0;
										VRegwen	      = 1'b0;
										Dcmwen 	      = 1'b0;
										VDcmwen				= 1'b0;					
									end
									else if((Inst_c_i[3:0] == 4'b0111)||(Inst_c_i[3:0] == 4'b1111))begin
										Funct4  [3:0] = Inst_c_i[3:0];
										VRdAddr[2:0] 	= Inst_c_i[12:10];
										VRs1Addr[2:0] = Inst_c_i[9:7];
										VRs2Addr[2:0] = Inst_c_i[6:4];
										Mux2_s 				= 1'b1;
										VRegwen	      = 1'b1;
										//others
										RdAddr[3:0] 	= 4'b0000;
										Imm8[7:0]			= 8'h00;
										Funct1				= 1'b0;
										Mux1_s      	= 1'b0;
										Regwen      	= 1'b0;
										RsAddr [3:0] 	= 4'b0000;
										Imm5	 [4:0] 	= 5'b00000;
										Dcmwen 	      = 1'b0;
										VDcmwen				= 1'b0;					
									end
									else if(Inst_c_i[3:0] == 4'b1000)begin
										Funct4  [3:0] = Inst_c_i[3:0];
										VRs1Addr[2:0] = Inst_c_i[9:7];
										//others
										VRs2Addr[2:0] = 3'b000;
										VRdAddr[2:0] 	= 3'b000;
										RdAddr[3:0] 	= 4'b0000;
										Imm8[7:0]			= 8'h00;
										Funct1				= 1'b0;
										Mux1_s      	= 1'b0;
										Regwen      	= 1'b0;
										RsAddr [3:0] 	= 4'b0000;
										Imm5	 [4:0] 	= 5'b00000;
										Mux2_s 				= 1'b0;
										VRegwen	      = 1'b0;
										Dcmwen 	      = 1'b0;
										VDcmwen				= 1'b0;					
									end
									else begin
										Funct4  [3:0] = 4'b0000;
										VRdAddr[2:0] 	= 3'b000;
										VRs1Addr[2:0] = 3'b000;
										VRs2Addr[2:0] = 3'b000;
										RdAddr[3:0] 	= 4'b0000;
										Imm8[7:0]			= 8'h00;
										Funct1				= 1'b0;
										Mux1_s      	= 1'b0;
										Regwen      	= 1'b0;
										RsAddr [3:0] 	= 4'b0000;
										Imm5	 [4:0] 	= 5'b00000;
										Mux2_s 				= 1'b0;
										VRegwen	      = 1'b0;
										Dcmwen 	      = 1'b0;
										VDcmwen				= 1'b0;					
									end				
								end
			M_VLOAD	:	begin
								if((Inst_n_i[3:0] == 4'b1000) && (opcode_n == VMAC))begin
									Funct4  [3:0] = Inst_n_i[3:0];
									VRs1Addr[2:0] = Inst_n_i[9:7];
									//next ins
									VRdAddr[2:0] = Inst_c_i[12:10];
									RsAddr [3:0] = Inst_c_i[9:6];
									Imm5	 [4:0] = Inst_c_i[5:1];
									Mux2_s 				= 1'b0;
									VRegwen				= 1'b1;
									//others
									VRs2Addr[2:0] = 3'b000;
									RdAddr[3:0] 	= 4'b0000;
									Imm8[7:0]			= 8'h00;
									Funct1				= 1'b0;
									Mux1_s      	= 1'b0;
									Regwen      	= 1'b0;
									Dcmwen 	      = 1'b0;
									VDcmwen				= 1'b0;	
								end
								else begin
									VRdAddr[2:0] = Inst_c_i[12:10];
									RsAddr [3:0] = Inst_c_i[9:6];
									Imm5	 [4:0] = Inst_c_i[5:1];
									Mux2_s 				= 1'b0;
									VRegwen				= 1'b1;
									//other
									Mux1_s      	= 1'b0;
									Regwen      	= 1'b0;
									RdAddr[3:0] 	= 4'b0000;
									Imm8[7:0]			= 8'h00;
									Funct1				= 1'b0;
									VRs1Addr[2:0] = 3'b000;
									VRs2Addr[2:0] = 3'b000;
									Funct4  [3:0] = 4'b0000;
									Dcmwen 				= 1'b0;
									VDcmwen				= 1'b0;				
								end				
								end					
			default	: begin
									RdAddr[3:0] 	= 4'b0000;
									Imm8[7:0]			= 8'h00;
									Funct1				= 1'b0;
									Mux1_s      	= 1'b0;
									Regwen      	= 1'b0;
									VRdAddr[2:0] 	= 3'b000;
									VRs1Addr[2:0] = 3'b000;
									VRs2Addr[2:0] = 3'b000;
									Funct4  [3:0] = 4'b0000;
									Imm5	 [4:0] 	= 5'b00000;
									RsAddr [3:0] 	= 4'b0000;	
									Mux2_s 				= 1'b0;
									VRegwen	      = 1'b0;
									Dcmwen 	      = 1'b0;
									VDcmwen				= 1'b0;		
								end
		endcase
end

//Mux1_s_o
assign Mux1_s_o = Mux1_s;

//Funct1_o
assign Funct1_o = Funct1;

//Regwen_o
assign Regwen_o 	= Regwen 	;

//RdAddr_o
assign RdAddr_o		= RdAddr	;

//RsAddr_o
assign RsAddr_o		= RsAddr	;



//VRs1Addr_o
assign VRs1Addr_o	= VRs1Addr;

//VRs2Addr_o
assign VRs2Addr_o	= VRs2Addr;

//Imm8_o
assign Imm8_o			= Imm8		;

/*access_mem*/
//Dcmwen_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Dcmwen_d <= 1'b0;
	else 
		Dcmwen_d <= Dcmwen;
end

//Dcmwen_o
assign Dcmwen_o = Dcmwen_d; 

//VDcmwen_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VDcmwen_d <= 1'b0;
	else 
		VDcmwen_d <= VDcmwen;
end

//VDcmwen_o
assign VDcmwen_o = VDcmwen_d;

//Imm5_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Imm5_d <= 5'b00000;
	else 
		Imm5_d <= Imm5;
end

//Imm5_o
assign Imm5_o = Imm5_d;

/*execute*/
//Funct4_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Funct4_d <= 4'b0000;
	else	
		Funct4_d <= Funct4;
end

//Funct4_o
assign Funct4_o = Funct4_d;

/*write_back*/ 		 	  
//Mux2_s_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Mux2_s_d <= 1'b0;
	else
		Mux2_s_d <= Mux2_s;
end

//Mux2_s_2d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Mux2_s_2d <= 1'b0;
	else
		Mux2_s_2d <= Mux2_s_d;
end

//Mux2_s_3d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Mux2_s_3d <= 1'b0;
	else
		Mux2_s_3d <= Mux2_s_2d;
end

//Mux2_s_o
assign Mux2_s_o = Mux2_s_2d;

//VRegwen_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRegwen_d <= 1'b0;
	else
		VRegwen_d <= VRegwen;
end

//VRegwen_2d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRegwen_2d <= 1'b0;
	else
		VRegwen_2d <= VRegwen_d;
end

//VRegwen_3d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRegwen_3d <= 1'b0;
	else
		VRegwen_3d <= VRegwen_2d;
end

//VRegwen_o
assign VRegwen_o = VRegwen_2d;

//VRdAddr_d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRdAddr_d <= {VREGAW{1'b0}};
	else
		VRdAddr_d <= VRdAddr;
end

//VRdAddr_2d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRdAddr_2d <= {VREGAW{1'b0}};
	else
		VRdAddr_2d <= VRdAddr_d;
end

//VRdAddr_3d
always@(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		VRdAddr_3d <= {VREGAW{1'b0}};
	else
		VRdAddr_3d <= VRdAddr_2d;
end

//VRdAddr_o
assign VRdAddr_o = VRdAddr_2d;


endmodule