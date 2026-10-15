class mem_tx extends uvm_sequence_item;
bit [23:0]addr;
bit [31:0]data;
bit wr_rd;
mem_type_t mem_type;
bit [2:0]cs;//not random
//we are not generating tx so no need to randomize
`uvm_object_utils_begin(mem_tx)
`uvm_field_int(addr,UVM_ALL_ON)
`uvm_field_int(data,UVM_ALL_ON)
`uvm_field_int(wr_rd,UVM_ALL_ON)
`uvm_field_enum(mem_type_t,mem_type,UVM_ALL_ON)
`uvm_field_int(cs,UVM_ALL_ON)
`uvm_field_utils_end
`NEW_OBJ
endclass
