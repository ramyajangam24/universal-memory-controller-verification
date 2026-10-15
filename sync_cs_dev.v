/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Synchronous Chip Select Device Model                       ////
/////////////////////////////////////////////////////////////////////

module sync_cs_dev(clk, addr, dq, cs_, we_, oe_, ack_ );
input		clk;
input	[15:0]	addr;
inout	[31:0]	dq;
input		cs_, we_, oe_;
output		reg ack_;

reg	[31:0]	data_o;
reg	[31:0]	mem[0:1024];
wire		rd, wr;

integer		rd_del;
reg	[31:0]	rd_r;
wire		rd_d;

integer		wr_del;
reg	[31:0]	wr_r;
wire		wr_d;

integer		ack_del;
reg	[31:0]	ack_r;
wire		ack_d;

initial	ack_del = 2;
//initial	rd_del  = 7;
initial	rd_del  = 4;
initial	wr_del  = 3;

task mem_fill;

integer n;

begin

for(n=0;n<1024;n=n+1)
	mem[n] = $random;

end
endtask


assign dq = rd_d ? data_o : 32'hzzzz_zzzz;

assign rd = ~cs_ &  we_ & ~oe_;
assign wr = ~cs_ & ~we_;

always @(posedge clk)
	if(~rd)		rd_r <= #1 0;
	else		rd_r <= #1 {rd_r[30:0], rd};
assign rd_d = rd_r[rd_del] & rd;

always @(posedge clk)
	if(~wr)		wr_r <= #1 0;
	else		wr_r <= #1 {wr_r[30:0], wr};
assign wr_d = wr_r[wr_del] & wr;

always @(posedge clk)
	data_o <= #1 mem[addr[9:0]];

always @(posedge clk)
	if(wr_d) mem[addr[9:0]] <= #1 dq;

assign ack_d = rd | wr;
always @(posedge clk)
	if(~rd & ~wr)	ack_r <= #1 0;
	else		ack_r <= #1 {ack_r[30:0], ack_d};

//assign	ack_ = ack_r[ack_del] & ack_d;
always @(ack_r or ack_d) begin
	ack_ = ack_r[ack_del] & ack_d;
end

endmodule


