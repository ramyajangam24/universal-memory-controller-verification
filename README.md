# UVM Testbench for Memory Controller (WISHBONE → SRAM / SDRAM / FLASH)

A SystemVerilog/UVM verification environment for a WISHBONE-slave memory controller (`mc_top`). The testbench drives register-programming and memory read/write traffic on the WISHBONE bus, passively monitors the memory-side pins, and a scoreboard checks that what the DUT put on the memory bus matches what was requested on the WISHBONE side.

## Features

- WISHBONE master agent (driver, sequencer, monitor, functional coverage)
- Passive memory-side monitor that decodes SRAM, SDRAM and FLASH bus protocols
- Scoreboard comparing expected (WISHBONE) vs. actual (memory pins) transactions
- Support for 8 chip selects (CS0–CS7), each configurable as SDRAM / SRAM / FLASH
- Memory model instantiation selected by compile-time defines
- Run-time control of target chip selects and transaction count via plusargs

## Architecture

```
                         ┌───────────────────────── mc_env ─────────────────────────┐
                         │                                                          │
  sequences ──► wb_sqr ──► wb_drv ──► [wb_intrf] ──►  DUT (mc_top)  ──► [mem_intrf] ──► mem_mon
                         │               ▲                                              │
                         │            wb_mon ──► wb_cov                                 │
                         │               │                                              │
                         │               └──► mc_sbd.imp_wb        mc_sbd.imp_mem ◄─────┘
                         └──────────────────────────────────────────────────────────┘
                                                                  │
                                                    memory models (SRAM / SDRAM / FLASH)
```

## File Overview

| File | Description |
|------|-------------|
| `top_tb.sv` | Top module: clocks, reset, DUT hookup, memory model includes, plusarg parsing, `run_test` |
| `mc_common.sv` | Common macros (`NEW_COMP`, `NEW_OBJ`), CS address-range defines, `mem_type_t` enum, shared globals |
| `test_lib.sv` | `mc_base_test` and all test classes |
| `mc_env.sv` | Environment: WB agent + scoreboard + memory monitor |
| `mc_sbd.sv` | Scoreboard (WB → expected mem tx; compares with monitored mem tx) |
| **WISHBONE agent** | |
| `wb_agent.sv` | Agent wrapper (driver, sequencer, monitor, coverage) |
| `wb_drv.sv` | Drives WISHBONE signals via the `drv_cb` clocking block |
| `wb_sqr.sv` | Sequencer |
| `wb_mon.sv` | Captures completed WB transfers (`stb && ack`) |
| `wb_cov.sv` | Functional coverage: reg/mem, CS, read/write and crosses |
| `wb_tx.sv` | WB sequence item with address/CS constraints |
| `wb_intrf.sv` | WISHBONE interface |
| `wb_seq_lib.sv` | Sequence library (register reset/read-write, config sequences, memory traffic) |
| **Memory side** | |
| `mem_intrf.sv` | Memory-side interface (`mc_*_pad_*` signals) |
| `mem_tx.sv` | Memory transaction item |
| `mem_mon.sv` | Monitors SRAM, SDRAM and FLASH protocol activity |
| `sram_inst_x16.sv` | SRAM instantiation for all CS (x16 devices) |
| `sdram_inst_x32.sv` | SDRAM instantiation for all CS (x32 devices) |
| `flash_inst.sv` | FLASH instantiation for all CS |
| `all_mem_inst.sv` | Mixed memory config: CS0–2 SRAM, CS3–5 SDRAM, CS6–7 FLASH |

## Memory Map

Bits `[31:29]` of the WISHBONE address select the target: `3'b000` = memory, `3'b011` = controller registers.

| Chip Select | Start | End |
|-------------|-------|-----|
| CS0 | `0x00200000` | `0x003FFFFF` |
| CS1 | `0x00400000` | `0x005FFFFF` |
| CS2 | `0x00800000` | `0x009FFFFF` |
| CS3 | `0x01000000` | `0x011FFFFF` |
| CS4 | `0x02000000` | `0x021FFFFF` |
| CS5 | `0x04000000` | `0x041FFFFF` |
| CS6 | `0x08000000` | `0x081FFFFF` |
| CS7 | `0x10000000` | `0x101FFFFF` |

Memory type per CS is read from bits `[3:1]` of its CSC register: `000` SDRAM, `001` SRAM, `010` FLASH, `011` SCSD (SCSD monitoring is not implemented).

## Prerequisites

- A SystemVerilog simulator with UVM support (the run commands below use **Synopsys VCS**; Verdi/FSDB dumping is used)
- UVM library (`uvm_pkg.sv`, `uvm_dpi.cc`)
- **Not included in this repo** – you must supply them:
  - DUT RTL: `mc_rtl.vh` (the `mc_top` design)
  - SRAM model: `mt58l1my18d.v` (Micron)
  - SDRAM model: `mt48lc2m32b2.v` (Micron 2Mx32)
  - FLASH model: `m8kx8.v`

