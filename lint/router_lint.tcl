#Liberty files are needed for logical and physical netlist designs
set search_path "./"
set link_library " "

set_app_var enable_lint true

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog {../rtl/router_fifo.v ../rtl/router_fsm.v ../rtl/router_reg.v ../rtl/router_sync.v ../rtl/router_top.v}

elaborate router_top

waive_lint -tag STARC05-2.5.1.2 -add router_top 

check_lint

report_lint -verbose -file report_lint_router.txt

