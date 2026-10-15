class mc_base_test extends uvm_test;
`uvm_component_utils(mc_base_test)
`NEW_COMP
mc_env env;
function void build();
env=mc_env::type_id::create("env",this);
endfunction
function void end_of_elaboration();
uvm_top.print_topology();
endfunction
function void report();
if(num_matches==2*tx_count && num_mismatches==0)
begin
`uvm_info("STATUS",$psprintf("%s Test passed",get_type_name()),UVM_NONE)
end
else begin
`uvm_error("STATUS",$psprintf("%s Test failed,num_matches=%0d,num_mismatches=%0d",get_type_name(),num_matches,num_mismatches))
end
endfunction
endclass

class test_reg_reset extends mc_base_test;
`uvm_component_utils(test_reg_reset)
`NEW_COMP
task run_phase(uvm_phase phase);
wb_reg_reset_seq wb_seq=new("wb_seq");
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
wb_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass


class test_reg_wr_rd extends mc_base_test;
`uvm_component_utils(test_reg_wr_rd)
`NEW_COMP
task run_phase(uvm_phase phase);
wb_reg_wr_rd_seq wb_wr_rd_seq=new("wb_seq");
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
wb_wr_rd_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//this is for single sram cs
class test_cs0_sram extends mc_base_test;
`uvm_component_utils(test_cs0_sram)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//this if for all cs
class test_all_cs_sram extends mc_base_test;
`uvm_component_utils(test_all_cs_sram)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_sram_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//this is for cs0
class test_cs0_sdram extends mc_base_test;
`uvm_component_utils(test_cs0_sdram)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_sdram_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//this is for all cs sdram
class test_all_cs_sdram extends mc_base_test;
`uvm_component_utils(test_all_cs_sdram)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_sdram_all_cs_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//this is for flash
class test_all_cs_flash extends mc_base_test;
`uvm_component_utils(test_all_cs_flash)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_flash_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass

//test_all_cs_diff_mem
class test_all_cs_diff_mem extends mc_base_test;
`uvm_component_utils(test_all_cs_diff_mem)
`NEW_COMP
task run_phase(uvm_phase phase);
	wb_config_all_cs_diff_mem_seq config_seq=new("config_seq");//program registers
	wb_mem_seq mem_seq=new("mem_seq");//wr_rd to memories
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
config_seq.start(env.wb_agent_i.sqr);//cs0,sram 16 bit width
mem_seq.start(env.wb_agent_i.sqr);
phase.drop_objection(this);
endtask
endclass
