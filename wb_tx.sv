class wb_tx extends uvm_sequence_item;
rand bit reg_mem_f;//accessing register or memory
rand bit [31:0]addr;
rand bit [31:0]data;
rand bit wr_rd;
rand bit [3:0]sel;
rand bit [7:0]cs;
`uvm_object_utils_begin(wb_tx)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_ALL_ON)
`uvm_field_int(wr_rd,UVM_ALL_ON)
`uvm_field_int(sel,UVM_ALL_ON)
`uvm_object_utils_end
`NEW_OBJ
constraint soft_c{
	soft sel==4'hf;
}
constraint reg_mem_c{
	(reg_mem_f==`REG) -> addr[31:29]==3'b011;
   (reg_mem_f==`MEM) -> addr[31:29]==3'b000;
   }
   constraint addr_c{
	  soft cs inside {cs_targetQ};
	   (cs==8'b00000001) -> addr inside {[`CS0_START:`CS0_END]};
	   (cs==8'b00000010) -> addr inside {[`CS1_START:`CS1_END]};
	   (cs==8'b00000100) -> addr inside {[`CS2_START:`CS2_END]};
	   (cs==8'b00001000) -> addr inside {[`CS3_START:`CS3_END]};
	   (cs==8'b00010000) -> addr inside {[`CS4_START:`CS4_END]};
	   (cs==8'b00100000) -> addr inside {[`CS5_START:`CS5_END]};
	   (cs==8'b01000000) -> addr inside {[`CS6_START:`CS6_END]};
	   (cs==8'b10000000) -> addr inside {[`CS7_START:`CS7_END]};
   }
 endclass
