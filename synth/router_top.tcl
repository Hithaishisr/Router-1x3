remove_design -all
set search_path {../lib}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/router_fifo.v ../rtl/router_fsm.v ../rtl/router_reg.v ../rtl/router_sync.v ../rtl/router_top.v} 

elaborate router_top

link 

check_design

current_design  router_top

compile_ultra

write_file -f verilog -hier -output Router_Top_netlist.v


 