## Compile-Time Defines

Select the memory models instantiated in the testbench:

| Define | Effect |
|--------|--------|
| `SRAM_ALL_CS` | Instantiate SRAM on all chip selects |
| `SDRAM_ALL_CS` | Instantiate SDRAM on all chip selects |
| `FLASH_ALL_CS` | Instantiate FLASH on all chip selects |
| `ALL_CS_DIFF_MEM` | CS0–2 SRAM, CS3–5 SDRAM, CS6–7 FLASH |

## Run-Time Plusargs

| Plusarg | Description |
|---------|-------------|
| `+UVM_TESTNAME=<test>` | Test to run |
| `+cs_target=<8-bit binary>` | Chip selects to exercise, e.g. `11111111` (all) or `00000001` (CS0 only) |
| `+tx_count=<n>` | Number of memory transactions per run |
| `+UVM_TIMEOUT=<n>` | Simulation timeout |

## Build & Run

Compile (adjust include paths to your environment):

```bash
vcs -sverilog -full64 -kdb -debug_access+all -l comp.log \
    +incdir+../../design/verilog \
    +incdir+../wb +incdir+../top +incdir+../sbd +incdir+../mem \
    +incdir+/home/projects/src \
    +incdir+../../MemoryModels/sram_models/MicronSRAM \
    +incdir+../../MemoryModels/sdram_models/2Mx32 \
    +incdir+../../MemoryModels/160b3ver \
    /home/projects/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
    +define+<SRAM_ALL_CS | SDRAM_ALL_CS | FLASH_ALL_CS | ALL_CS_DIFF_MEM> \
    ../top/top_tb.sv
```

Run examples:

```bash
# Register tests
./simv +UVM_TESTNAME=test_reg_reset   -l sim.log
./simv +UVM_TESTNAME=test_reg_wr_rd   -l sim.log

# Single chip select (CS0)
./simv +UVM_TESTNAME=test_cs0_sram    +cs_target=00000001 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000
./simv +UVM_TESTNAME=test_cs0_sdram   +cs_target=00000001 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000

# All chip selects (compile with matching +define)
./simv +UVM_TESTNAME=test_all_cs_sram  +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000   # +define+SRAM_ALL_CS
./simv +UVM_TESTNAME=test_all_cs_sdram +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=20000   # +define+SDRAM_ALL_CS
./simv +UVM_TESTNAME=test_all_cs_flash +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=30000   # +define+FLASH_ALL_CS

# Mixed memories (compile with +define+ALL_CS_DIFF_MEM)
./simv +UVM_TESTNAME=test_all_cs_diff_mem +cs_target=11111111 +tx_count=30 -l sim.log +UVM_TIMEOUT=30000
```

> Note: `top_tb.sv` calls `run_test("test_all_cs_diff_mem")` by default; `+UVM_TESTNAME` overrides it.

## Test List

| Test | Description | Required define |
|------|-------------|-----------------|
| `test_reg_reset` | Reads registers and checks reset values | any |
| `test_reg_wr_rd` | Register write/read-back | any |
| `test_cs0_sram` | Configure CS0 as SRAM, write/read memory | `SRAM_ALL_CS` |
| `test_cs0_sdram` | Configure CS0 as SDRAM, write/read memory | `SDRAM_ALL_CS` |
| `test_all_cs_sram` | All CS as SRAM | `SRAM_ALL_CS` |
| `test_all_cs_sdram` | All CS as SDRAM | `SDRAM_ALL_CS` |
| `test_all_cs_flash` | All CS as FLASH | `FLASH_ALL_CS` |
| `test_all_cs_diff_mem` | Mixed SRAM/SDRAM/FLASH across CS | `ALL_CS_DIFF_MEM` |

Each memory test runs a config sequence (programs the CSC/timing registers) followed by `wb_mem_seq` (random writes and reads).

## Pass / Fail Criteria

`mc_base_test::report()` declares a test **passed** when `num_matches == 2 * tx_count` and `num_mismatches == 0` (each transaction is a write plus a read-back). Otherwise a `UVM_ERROR` is reported with the match/mismatch counts. Mismatches are also printed by the scoreboard.

## Coverage

`wb_cov` samples every WB transaction: register vs. memory access, CS region, read/write, plus crosses of CS × read/write and CS × reg/mem.

## Waveforms

`top_tb.sv` dumps `mc.fsdb` (Verdi). Replace the `$fsdbDump*` calls with `$dumpfile/$dumpvars` if using another simulator.

## Known Limitations

- SCSD memory type is decoded but not monitored.
- Clocks: WISHBONE 200 MHz, memory controller 100 MHz (set in `top_tb.sv`).
- The FLASH read path in `mem_mon` uses a fixed `#344` delay before sampling data; adjust if timing registers change.
- Memory models and DUT RTL are third-party/proprietary and must be added separately.
