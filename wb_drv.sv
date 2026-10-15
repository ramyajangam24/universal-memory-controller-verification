class wb_drv extends uvm_driver#(wb_tx);
virtual wb_intrf vif;
`uvm_component_utils(wb_drv)
`NEW_COMP
task run_phase(uvm_phase phase);
uvm_resource_db#(virtual wb_intrf)::read_by_name("GLOBAL","WB_VIF",vif,this);
@(negedge vif.rst_i);//waiting for rst to be realeased
forever begin
seq_item_port.get_next_item(req);
drive_tx(req);
seq_item_port.item_done();
end
endtask

task drive_tx(wb_tx tx);
if (tx.addr[31:29] == 3'b0) $display("drive_tx: start");
@(vif.drv_cb);
vif.drv_cb.wb_addr_i<=tx.addr;
vif.drv_cb.wb_we_i<=tx.wr_rd;
if(tx.wr_rd==1) vif.drv_cb.wb_data_i<=tx.data;
vif.drv_cb.wb_sel_i<=tx.sel;
vif.drv_cb.wb_stb_i<=1'b1;
vif.drv_cb.wb_cyc_i<=1'b1;
wait(vif.drv_cb.wb_ack_o==1'b1);
@(vif.drv_cb);
  vif.drv_cb.wb_stb_i<=0;
  vif.drv_cb.wb_cyc_i<=0;
  vif.drv_cb.wb_addr_i<=0;
  vif.drv_cb.wb_we_i<=0;
  //vif.drv_cb.wb_data_i<=0;
  //vif.drv_cb.wb_addr_i<=0;
if (tx.addr[31:29] == 3'b0) $display("drive_tx: end");
endtask
endclass	
