class mc_env extends uvm_env;
wb_agent wb_agent_i;
mc_sbd sbd;
mem_mon mem_mon_i;
`uvm_component_utils(mc_env)
`NEW_COMP
function void build();
wb_agent_i=wb_agent::type_id::create("wb_agent_i",this);
sbd=mc_sbd::type_id::create("sbd",this);
mem_mon_i=mem_mon::type_id::create("mem_mon_i",this);
endfunction
function void connect();
	wb_agent_i.mon.ap_port.connect(sbd.imp_wb);
	mem_mon_i.ap_port.connect(sbd.imp_mem);
endfunction
endclass
