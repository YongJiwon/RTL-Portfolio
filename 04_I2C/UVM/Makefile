VCS_OPTS = -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/10ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

VCS_INCDIR = +incdir+tb +incdir+rtl

VCS_OUTPUT = -o simv

VCS_SRC_FILES = ./tb/tb_i2c_uvm.sv \
                ./rtl/i2c_master.sv \
                ./rtl/i2c_slave.sv

TEST ?= test
SEED ?= 1
INFO_LEVEL ?= UVM_DEBUG

SIMV_OPTS = +UVM_TESTNAME=$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=$(SEED)
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name sim1

.PHONY: compile simv clean

all: simv

compile:
	@vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_SRC_FILES) $(VCS_OUTPUT)
	@echo "타겟 [$@]"

simv: compile
	@./simv $(SIMV_OPTS)
	@echo "의존 타겟 [$<]"
	@echo "타겟 [$@]"

clean:
	rm -rf simv* csrc *.log *.key *.h ucli.key DVEfiles coverage.vdb
	@echo "결과물 정리 중 ..."