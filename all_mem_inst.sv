
reg sram_access_r,sdram_access_r,flash_access_r;
assign sram_access_f=$onehot(~mem_pif.mc_cs_pad_o_[2:0]);//if cs[0,1,2]=0
//if any bit->0 then ~0->1 becomes onehot zero like 001
assign sdram_access_f=$onehot(~mem_pif.mc_cs_pad_o_[5:3]);//if cs[3,4,5]=0
assign flash_access_f=$onehot(~mem_pif.mc_cs_pad_o_[7:6]);//if cs[6,7]=0
always@(posedge sram_access_f or posedge sdram_access_f or posedge flash_access_f)begin
	{sram_access_r,sdram_access_r,flash_access_r}={sram_access_f,sdram_access_f,flash_access_f};//setting only one of them to 1 like 100,010,001
end

//during write MEM_CTRL ->memory
//mem_ctrl should drive mc_dq memory shoul d not drive (floating ,'bz)
assign mc_dq=(mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//assign mc_dq=(mem_pif.mc_oe_pad_o_==1&&mem_pif.mc_we_pad_o_==0)?mem_pif.mc_data_pad_o:32'hz;
//during read :memory -> MEM_CTRL
assign mem_pif.mc_data_pad_i=(mem_pif.mc_we_pad_o_==1&&(sdram_access_r || flash_access_r))||(mem_pif.mc_oe_pad_o_==0&&sram_access_r)?mc_dq:32'hz;//if mem_ctrl is reading

genvar i;
//cs0-2
//sram
for(i=0;i<=2;i=i+1)begin
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
//cs3-5
//sdram
for(i=3;i<=5;i=i+1)begin
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
//cs 6-7 
//flash
for(i=6;i<=7;i=i+1)begin
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
