vcs -sverilog -full64 -kdb -debug_access+all -l comp.log \
+incdir+../../design/verilog \
+incdir+../wb \
+incdir+../top \
+incdir+../sbd \
+incdir+../mem \
+incdir+/home/projects/src \
+incdir+../../MemoryModels/sram_models/MicronSRAM \
+incdir+../../MemoryModels/sdram_models/2Mx32 \
+incdir+../../MemoryModels/160b3ver \
/home/projects/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
+define+ALL_CS_DIFF_MEM
../top/top_tb.sv

./simv +UVM_TESTNAME=test_all_cs_diff_mem +cs_target=11111111 +tx_count=10 -l sim.log +UVM_TIMEOUT=30000



