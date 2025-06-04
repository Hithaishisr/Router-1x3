# Makefile for RTL Design Compiler automation

# Default target
.PHONY: all clean dcshell

all:
	@echo "Use 'make synthesize' to run synthesis or 'make clean' to clean the workspace."

clean:
	@rm -r alib* *netlist* *.pvl *.log *.pdf *.mr *.syn *.svf 2>/dev/null || true
	@echo "Cleanup complete."

synthesize:
	@dc_shell -f "router_top.tcl"


