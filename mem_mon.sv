class mem_mon extends uvm_monitor;
virtual mem_intrf vif;
mem_tx tx;
mem_type_t mem_type;
integer target_cs;
bit [31:0]csc_target_cs;
bit wr_tx_in_progress_f;
bit sdram_wr_tx_in_progress_f;
bit sdram_rd_tx_in_progress_f;
bit [10:0]row_addr;
bit [1:0]bank_addr;
bit [10:0]col_addr;
bit row_act_arr[int][int];
uvm_analysis_port#(mem_tx) ap_port;
`uvm_component_utils(mem_mon)
`NEW_COMP
function void build();
ap_port=new("ap_port",this);
uvm_resource_db#(virtual mem_intrf)::read_by_name("GLOBAL","MEM_VIF",vif,this);
endfunction
task run();
//monitor memory interface for txs
  fork
  //sdram,sram,scsd memories
      forever begin
	@(posedge vif.mc_clk);
	if(vif.mc_cs_pad_o_==8'hFF)begin
	       wr_tx_in_progress_f=0;//when no cs is targetted,resetting this variable
	sdram_wr_tx_in_progress_f=0;//when no cs is targetted,resetting this variable
	sdram_rd_tx_in_progress_f=0;//when no cs is targetted,resetting this variable
end
        if(vif.mc_cs_pad_o_!=8'hFF)begin//atleast cs bit is low asserted
	target_cs=get_target_cs(vif.mc_cs_pad_o_);
	csc_target_cs=csc_regA[target_cs];
	mem_type=csc_target_cs[3:1];

  if(mem_type==SDRAM)begin//sdram
tx=mem_tx::type_id::create("tx");
if(vif.mc_ras_pad_o_==0&&vif.mc_cas_pad_o_==1&&vif.mc_we_pad_o_==1)begin//ACTIVATE
	row_addr=vif.mc_addr_pad_o[10:0];//11 bit row addr
	bank_addr=vif.mc_addr_pad_o[14:13];//2 bit bank addr
	row_act_arr[bank_addr][row_addr]=1;
end
if(vif.mc_ras_pad_o_==1&&vif.mc_cas_pad_o_==0&&vif.mc_we_pad_o_==0&&sdram_wr_tx_in_progress_f==0)begin//WRITE
	sdram_wr_tx_in_progress_f=1;
	col_addr=vif.mc_addr_pad_o[10:0];//8 bit column address
	tx.data=vif.mc_data_pad_o;
	if(csc_target_cs[9]==1) tx.addr={bank_addr,row_addr,col_addr[7:0]};
	if(csc_target_cs[9]==0) tx.addr={row_addr,bank_addr,col_addr[7:0]};
	tx.wr_rd=1;
	tx.mem_type=SDRAM;
	tx.cs=target_cs;
	$display("csc_target_cs[9]=%b,ba=%b,col_addr=%b,data=%h",csc_target_cs[9],bank_addr,col_addr,tx.data);
	ap_port.write(tx);
	tx.print();
end
if(vif.mc_ras_pad_o_==1&&vif.mc_cas_pad_o_==0&&vif.mc_we_pad_o_==1&&sdram_rd_tx_in_progress_f==0)begin//READ
	sdram_rd_tx_in_progress_f=1;
	col_addr=vif.mc_addr_pad_o[10:0];
	if(csc_target_cs[9]==1)tx.addr={bank_addr,row_addr,col_addr[7:0]};
	if(csc_target_cs[9]==0)tx.addr={row_addr,bank_addr,col_addr[7:0]};

	tx.wr_rd=0;
	tx.mem_type=SDRAM;
	tx.cs=target_cs;
	repeat(2)@(posedge vif.mc_clk);
	tx.data=vif.mc_data_pad_i;
	ap_port.write(tx);
	tx.print();
end

	    end


 else if(mem_type==SRAM)begin//sram
	tx=mem_tx::type_id::create("tx");
	//see timing diagram
	wait(vif.mc_adsc_pad_o_==0);
	//for collecting wr_tx,both we=0,wr_tx_in_progress_f=0
	if(vif.mc_we_pad_o_==0&&wr_tx_in_progress_f==0)begin//write
		wr_tx_in_progress_f=1;//it will avoid duplicate collection of same tx
		tx.addr=vif.mc_addr_pad_o;
		tx.data=vif.mc_data_pad_o;
              //MEM_CTRL->SRAM
	      tx.cs=target_cs;
	      tx.mem_type=mem_type;
	      tx.wr_rd=1;
	      ap_port.write(tx);
	      tx.print();
      end
      if(vif.mc_oe_pad_o_==0)begin//read
	      tx.addr=vif.mc_addr_pad_o;
	      tx.cs=target_cs;
	      tx.mem_type=mem_type;//this is useful for sbd &cov
	      tx.wr_rd=0;
	      repeat(2)@(posedge vif.mc_clk);
	      tx.data=vif.mc_data_pad_i;//SRAM->MEM_CTRL
	      ap_port.write(tx);
	      tx.print();
      end

	 end
  else if(mem_type==SCSD)begin//scsd
       end
       end
       end
   //flash memories
      forever begin
  @(vif.mc_cs_pad_o_);//waiting for cs to change
  target_cs=get_target_cs(vif.mc_cs_pad_o_);
  csc_target_cs=csc_regA[target_cs];
  mem_type=csc_target_cs[3:1];
  $display("mem_type=%h",mem_type);
  if(mem_type==FLASH)begin
	  tx=mem_tx::type_id::create("tx");
	  wait(vif.mc_oe_pad_o_==0 || vif.mc_we_pad_o_==0);
	  if(vif.mc_doe_pad_doe_o==1&&vif.mc_we_pad_o_==0)begin//write
	tx.addr=vif.mc_addr_pad_o;	  
	tx.data=vif.mc_data_pad_o;
	tx.cs=target_cs;
	tx.mem_type=mem_type;
	tx.wr_rd=1;
	ap_port.write(tx);
	tx.print();
end
	  if(vif.mc_oe_pad_o_==0&&vif.mc_we_pad_o_==1)begin//READ
	tx.addr=vif.mc_addr_pad_o;	  
	tx.cs=target_cs;
	tx.mem_type=mem_type;
	$display("%t:=mem_type=%h,csc_target_cs=%h,target_cs=%h",$realtime,mem_type,csc_target_cs,target_cs);
	tx.wr_rd=0;
	//#25;
	#344;
	tx.data=vif.mc_data_pad_i;
	ap_port.write(tx);
	tx.print();
end
end
      end
  join
endtask
  function integer get_target_cs(bit [7:0]cs);
	get_target_cs= vif.mc_cs_pad_o_== 8'b1111_1110 ? 0:

                          vif.mc_cs_pad_o_== 8'b1111_1101 ? 1:

	                  vif.mc_cs_pad_o_== 8'b1111_1011 ? 2:

	                  vif.mc_cs_pad_o_== 8'b1111_0111 ? 3:

	                  vif.mc_cs_pad_o_== 8'b1110_1111 ? 4:

	                  vif.mc_cs_pad_o_== 8'b1101_1111 ? 5:

	                  vif.mc_cs_pad_o_== 8'b1011_1111 ? 6:

	                  vif.mc_cs_pad_o_== 8'b0111_1111 ? 7:'hx;
  
  endfunction


endclass
