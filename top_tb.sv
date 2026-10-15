`timescale 1ns/1ps
`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "mc_rtl.vh"
`include "mt58l1my18d.v"
`include "mt48lc2m32b2.v"
`include "m8kx8.v"
`include "mc_common.sv"
`include "mem_intrf.sv"
`include "mem_tx.sv"
`include "mem_mon.sv"
`include "wb_tx.sv"
`include "mc_sbd.sv"
`include "wb_seq_lib.sv"
`include "wb_intrf.sv"
`include "wb_drv.sv"
`include "wb_sqr.sv"
`include "wb_mon.sv"
`include "wb_cov.sv"
`include "wb_agent.sv"
`include "mc_env.sv"
`include "test_lib.sv"
module top_tb;
reg wb_clk,wb_rst;
reg mc_clk;
bit [7:0]cs_target;
wb_intrf wb_pif(wb_clk,wb_rst);
mem_intrf mem_pif(mc_clk);
mc_top dut(
	.clk_i(wb_pif.clk_i),
       	.rst_i(wb_pif.rst_i),


	.wb_data_i(wb_pif.wb_data_i),
       	.wb_data_o(wb_pif.wb_data_o), 
	.wb_addr_i(wb_pif.wb_addr_i), 
	.wb_sel_i(wb_pif.wb_sel_i), 
	.wb_we_i(wb_pif.wb_we_i), 
	.wb_cyc_i(wb_pif.wb_cyc_i),
	.wb_stb_i(wb_pif.wb_stb_i),
       	.wb_ack_o(wb_pif.wb_ack_o),
       	.wb_err_o(wb_pif.wb_err_o), 

	.susp_req_i(wb_pif.susp_req_i),
       	.resume_req_i(wb_pif.resume_req_i),
       	.suspended_o(wb_pif.suspended_o), 
	.poc_o(wb_pif.poc_o),

	.mc_clk_i(mem_pif.mc_clk), 
	.mc_br_pad_i(mem_pif.mc_br_pad_i), 
	.mc_bg_pad_o(mem_pif.mc_bg_pad_o),
       	.mc_ack_pad_i(mem_pif.mc_ack_pad_i),
	.mc_addr_pad_o(mem_pif.mc_addr_pad_o), 
	.mc_data_pad_i(mem_pif.mc_data_pad_i), 
	.mc_data_pad_o(mem_pif.mc_data_pad_o),
       	.mc_dp_pad_i(mem_pif.mc_dp_pad_i),
	.mc_dp_pad_o(mem_pif.mc_dp_pad_o),
       	.mc_doe_pad_doe_o(mem_pif.mc_doe_pad_doe_o),
       	.mc_dqm_pad_o(mem_pif.mc_dqm_pad_o),
       	.mc_oe_pad_o_(mem_pif.mc_oe_pad_o_),
	.mc_we_pad_o_(mem_pif.mc_we_pad_o_),
       	.mc_cas_pad_o_(mem_pif.mc_cas_pad_o_), 
	.mc_ras_pad_o_(mem_pif.mc_ras_pad_o_), 
	.mc_cke_pad_o_(mem_pif.mc_cke_pad_o_),
	.mc_cs_pad_o_(mem_pif.mc_cs_pad_o_),
       	.mc_sts_pad_i(mem_pif.mc_sts_pad_i), 
	.mc_rp_pad_o_(mem_pif.mc_rp_pad_o_), 
	.mc_vpen_pad_o(mem_pif.mc_vpen_pad_o),
	.mc_adsc_pad_o_(mem_pif.mc_adsc_pad_o_), 
	.mc_adv_pad_o_(mem_pif.mc_adv_pad_o_), 
	.mc_zz_pad_o(mem_pif.mc_zz_pad_o), 
	.mc_coe_pad_coe_o(mem_pif.mc_coe_pad_coe_o));

wire [31:0]mc_dq;

