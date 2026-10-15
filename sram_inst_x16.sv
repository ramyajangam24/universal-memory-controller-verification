	//during write MEM_CTRL ->memory
//mem_ctrl should drive mc_dq memory shoul d not drive (floating ,'bz)
assign mc_dq=(mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//assign mc_dq=(mem_pif.mc_oe_pad_o_==1&&mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//during read :memory -> MEM_CTRL
assign mem_pif.mc_data_pad_i=(mem_pif.mc_oe_pad_o_==0)?mc_dq:32'hz;

genvar i;
for(i=0;i<8;i=i+1)begin
//this sram is of 16 bit--->x16
mt58l1my18d sram_inst_a(.Dq({2'b0,mc_dq[15:0]}),
       	        .Addr(mem_pif.mc_addr_pad_o[19:0]),
       	        .Mode(1'b0),
       	        .Adv_n(mem_pif.mc_adv_pad_o_),
       	        .Clk(mc_clk),
       	        .Adsc_n(mem_pif.mc_adsc_pad_o_), 
	        .Adsp_n(1'b1),
       	        .Bwa_n(mem_pif.mc_dqm_pad_o[0]), 
	        .Bwb_n(mem_pif.mc_dqm_pad_o[1]),
       	        .Bwe_n(mem_pif.mc_we_pad_o_),
       	        .Gw_n(1'b1),
       	        .Ce_n(mem_pif.mc_cs_pad_o_[i]),
       	        .Ce2(1'b1),
       	        .Ce2_n(1'b0),
       	        .Oe_n(mem_pif.mc_oe_pad_o_),
       	        .Zz(mem_pif.mc_zz_pad_o)
	);
mt58l1my18d sram_inst_b(.Dq({2'b0,mc_dq[31:16]}),
       	        .Addr(mem_pif.mc_addr_pad_o[19:0]),
       	        .Mode(1'b0),
       	        .Adv_n(mem_pif.mc_adv_pad_o_),
       	        .Clk(mc_clk),
       	        .Adsc_n(mem_pif.mc_adsc_pad_o_), 
	        .Adsp_n(1'b1),
       	        .Bwa_n(mem_pif.mc_dqm_pad_o[2]), 
	        .Bwb_n(mem_pif.mc_dqm_pad_o[3]),
       	        .Bwe_n(mem_pif.mc_we_pad_o_),
       	        .Gw_n(1'b1),
       	        .Ce_n(mem_pif.mc_cs_pad_o_[i]),
       	        .Ce2(1'b1),
       	        .Ce2_n(1'b0),
       	        .Oe_n(mem_pif.mc_oe_pad_o_),
       	        .Zz(mem_pif.mc_zz_pad_o)
	);

end
