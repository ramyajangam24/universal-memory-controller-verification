class wb_cov extends uvm_subscriber#(wb_tx);
`uvm_component_utils(wb_cov)
wb_tx tx;
covergroup wb_cg;
REG_MEM_CP:coverpoint tx.addr[31:29]{
bins REG={3'b011};
bins MEM={3'b000};
illegal_bins other ={3'b001,3'b010,3'b100,3'b101,3'b110,3'b111};
}
CS_CP:coverpoint tx.addr{
	bins cs0={[`CS0_START:`CS0_END]};
	bins cs1={[`CS1_START:`CS1_END]};
	bins cs2={[`CS2_START:`CS2_END]};
	bins cs3={[`CS3_START:`CS3_END]};
	bins cs4={[`CS4_START:`CS4_END]};
	bins cs5={[`CS5_START:`CS5_END]};
	bins cs6={[`CS6_START:`CS6_END]};
	bins cs7={[`CS7_START:`CS7_END]};
}
WR_RD_CP:coverpoint tx.wr_rd{
	bins WRITE={1'b1};
        bins READ={1'b0};
}
CS_X_WR_RD_CP:cross CS_CP,WR_RD_CP;
CS_X_REG_MEM_CP:cross CS_CP,REG_MEM_CP;
endgroup
function new(string name,uvm_component parent);
super.new(name,parent);
wb_cg=new();
endfunction
//mon calls ap_port write,below write method gets invoked
function void write(wb_tx t);
tx=new t;
wb_cg.sample();
endfunction
endclass