//sram instantiation
`ifdef SRAM_ALL_CS
`include "sram_inst_x16.sv"
`endif

//sdram instantiation
`ifdef SDRAM_ALL_CS
`include "sdram_inst_x32.sv"
`endif

//flash instantiation
`ifdef FLASH_ALL_CS
`include "flash_inst.sv"
`endif

//all_cs_diff_mem_instantiation
`ifdef ALL_CS_DIFF_MEM
`include "all_mem_inst.sv"
`endif 

initial begin
$value$plusargs("cs_target=%b",cs_target);
$value$plusargs("tx_count=%0d",tx_count);

for(int i=0;i<8;i++)begin
if(cs_target[i])begin
cs_targetQ.push_back(8'b1<<i);
$display("pushing %b",8'b1<<i);
end
end
end
initial begin
uvm_resource_db#(virtual wb_intrf)::set("GLOBAL","WB_VIF",wb_pif,null);
uvm_resource_db#(virtual mem_intrf)::set("GLOBAL","MEM_VIF",mem_pif,null);

end
//wb_clk at 200mhz
initial begin
wb_clk=0;
forever #2.5 wb_clk=~wb_clk;
end
//mc_clk at 100mhz
initial begin
mc_clk=0;
forever #5 mc_clk=~mc_clk;
end
initial begin
wb_rst=1;
repeat(2)@(posedge wb_clk);
wb_rst=0;
end
initial begin
$fsdbDumpfile("mc.fsdb");
$fsdbDumpvars(0);
end
initial begin
run_test("test_all_cs_diff_mem");
end
endmodule

//vcs -sverilog -full64 -kdb -debug_access+all -l comp.log \
//+incdir+../../design/verilog \
//+incdir+../wb \
//+incdir+../top \
//+incdir+../sbd \
//+incdir+../mem \
//+incdir+/home/projects/src \
//+incdir+../../MemoryModels/sram_models/MicronSRAM \
//+incdir+../../MemoryModels/sdram_models/2Mx32 \
//+incdir+../../MemoryModels/160b3ver \
///home/projects/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
//+define+SDRAM_CS0 \
//../../design/verilog/mc_rtl.vh
////../top/top_tb.sv
////./simv +cs_target=8'b11111111
////./simv +UVM_TESTNAME=test_reg_reset -l sim.log
////./simv +UVM_TEST_NAME=test_reg_wr_rd -l sim.log
//./simv +UVM_TESTNAME=test_cs0_sram +cs_target=00000001 -l sim.log +UVM_TIMEOUT=20000
//./simv +UVM_TESTNAME=test_cs0_sdram +cs_target=00000001 -l sim.log +UVM_TIMEOUT=20000
//./simv +UVM_TESTNAME=test_all_cs_sram +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000
//+define+SDRAM_ALL_CS \
//./simv +UVM_TESTNAME=test_all_cs_sdram +cs_target=11111111 -l +tx_count=30 -l sim.log +UVM_TIMEOUT=20000
//+define+FLASH_ALL_CS \
//./simv +UVM_TESTNAME=test_all_cs_flash +cs_target=11111111 -l +tx_count=30 -l sim.log +UVM_TIMEOUT=30000
////for mem_mon
//+define+SRAM_ALL_CS \
//./simv +UVM_TESTNAME=test_all_cs_sram +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000
//+define+FLASH_ALL_CS \
//./simv +UVM_TESTNAME=test_al_cs_sdram +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=30000



//../top/top_tb.sv
//./simv +cs_target=8'b11111111
//./simv +UVM_TESTNAME=test_reg_reset -l sim.log
//./simv +UVM_TEST_NAME=test_reg_wr_rd -l sim.log
//./simv +UVM_TESTNAME=test_cs0_sram +cs_target=00000001 -l sim.log +UVM_TIMEOUT=20000
//./simv +UVM_TESTNAME=test_cs0_sdram +cs_target=00000001 -l sim.log +UVM_TIMEOUT=20000
