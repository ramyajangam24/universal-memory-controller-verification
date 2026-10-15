# universal-memory-controller-verification
A SystemVerilog/UVM verification environment for a WISHBONE-slave memory controller (mc_top). The testbench drives register-programming and memory read/write traffic on the WISHBONE bus, passively monitors the memory-side pins, and a scoreboard checks that what the DUT put on the memory bus matches what was requested on the WISHBONE side.
