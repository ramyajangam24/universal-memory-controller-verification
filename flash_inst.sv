//during write MEM_CTRL ->memory ->mc_dq should be input->mc_dq should be output
//mem_ctrl should drive mc_dq memory shoul d not drive (floating ,'bz)
assign mc_dq=(mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//during read :memory -> MEM_CTRL
assign mem_pif.mc_data_pad_i=(mem_pif.mc_we_pad_o_==1)?mc_dq:32'hz;
//this sdram is of 32 bit --->x32
genvar i;
for(i=0;i<8;i=i+1)begin
A8Kx8 flash_inst_0(.Address(mem_pif.mc_addr_pad_o[12:0]),
       	.dataIO(mc_dq[7:0]), 
	.OEn(mem_pif.mc_oe_pad_o_),
       	.CE1n(mem_pif.mc_cs_pad_o_[i]),
       	.CE2(1'b1),
       	.WEn(mem_pif.mc_we_pad_o_)
        );

A8Kx8 flash_inst_1(.Address(mem_pif.mc_addr_pad_o[12:0]),
       	.dataIO(mc_dq[15:8]), 
	.OEn(mem_pif.mc_oe_pad_o_),
       	.CE1n(mem_pif.mc_cs_pad_o_[i]),
       	.CE2(1'b1),
       	.WEn(mem_pif.mc_we_pad_o_)
        );
A8Kx8 flash_inst_2(.Address(mem_pif.mc_addr_pad_o[12:0]),
       	.dataIO(mc_dq[23:16]), 
	.OEn(mem_pif.mc_oe_pad_o_),
       	.CE1n(mem_pif.mc_cs_pad_o_[i]),
       	.CE2(1'b1),
       	.WEn(mem_pif.mc_we_pad_o_)
        );
A8Kx8 flash_inst_3(.Address(mem_pif.mc_addr_pad_o[12:0]),
       	.dataIO(mc_dq[31:24]), 
	.OEn(mem_pif.mc_oe_pad_o_),
       	.CE1n(mem_pif.mc_cs_pad_o_[i]),
       	.CE2(1'b1),
       	.WEn(mem_pif.mc_we_pad_o_)
        );
end
