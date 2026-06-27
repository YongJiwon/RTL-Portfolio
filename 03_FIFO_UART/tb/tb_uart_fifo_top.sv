`timescale 1ns / 1ps

//============================================================
// Transaction
//============================================================
class transaction;

    rand bit [7:0] tx_byte;   // expected byte: Driver sends to DUT rx
         bit [7:0] rx_byte;   // actual byte: Monitor restores from DUT tx

    function void debug_print(string name);
        $display("%t: [%s] tx_byte = %h, rx_byte = %h",
                 $time, name, tx_byte, rx_byte);
    endfunction

endclass


//============================================================
// UART Interface
//============================================================
interface uart_interface;

    logic clk;
    logic rst;

    // DUT input
    logic rx;

    // DUT output
    logic tx;

endinterface


//============================================================
// Generator
//============================================================
class generator;

    transaction tr;
    mailbox #(transaction) gen2drv_mbox;

    function new(mailbox #(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task put_byte(input bit [7:0] data);
        tr = new();
        tr.tx_byte = data;

        gen2drv_mbox.put(tr);

        tr.debug_print("GEN");
    endtask

    // Directed pattern test for continuous bit/byte verification
    task run_directed();
        put_byte(8'h55);  // 0101_0101
        put_byte(8'hAA);  // 1010_1010
        put_byte(8'hF0);  // 1111_0000
        put_byte(8'h0F);  // 0000_1111
        put_byte(8'h00);  // all zero
        put_byte(8'hFF);  // all one
    endtask

    // Random byte test
    task run_random(int count);
        repeat (count) begin
            tr = new();

            assert(tr.randomize())
            else $error("[GEN] randomize error");

            gen2drv_mbox.put(tr);

            tr.debug_print("GEN_RANDOM");
        end
    endtask

endclass


//============================================================
// Driver
//============================================================
class driver;

    transaction tr;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) exp_mbox;

    virtual uart_interface uart_vif;

    // 9600 bps
    // 1 bit period = 1 / 9600 sec = about 104.166 us
    // timescale 1ns -> about 104_160 ns
    parameter int BIT_PERIOD = 104_160;

    function new(mailbox #(transaction) gen2drv_mbox,
                 mailbox #(transaction) exp_mbox,
                 virtual uart_interface uart_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.exp_mbox     = exp_mbox;
        this.uart_vif     = uart_vif;
    endfunction

    task preset();
        uart_vif.rst = 1'b1;
        uart_vif.rx  = 1'b1;   // UART idle state

        repeat (5) @(posedge uart_vif.clk);

        uart_vif.rst = 1'b0;

        repeat (5) @(posedge uart_vif.clk);

        // idle time before first transmission
        #(BIT_PERIOD);

        $display("[DRV] reset done");
    endtask

    // UART frame generation
    // Frame format: start bit(0) + data bits LSB first + stop bit(1)
    task send_uart_byte(input bit [7:0] data);
        int i;

        // start bit
        uart_vif.rx = 1'b0;
        #(BIT_PERIOD);

        // data bits, LSB first
        for (i = 0; i < 8; i++) begin
            uart_vif.rx = data[i];
            #(BIT_PERIOD);
        end

        // stop bit
        uart_vif.rx = 1'b1;
        #(BIT_PERIOD);
    endtask

    task run(int count);
        repeat (count) begin
            gen2drv_mbox.get(tr);

            tr.debug_print("DRV");

            // Send expected value to scoreboard before driving DUT
            exp_mbox.put(tr);

            // Drive UART rx line
            send_uart_byte(tr.tx_byte);
        end
    endtask

endclass


//============================================================
// Monitor
//============================================================
class monitor;

    transaction tr;

    mailbox #(transaction) mon2scb_mbox;

    virtual uart_interface uart_vif;

    parameter int BIT_PERIOD = 104_160; //651x16x10ns

    function new(mailbox #(transaction) mon2scb_mbox,
                 virtual uart_interface uart_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.uart_vif     = uart_vif;
    endfunction

    // UART frame decode from DUT tx line
    task receive_uart_byte(output bit [7:0] data);
        int i;

        // detect start bit: tx falling edge
        @(negedge uart_vif.tx);

        // move to center of data[0]
        #(BIT_PERIOD + BIT_PERIOD / 2);
        //#(BIT_PERIOD);
        //#(BIT_PERIOD);

        // sample data bits, LSB first
        for (i = 0; i < 8; i++) begin
            data[i] = uart_vif.tx;
            #(BIT_PERIOD);
        end

        // stop bit check at stop bit center
        if (uart_vif.tx !== 1'b1) begin
            $display("%t [MON] stop bit error. tx = %b",
                     $time, uart_vif.tx);
        end

        // IMPORTANT:
        // Do not add extra #(BIT_PERIOD) here.
        // Otherwise monitor can miss the next start bit in continuous frames.
    endtask

    task run();
        forever begin
            tr = new();

            receive_uart_byte(tr.rx_byte);

            mon2scb_mbox.put(tr);

            tr.debug_print("MON");
        end
    endtask

endclass


//============================================================
// Scoreboard
//============================================================
class scoreboard;

    transaction exp_tr;
    transaction act_tr;

    mailbox #(transaction) exp_mbox;
    mailbox #(transaction) mon2scb_mbox;

    bit [7:0] expected_q[$];
    bit [7:0] expected_data;

    int total_cnt = 0;
    int pass_cnt  = 0;
    int fail_cnt  = 0;

    function new(mailbox #(transaction) exp_mbox,
                 mailbox #(transaction) mon2scb_mbox);
        this.exp_mbox     = exp_mbox;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin

            // Get at least one expected value first
            if (expected_q.size() == 0) begin
                exp_mbox.get(exp_tr);
                expected_q.push_back(exp_tr.tx_byte);

                $display("%t: [SCB QUEUE PUSH] expected_q push = %h, size = %0d",
                         $time, exp_tr.tx_byte, expected_q.size());
            end

            // Move additional expected values to queue
            while (exp_mbox.num() > 0) begin
                exp_mbox.get(exp_tr);
                expected_q.push_back(exp_tr.tx_byte);

                $display("%t: [SCB QUEUE PUSH] expected_q push = %h, size = %0d",
                         $time, exp_tr.tx_byte, expected_q.size());
            end

            // Wait for actual value from monitor
            mon2scb_mbox.get(act_tr);

            total_cnt++;

            expected_data = expected_q.pop_front();

            if (act_tr.rx_byte == expected_data) begin
                pass_cnt++;

                $display("%t: [SCB PASS] expected = %h, actual = %h, q_size = %0d",
                         $time, expected_data, act_tr.rx_byte, expected_q.size());
            end else begin
                fail_cnt++;

                $display("%t: [SCB FAIL] expected = %h, actual = %h, q_size = %0d",
                         $time, expected_data, act_tr.rx_byte, expected_q.size());
            end
        end
    endtask

endclass


//============================================================
// Environment
//============================================================
class environment;

    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) exp_mbox;
    mailbox #(transaction) mon2scb_mbox;

    virtual uart_interface uart_vif;

    int run_count;

    function new(virtual uart_interface uart_vif);
        gen2drv_mbox = new();
        exp_mbox     = new();
        mon2scb_mbox = new();

        this.uart_vif = uart_vif;

        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, exp_mbox, uart_vif);
        mon = new(mon2scb_mbox, uart_vif);
        scb = new(exp_mbox, mon2scb_mbox);
    endfunction

    task run();
        drv.preset();

        // Directed continuous byte test
        run_count = 1000;

        fork
            //gen.run_directed();
            gen.run_random(run_count);
            drv.run(run_count);//run_count
            mon.run();
            scb.run();
        join_any

        // Wait until all expected bytes are checked
        wait (scb.total_cnt == run_count);

        #100000;

        $display("====================================");
        $display("uart fifo directed verification end");
        $display("total = %0d", scb.total_cnt);
        $display("pass  = %0d", scb.pass_cnt);
        $display("fail  = %0d", scb.fail_cnt);
        $display("====================================");

        $stop;
    endtask

endclass


//============================================================
// Testbench Top
//============================================================
module tb_uart_fifo_top();

    uart_interface uart_if();

    environment env;

    uart_fifo_top DUT (
        .clk (uart_if.clk),
        .rst (uart_if.rst),
        .rx  (uart_if.rx),
        .tx  (uart_if.tx)
    );

    always #5 uart_if.clk = ~uart_if.clk;

    initial begin
        uart_if.clk = 1'b0;
        uart_if.rx  = 1'b1;   // UART idle state

        env = new(uart_if);
        env.run();
    end

endmodule