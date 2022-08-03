//wk2021/06/30

`timescale 1ns/10ps

`define PERIOD 10
module tb #(
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

reg 		rst_n;
reg 		clk	;

risc_vector x_risc_vector(
	.Clk_i			  (clk),		
	.Rst_n_i		  (rst_n)
);

initial begin
	clk = 1'b0;
	forever #(`PERIOD/2) clk = ~clk;
end

//MAIN
initial begin
	test1();
$finish;
end

//tasks
task test1();
begin
	rst_n = 1;
	#(`PERIOD*0.7) rst_n = 0; 
	#(1.5*`PERIOD) rst_n = 1; 
	$readmemb ("C:/Users/12863/Desktop/risc_vector/tb/ins.txt", x_risc_vector.x_icmem_dff.x_rom.mem);
	$display("icmem loaded   successfully!");
	$readmemb("C:/Users/12863/Desktop/risc_vector/tb/dat.txt",  x_risc_vector.x_dcmem_dff.RAM);
	$display("dcmem loaded   successfully!");
	$readmemb("C:/Users/12863/Desktop/risc_vector/tb/vdat.txt",  x_risc_vector.x_vdcmem_dff.RAM);
	$display("vdcmem loaded   successfully!");
	#(500*`PERIOD); 
end
endtask

endmodule