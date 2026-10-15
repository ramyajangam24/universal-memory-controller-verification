`define NEW_COMP\
function new(string name,uvm_component parent);\
super.new(name,parent);\
endfunction
`define NEW_OBJ\
function new(string name="");\
super.new(name);\
endfunction
`define BA_MASK    8'b11111111
`define CS0_START  32'h00200000
`define CS0_END    32'h003FFFFF
`define CS1_START  32'h00400000
`define CS1_END    32'h005FFFFF
`define CS2_START  32'h00800000
`define CS2_END    32'h009FFFFF
`define CS3_START  32'h01000000
`define CS3_END    32'h011FFFFF
`define CS4_START  32'h02000000
`define CS4_END    32'h021FFFFF
`define CS5_START  32'h04000000
`define CS5_END    32'h041FFFFF
`define CS6_START    32'h08000000
`define CS6_END    32'h081FFFFF
`define CS7_START    32'h10000000
`define CS7_END    32'h101FFFFF
bit [7:0] cs_targetQ[$];
`define REG 1'b0
`define MEM 1'b1
typedef enum bit[2:0]{SDRAM=3'b000,SRAM=3'b001,FLASH=3'b010,SCSD=3'b011}mem_type_t;
int tx_count;
bit [31:0] csc_regA[7:0];
int num_matches,num_mismatches;
