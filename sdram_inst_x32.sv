
//during write MEM_CTRL ->memory ->mc_dq should be input->mc_dq should be output
//mem_ctrl should drive mc_dq memory shoul d not drive (floating ,'bz)
assign mc_dq=(mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//during read :memory -> MEM_CTRL
assign mem_pif.mc_data_pad_i=(mem_pif.mc_we_pad_o_==1)?mc_dq:32'hz;
//this sdram is of 32 bit --->x32
genvar i;
for(i=0;i<8;i=i+1)begin
mt48lc2m32b2 sdram_0(.Dq(mc_dq), 
	.Addr(mem_pif.mc_addr_pad_o[10:0]),
       	.Ba(mem_pif.mc_addr_pad_o[14:13]),
       	.Clk(mc_clk), 
	.Cke(mem_pif.mc_cke_pad_o_),
       	.Cs_n(mem_pif.mc_cs_pad_o_[i]),
       	.Ras_n(mem_pif.mc_ras_pad_o_), 
	.Cas_n(mem_pif.mc_cas_pad_o_),
       	.We_n(mem_pif.mc_we_pad_o_), 
	.Dqm(mem_pif.mc_dqm_pad_o)
);
end
