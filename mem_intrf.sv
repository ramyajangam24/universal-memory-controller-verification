interface mem_intrf(input mc_clk);

bit   mc_br_pad_i;
bit   mc_bg_pad_o;
bit   mc_ack_pad_i;
bit   [23:0]mc_addr_pad_o;
bit   [31:0]mc_data_pad_i;
bit  [31:0]mc_data_pad_o;
bit   [3:0]mc_dp_pad_i;
bit   [3:0]mc_dp_pad_o;
bit   mc_doe_pad_doe_o;
bit   [3:0]mc_dqm_pad_o;
bit   mc_oe_pad_o_;
bit   mc_we_pad_o_;
bit   mc_cas_pad_o_;
bit   mc_ras_pad_o_;
bit   mc_cke_pad_o_;
bit   [7:0]mc_cs_pad_o_;
bit   mc_sts_pad_i;
bit   mc_rp_pad_o_;
bit   mc_vpen_pad_o;
bit   mc_adsc_pad_o_;
bit   mc_adv_pad_o_;
bit   mc_zz_pad_o;
bit   mc_coe_pad_coe_o;
endinterface
