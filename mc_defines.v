//`timescale 1ns / 10ps
// This define selects how the WISHBONE interface determines if
// the internal register file is selected.
// This should be a simple address decoder. "wb_addr_i" is the
// WISHBONE address bus (32 bits wide).
`define	MC_REG_SEL		(wb_addr_i[31:29] == 3'b011)

// This define selects how the WISHBONE interface determines if
// the memory is selected.
// This should be a simple address decoder. "wb_addr_i" is the
// WISHBONE address bus (32 bits wide).
`define	MC_MEM_SEL		(wb_addr_i[31:29] == 3'h0)

/////////////////////////////////////////////////////////////////////
//
// This are the default Power-On Reset values for Chip Select
//

// This will be defined by the run script for my test bench ...
// Alternatively force here for synthesis ...
//`define RUDIS_TB 1

// Defines which chip select is used for Power On booting

// To run my default testbench default boot CS must be 3 !!!
`ifdef RUDIS_TB
`define MC_DEF_SEL		3'h3
`else
`define MC_DEF_SEL		3'h0
`endif

// Defines the default (reset) TMS value for the DEF_SEL chip select
`define	MC_DEF_POR_TMS 	32'hffff_ffff


/////////////////////////////////////////////////////////////////////
//
// Define how many Chip Selects to Implement
//
`define MC_HAVE_CS1	1
`define MC_HAVE_CS2	1
`define MC_HAVE_CS3	1
`define MC_HAVE_CS4	1
`define MC_HAVE_CS5	1
`define MC_HAVE_CS6	1
`define MC_HAVE_CS7	1


// To run my default testbench those need to there !!!
`ifdef RUDIS_TB
`define MC_HAVE_CS2	1
`define MC_HAVE_CS3	1
`define MC_HAVE_CS4	1
`define MC_HAVE_CS5	1
`endif

/////////////////////////////////////////////////////////////////////
//
// Init Refresh
//
// Number of Refresh Cycles to perform during SDRAM initialization.
// This varies between SDRAM manufacturer. Typically this value is
// between 2 and 8. This number must be smaller than 16.
`define	MC_INIT_RFRC_CNT	2

/////////////////////////////////////////////////////////////////////
//
// Power On Delay
//
// Most if SDRAMs require some time to initialize before they can be used
// after power on. If the Memory Controller shall stall after power on to
// allow SDRAMs to finish the initialization process uncomment the below
// define statement
`define	MC_POR_DELAY	1

// This value defines how many MEM_CLK cycles the Memory Controller should
// stall. Default is 2.5uS. At a 10nS MEM_CLK cycle time, this would 250
// cycles.
`define	MC_POR_DELAY_VAL	8'd8


// ===============================================================
// ===============================================================
// Various internal defines (DO NOT MODIFY !)
// ===============================================================
// ===============================================================

// Register settings encodings
`define MC_BW_8			2'h0
`define MC_BW_16		2'h1
`define MC_BW_32		2'h2

`define MC_MEM_TYPE_SDRAM	3'h0
`define MC_MEM_TYPE_SRAM	3'h1
`define MC_MEM_TYPE_ACS		3'h2
`define MC_MEM_TYPE_SCS		3'h3

`define MC_MEM_SIZE_64		2'h0
`define MC_MEM_SIZE_128		2'h1
`define MC_MEM_SIZE_256		2'h2

// Command Valid, Ras_, Cas_, We_
`define MC_CMD_NOP		4'b0111
`define MC_CMD_PC		4'b1010
`define MC_CMD_ACT		4'b1011
`define MC_CMD_WR		4'b1100
`define MC_CMD_RD		4'b1101
`define MC_CMD_BT		4'b1110
`define MC_CMD_ARFR		4'b1001
`define MC_CMD_LMR		4'b1000
`define MC_CMD_XRD		4'b1111
`define MC_CMD_XWR		4'b1110

`define MC_SINGLE_BANK		1'b0
`define MC_ALL_BANKS		1'b1

