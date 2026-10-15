//from wb_mon and mem_mon
`uvm_analysis_imp_decl(_wb)
`uvm_analysis_imp_decl(_mem)

class mc_sbd extends uvm_scoreboard;
mem_tx exp_mem_txQ[$];
mem_tx act_mem_txQ[$];
mem_tx exp_mem_tx,act_mem_tx;
uvm_analysis_imp_wb#(wb_tx,mc_sbd)imp_wb;
uvm_analysis_imp_mem#(mem_tx,mc_sbd)imp_mem;
`uvm_component_utils(mc_sbd)
`NEW_COMP
function void build();
imp_wb=new("imp_wb",this);
imp_mem=new("imp_mem",this);
endfunction
function void write_wb(wb_tx t);
if(t.addr[31:29]==3'b000)begin//this tx is for memory
mem_tx tx=mem_tx::type_id::create("tx");
tx.data=t.data;
tx.wr_rd=t.wr_rd;
tx.cs=get_cs(t.addr);
tx.mem_type=csc_regA[tx.cs][3:1];
if(tx.mem_type==SRAM) tx.addr=t.addr[25:2];
if(tx.mem_type==SDRAM) tx.addr=t.addr[22:2];
if(tx.mem_type==FLASH) tx.addr=t.addr[25:2];
exp_mem_txQ.push_back(tx);
end
endfunction
function void write_mem(mem_tx t);
act_mem_txQ.push_back(t);
endfunction
task run();
forever begin
wait(act_mem_txQ.size()>0&&exp_mem_txQ.size()>0);
act_mem_tx=act_mem_txQ.pop_front();
exp_mem_tx=exp_mem_txQ.pop_front();
if(act_mem_tx.compare(exp_mem_tx))begin
num_matches++;
end
else begin
`uvm_error("MEM_TX COMPARE","TXS are not matching")
act_mem_tx.print();
exp_mem_tx.print();
num_mismatches++;
end
end
endtask
function integer get_cs(input [31:0]addr);
if(addr inside {[`CS0_START :`CS0_END]}) return 0;
else if (addr inside {[`CS1_START :`CS1_END]}) return 1;
else if (addr inside {[`CS2_START :`CS2_END]}) return 2;
else if (addr inside {[`CS3_START :`CS3_END]}) return 3;
else if (addr inside {[`CS4_START :`CS4_END]}) return 4;
else if (addr inside {[`CS5_START :`CS5_END]}) return 5;
else if (addr inside {[`CS6_START :`CS6_END]}) return 6;
else if (addr inside {[`CS7_START :`CS7_END]}) return 7;
endfunction
endclass
