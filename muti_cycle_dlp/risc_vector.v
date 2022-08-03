//wk2021/07/02

//`include "C:/Users/12863/Desktop/risc_vector/decode.v"

module risc_vector #(
//isa
parameter ISAW	= 16,
parameter PCW		= 16,
parameter OPW 	= 3 ,
parameter IMMW5 = 5 ,
parameter IMMW8 = 8 ,
parameter FUN4W = 4	,
//(* keep = "true" *)reg
parameter REGAW = 4 ,
parameter REGDW = 16,
parameter REGN  = 16,
parameter VREGAW= 3 ,
parameter VREGDW= 32,
parameter VREGN = 8	,
//mem
parameter MEMAW = 5 ,
parameter MEMDW = 16,
parameter MEMN	= 32,
parameter VMEMAW= 6 ,
parameter VMEMDW= 32,
parameter VMEMN	= 64

)(
input 								Clk_i			,
input 								Rst_n_i
);
//data_wire
wire 	[PCW-1:0]			pc_dp2i						;
wire 					 			ml_en_de2dp				;
wire 	[ISAW-1:0]		ins_curr_i2de			;
wire 	[ISAW-1:0]		ins_next_i2de			;
wire								mux1_s_de2mux1		;
wire 	[IMMW8-1:0]		imm8_de2mux1			;
wire 	[MEMDW-1:0]		mem_data_d2mux1		;
wire 	[REGDW-1:0]		rd_data_mux1rf		;
wire								mux2_s_de2mux2		;
wire 	[VMEMDW-1:0]	mem_data_vd2mux2	;
wire 	[VREGDW-1:0]	vec3_vmac2mux2		;
wire 	[VREGDW-1:0]	vrd_data_mux2vrf	;
wire 	[REGDW-1:0] 	rs_data_rf2vd			;
wire 	[IMMW5-1:0]	 	imm5_de2vd				;
wire 	[VREGDW-1:0]	vrs1_data_vrf2vmac;
wire 	[VREGDW-1:0]	vrs2_data_vrf2vmac;
wire								vregwen_de2vrf		;
//ctrl_wire
wire								dcmwen_de2d				;
wire								vdcmwen_de2vd			;
wire								regwen_de2rf			;
wire	[FUN4W-1:0]		funct4_de2vmac		;
wire	[REGAW-1:0]		rd_addr_de2rf			;
wire	[REGAW-1:0]		rs_addr_de2rf			;
wire	[VREGAW-1:0]	vrd_addr_de2vrf		;
wire	[VREGAW-1:0]	vrs1_addr_de2vrf	;
wire	[VREGAW-1:0]	vrs2_addr_de2vrf	;

//i
icmem_dff #(
    .PCW(16),
    .ISAW(16)
)x_icmem_dff (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.Addr_i 		(pc_dp2i),
	.ML_en_i		(ml_en_de2dp),
	.InsCurr_o	(ins_curr_i2de),
	.InsNext_o  (ins_next_i2de)
);

//dp
dispatcher #(
	.PCW(16),
	.ISAW(16)
)x_dispatcher (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.ML_en_i		(ml_en_de2dp),
	.PC_o				(pc_dp2i)
);

//de
decode x_decode(
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.Inst_c_i		(ins_curr_i2de),
	.Inst_n_i		(ins_next_i2de),
	.ML_en_o		(ml_en_de2dp),
	.Mux2_s_o 	(mux2_s_de2mux2),
	.VRegwen_o	(vregwen_de2vrf),
	.Dcmwen_o 	(dcmwen_de2d),
	.VDcmwen_o	(vdcmwen_de2vd),
	.Mux1_s_o		(mux1_s_de2mux1),
	.Funct1_o		(),
	.Funct4_o		(funct4_de2vmac),
	.Regwen_o 	(regwen_de2rf),
	.RdAddr_o		(rd_addr_de2rf),
	.RsAddr_o		(rs_addr_de2rf),
	.VRdAddr_o	(vrd_addr_de2vrf),
	.VRs1Addr_o	(vrs1_addr_de2vrf),
	.VRs2Addr_o	(vrs2_addr_de2vrf),
	.Imm8_o			(imm8_de2mux1),
	.Imm5_o			(imm5_de2vd)
);

//mux1
mux2s1 #(
	.DW(16)
)mux_1 (
	.S					(mux1_s_de2mux1),
	.A					(mem_data_d2mux1),
	.B					({8'h00,imm8_de2mux1}),
	.Y					(rd_data_mux1rf)
);

//mux2
mux2s1 #(
	.DW(32)
)mux_2 (
	.S					(mux2_s_de2mux2),
	.A					(mem_data_vd2mux2),
	.B					(vec3_vmac2mux2),
	.Y					(vrd_data_mux2vrf)
);

//rf
regfile_dff #(
	.REGAW(4),
	.REGDW(16),
	.REGN (16)
)x_regfile_dff (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.RegWEn			(regwen_de2rf),
	.RdAddr_i		(rd_addr_de2rf),
	.RdData_i 	(rd_data_mux1rf),
	.Rs1Addr_i	(rs_addr_de2rf),
	.Rs1Data_o	(rs_data_rf2vd),
	.Rs2Addr_i	(4'b0000),
	.Rs2Data_o  ()
);

//d
dcmem_dff #(
	.MEMAW			(4),
	.MEMDW	    (16),
	.MEMN	      (16)
)x_dcmem_dff (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.MemWEn_i		(dcmwen_de2d),
	.MemAddr_i	(rs_data_rf2vd),
	.MemData_i	({MEMDW{1'b0}}),
	.MemData_o	(mem_data_d2mux1)
);

//vrf
regfile_dff #(
	.REGAW(3),
	.REGDW(32),
	.REGN (8)
)x_vregfile_dff (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.RegWEn			(vregwen_de2vrf),
	.RdAddr_i		(vrd_addr_de2vrf),
	.RdData_i 	(vrd_data_mux2vrf),
	.Rs1Addr_i	(vrs1_addr_de2vrf),
	.Rs1Data_o	(vrs1_data_vrf2vmac),
	.Rs2Addr_i	(vrs2_addr_de2vrf),
	.Rs2Data_o  (vrs2_data_vrf2vmac)
);

//vd
dcmem_dff #(
	.MEMAW			(7),
	.MEMDW	    (32),
	.MEMN	      (85)
)x_vdcmem_dff (
	.Clk_i			(Clk_i),
	.Rst_n_i		(Rst_n_i),
	.MemWEn_i		(vdcmwen_de2vd),
	.MemAddr_i	((rs_data_rf2vd+imm5_de2vd)),
	.MemData_i	(vrs1_data_vrf2vmac),
	.MemData_o	(mem_data_vd2mux2)
);

//vmac
vmac_dff #(
	.DW 				(8),
	.AW 				(4),
	.VECW 			(32),
	.SPW				(20)
)x_vmac_dff (
	.Clk_i			(Clk_i),	
	.Rst_n_i		(Rst_n_i),
	.Funct4_i 	(funct4_de2vmac),
	.Vec1_i	  	(vrs1_data_vrf2vmac),
	.Vec2_i	  	(vrs2_data_vrf2vmac),
	.Vec3_o   	(vec3_vmac2mux2)
);

endmodule