`ifndef I2C_COVERAGE_SV
`define I2C_COVERAGE_SV

    class i2c_coverage extends uvm_subscriber #(transaction);
        `uvm_component_utils(i2c_coverage)

        transaction tr;

        covergroup i2c_cg;

            option.per_instance = 1;

            cp_ack_error : coverpoint tr.ack_error {
                bins ack_ok    = {0};
                bins ack_error = {1};
            }

            cp_slave_addr : coverpoint tr.slave_addr {
                bins addr_zero  = {7'h00};
                bins addr_low1  = {[7'h01 : 7'h20]};
                bins addr_low2  = {[7'h21 : 7'h41]};
                bins addr_match = {7'h42};
                bins addr_mid   = {[7'h43 : 7'h55]};
                bins addr_high1 = {[7'h56 : 7'h7E]};
                bins addr_max   = {7'h7F};
            }

            cp_data_in : coverpoint tr.data_in {
                bins data_zero = {8'h00};
                bins data_max  = {8'hff};
                bins data_etc  = {[8'h01 : 8'hFE]};
            }

            cx_addr_data : cross cp_slave_addr, cp_data_in;
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            i2c_cg = new();
        endfunction

        function void write(transaction t);
            tr = t;
            i2c_cg.sample();
        endfunction

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("COV", "===================================", UVM_LOW)
            `uvm_info("COV", "====== Functional Coverage ========", UVM_LOW)
            `uvm_info("COV", $sformatf("  전체       : %6.2f %%", i2c_cg.get_inst_coverage()), UVM_LOW)
            `uvm_info("COV", $sformatf("  ACK 상태   : %6.2f %%(ack/nack)", i2c_cg.cp_ack_error.get_inst_coverage()), UVM_LOW)
            `uvm_info("COV", $sformatf("  Slave 주소 : %6.2f %%(zero/low/match/mid/high/max)", i2c_cg.cp_slave_addr.get_inst_coverage()), UVM_LOW)
            `uvm_info("COV", $sformatf("  Write Data : %6.2f %%(0/FF/etc)", i2c_cg.cp_data_in.get_inst_coverage()), UVM_LOW)
            `uvm_info("COV", $sformatf("  주소x데이터 : %6.2f %%(cross)", i2c_cg.cx_addr_data.get_inst_coverage()), UVM_LOW)
            `uvm_info("COV", "===================================", UVM_LOW)

            if (i2c_cg.get_inst_coverage() < 100.0) begin
                `uvm_warning("COV", "커버리지 100% 미달! 시나리오를 추가하거나 더 테스트를 진행하시오.")
            end
        endfunction
    endclass //i2c_coverage

`endif // I2C_COVERAGE_SV
