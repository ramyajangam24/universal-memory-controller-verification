class wb_base_seq extends uvm_sequence#(wb_tx);
uvm_phase phase;
`uvm_object_utils(wb_base_seq)
`NEW_OBJ
wb_tx tx;
wb_tx txQ[$];
task pre_body();
phase=get_starting_phase();
if(phase!=null)begin
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,100);
end
endtask
task post_body();
if(phase!=null)begin
phase.drop_objection(this);
end
endtask
endclass

//reg_rest_seq
class wb_reg_reset_seq extends wb_base_seq;
`uvm_object_utils(wb_reg_reset_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t;
for(int i=0;i<19;i++)begin
addr_t=(i<=2)?4*i:4*(i+1);
addr_t[31:29]=3'b011;//reg scenario
`uvm_do_with(req,{req.reg_mem_f==`REG;req.wr_rd==1'b0;req.addr==addr_t;})
//addr of c/s reg 4*i
end
endtask
endclass

//reg_wr_rd_seq
class wb_reg_wr_rd_seq extends wb_base_seq;
`uvm_object_utils(wb_reg_wr_rd_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//write to all registers with random data
for(int i=0;i<19;i++)begin
addr_t=(i<=2)?4*i:4*(i+1);
addr_t[31:29]=3'b011;//reg
if(i==0)data_t=$random&{8'hff,13'h0,11'h7ff};//csr register

`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
                  req.addr==addr_t;
	          req.data==data_t;             
	  })
	  //poc register cant write to this
 if(i==1) data_t=$random&32'h0;//poc
	 //ba_mask
   if(i==2) data_t=$random&8'hff;//ba_mask
   //csc & tms all bits are valid so no need to mask them
   if(i>2)data_t=$random;
	  end
	  //read all registers
for(int i=0;i<19;i++)begin
addr_t=(i<=2)?4*i:4*(i+1);
addr_t[31:29]=3'b011;//reg
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b0;
                  req.addr==addr_t;})
	  end
  endtask 
  endclass


//this sequence is common for all only config sequence changes
class wb_mem_seq extends wb_base_seq;
`uvm_object_utils(wb_mem_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//writing to memory
repeat(tx_count)begin
`uvm_do_with(req,{req.reg_mem_f==`MEM;
                  req.wr_rd==1'b1;
})
tx =new req;//shallow copy
txQ.push_back(tx);
end
//reading to memory
repeat(tx_count)begin
	tx=txQ.pop_front();
`uvm_do_with(req,{req.reg_mem_f==`MEM;
                  req.wr_rd==1'b0;
		  req.addr==tx.addr;//read happen to samelocation as write
	  })
  end
 endtask
 endclass

//cs0_sram_config_seq
class wb_config_seq extends wb_base_seq;
`uvm_object_utils(wb_config_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//sram :csr need not be programmed
//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h60000008;})
		 //upper 3 bits 011 so 6
//need to program csc0 
data_t={8'b0,8'b0000_0001,4'b0,1'b0,1'b0,1'b1,1'b0,2'b0,2'h2,3'h2,1'b1};
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h60000010;})
	      //tms0 no significance for sram
endtask
endclass


//all_cs_sram
class wb_config_sram_seq extends wb_base_seq;
`uvm_object_utils(wb_config_sram_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//sram :csr need not be programmed
//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h6000_0008;})//upper 3 bits 011 so 6
//for all cs need to program for cs0 to cs7
for(int i=0;i<8;i++)begin 
data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b0,1'b0,2'b0,2'b1,3'h1,1'b1};
csc_regA[i]=data_t;//storing locally whatever programmed storing to regA[i] register
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 no significance for sram
      end
      endtask
endclass



//this is for cs0
//cs0_sdram
class wb_config_sdram_seq extends wb_base_seq;
`uvm_object_utils(wb_config_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//sdram :csr need not be programmed
//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h6000_0008;})
		 //upper 3 bits 011 so 6
//need to program csc0 
data_t={8'b0,8'b0000_0001,4'b0,1'b0,1'b0,1'b0,1'b0,2'b0,2'h2,3'h0,1'b1};
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010;})
	      //tms0 significance for sdram
data_t={4'h0,4'h7,4'h7,3'h3,2'h2,5'h0,1'h1,2'h0,3'h2,1'b0,3'h0};
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0014;
	  })
endtask
endclass

//this is for all cs
//cs_all_sdram 
class wb_config_sdram_all_cs_seq extends wb_base_seq;
`uvm_object_utils(wb_config_sdram_all_cs_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//sram :csr need not be programmed
//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h6000_0008;})//upper 3 bits 011 so 6
//need to program all cs
for(int i=0;i<8;i=i+1)begin
data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b1,1'b0,2'b0,2'h2,3'h0,1'b1};

csc_regA[i]=data_t;
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 significance for sdram
data_t={4'h0,4'h7,4'h7,3'h3,2'h2,5'h0,1'h1,2'h0,3'h2,1'b0,3'h0};
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0014+8*i;
	  })
end
endtask
endclass

//wb_config_flash_seq
class wb_config_flash_seq extends wb_base_seq;
`uvm_object_utils(wb_config_flash_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//flash :csr need be programmed
data_t=$random;
data_t[2]=0;
data_t[1]=1;
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0000;})
//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h6000_0008;})//upper 3 bits 011 so 6
//csc0-7 register
for(int i=0;i<8;i=i+1)begin
data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b1,1'b0,2'b0,2'h2,3'h2,1'b1};
csc_regA[i]=data_t;
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 to tms7 taking random values
data_t={6'b0,6'd15,4'h7,4'h7,4'h7,8'h20};
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0014+8*i;})
end
endtask
endclass

//wb_config_all_cs_diff_mem_seq
class wb_config_all_cs_diff_mem_seq extends wb_base_seq;
`uvm_object_utils(wb_config_all_cs_diff_mem_seq)
`NEW_OBJ
task body();
bit [31:0]addr_t,data_t;
//flash :csr need be programmed
data_t=$random;
data_t[2]=0;
data_t[1]=1;
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0000;})

//poc :used during processor boot up nothing t do with sram
//ba_mask :yes
`uvm_do_with(req,{req.reg_mem_f==`REG;
                 req.wr_rd==1'b1;
		 req.data==8'hff;
		 req.addr==32'h6000_0008;})//upper 3 bits 011 so 6
//for cs0 to cs2->sram
for(int i=0;i<=2;i++)begin 
data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b0,1'b0,2'b0,2'b1,3'h1,1'b1};
csc_regA[i]=data_t;//storing locally whatever programmed storing to regA[i] register
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 no significance for sram
      end
//for cs3-5
for(int i=3;i<=5;i=i+1)begin
data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b1,1'b0,2'b0,2'h2,3'h0,1'b1};

csc_regA[i]=data_t;
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 significance for sdram
data_t={4'h0,4'h7,4'h7,3'h3,2'h2,5'h0,1'h1,2'h0,3'h2,1'b0,3'h0};
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0014+8*i;
	  })
end

//need to program all cs6 to cs7->flash
for(int i=6;i<=7;i=i+1)begin
	data_t={8'b0,8'b0000_0001<<i,4'b0,1'b0,1'b0,1'b1,1'b0,2'b0,2'h2,3'h2,1'b1};
csc_regA[i]=data_t;
`uvm_do_with(req,{req.reg_mem_f==`REG;
              req.wr_rd==1'b1;
	      req.data==data_t;
	      req.addr==32'h6000_0010+8*i;})
	      //tms0 to tms7 taking random values
data_t={6'b0,6'd15,4'h7,4'h7,4'h7,8'h20};
`uvm_do_with(req,{req.reg_mem_f==`REG;
                  req.wr_rd==1'b1;
		  req.data==data_t;
		  req.addr==32'h6000_0014+8*i;})
end
endtask
endclass
