interface wb_intrf(input clk_i,rst_i);
	
bit	[31:0]wb_data_i;
bit	[31:0]wb_data_o;
bit	[31:0]wb_addr_i;
bit	[3:0]wb_sel_i;
bit	wb_we_i;
bit	wb_cyc_i;
bit	wb_stb_i;
bit	wb_ack_o;
bit	wb_err_o;
bit	susp_req_i;
bit	resume_req_i;
bit	suspended_o;
bit   [31:0] poc_o;
//clocking_block
clocking drv_cb @(posedge clk_i);
   default input #1 output #1;
   output wb_data_i;
   input wb_data_o;
   output wb_addr_i;
   output wb_sel_i;
   output wb_we_i;
   output wb_cyc_i;
   output wb_stb_i;
   input wb_ack_o;
   input wb_err_o;
   output susp_req_i;
   output resume_req_i;
   input suspended_o;
   input poc_o;
   endclocking

clocking mon_cb @(posedge clk_i);
   default input #1 ;
   input wb_data_i;
   input wb_data_o;
   input wb_addr_i;
   input wb_sel_i;
   input wb_we_i;
   input wb_cyc_i;
   input wb_stb_i;
   input wb_ack_o;
   
   endclocking
endinterface
