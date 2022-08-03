//wk2021/03/30
`timescale 1ns / 1ps
`define PERIOD 10
module tb#(
parameter ISA_WIDTH=16,
parameter REG_ADDR_WIDTH = 4,
parameter REG_DATA_WIDTH = 16,
parameter OPCODE_WIDTH = 3,
parameter IMM_WIDTH0 = 5,
parameter IMM_WIDTH1 = 9,
parameter MEM_ADDR_WIDTH=5,
parameter MEM_DATA_WIDTH=16,
parameter MEM_NUMBER=32
)();
integer out_file;
bit 		rst_n;
bit 		clk	;

initial begin
	sys_reset();
	test1();
	#(20*`PERIOD)
	$display("17+4x7+6x9+8x12+10x15=%d\n",x_risc_minimalist.x_dcmem.RAM[24]);
	$finish;
end

task test1();
	$readmemb ("/home/stu15/Project/risc_minimalist/tb/test1.pro", x_risc_minimalist.x_icmem.inst_mem1.RAM);
	$display("icmem loaded   successfully!");
	$readmemb("/home/stu15/Project/risc_minimalist/tb/test1.dat",  x_risc_minimalist.x_dcmem.RAM);
	$display("dcmem loaded   successfully!");
endtask

task sys_reset();
	rst_n = 1;
	#(`PERIOD*0.7) rst_n = 0; 
	#(1.5*`PERIOD) rst_n = 1;  
endtask

initial begin
	clk = 1'b0;
	forever #(`PERIOD/2) clk = ~clk;
end

risc_minimalist x_risc_minimalist(
	.Clk_i				(clk),		
	.Rst_n_i		  (rst_n),
	.Inst_wen_i   (1'b0),
	.Input_inst_i ({ISA_WIDTH{1'b0}})
);

`ifdef DUMP_FSDB
initial begin
  $fsdbDumpfile("tb.fsdb");
  $fsdbDumpvars(0,"+all",tb);
  $fsdbDumpon();
end
`endif

endmodule