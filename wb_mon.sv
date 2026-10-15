class wb_mon extends uvm_monitor;
uvm_analysis_port#(wb_tx) ap_port;
virtual wb_intrf vif;
`uvm_component_utils(wb_mon)
`NEW_COMP
wb_tx tx;
function void build();
ap_port=new("ap_port",this);
endfunction
task run();
uvm_resource_db#(virtual wb_intrf)::read_by_name("GLOBAL","WB_VIF",vif,this);

forever begin
@(vif.mon_cb);
if(vif.mon_cb.wb_stb_i&&vif.mon_cb.wb_ack_o)begin
tx=wb_tx::type_id::create("tx");
tx.addr=vif.mon_cb.wb_addr_i;
tx.data=(vif.mon_cb.wb_we_i)?vif.mon_cb.wb_data_i:vif.mon_cb.wb_data_o;
tx.wr_rd=vif.mon_cb.wb_we_i;
tx.sel=vif.mon_cb.wb_sel_i;
ap_port.write(tx);
$display("wb_mon:start");
tx.print();
$display("wb_mon:end");
end
end
endtask
endclass
