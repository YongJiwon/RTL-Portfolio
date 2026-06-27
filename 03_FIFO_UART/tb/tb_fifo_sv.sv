`timescale 1ns / 1ps

class transaction;

    //bit 0 or 1 : 2-state type
    //logic 0 or 1 or x or z : 4-state type
    rand bit [7:0] push_data;
    rand bit push;
    rand bit pop;

    bit [7:0] pop_data; //This is output for CL, thus, bit has 4-state
    // bit clk;
    // bit rst;
    bit full; 
    bit empty;

    function debug_print(string name);
        $display(
            "%t: [%s] push = %d, pop = %d, push_data = %d, pop_data = %d, full = %d, empty = %d",
            $time, name, push, pop, push_data, pop_data, full, empty);
    endfunction


endclass

interface fifo_interface;

    logic clk;
    logic rst;
    logic [7:0] push_data;
    logic push;
    logic pop;
    logic [7:0] pop_data;
    logic full;
    logic empty;

endinterface

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox; 
    event event_gen_next;

    function new(mailbox#(transaction) gen2drv_mbox, event event_gen_next);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.event_gen_next = event_gen_next;
    endfunction

    task run(int count);
        repeat (count) begin
            tr = new;  // tr 공간 생성
            tr.randomize();
            // assert (tr.randomize()) 
            // else $error("[GEN] tr.randomize() error !");
            gen2drv_mbox.put(tr);  // tr을 drive로 put
            tr.debug_print("GEN");
            @(event_gen_next);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event event_gen_next;
    virtual fifo_interface fifo_vif;

    function new(mailbox#(transaction) gen2drv_mbox, event event_gen_next,
                 virtual fifo_interface fifo_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event_gen_next = event_gen_next;
        this.fifo_vif = fifo_vif;
    endfunction

    task preset();  
        fifo_vif.rst = 1;
        fifo_vif.push_data = 0;
        fifo_vif.push = 0;
        fifo_vif.pop = 0;

        @(posedge fifo_vif.clk);
        @(posedge fifo_vif.clk);
        
        fifo_vif.rst = 0;

        @(negedge fifo_vif.clk);
        assert (fifo_vif.empty)  // empty = 1로 시작
            $display("[DRV Assert] reset pass: empty~!");
        else $display("[DRV Assert] reset fail: empty = %d", fifo_vif.empty);

        assert (!fifo_vif.full)  // full = 0로 시작
            $display("[DRV Assert] reset pass: not full~!");
        else $display("[DRV Assert] reset fail: full = %d", fifo_vif.full);

    endtask

    task push_only(int count);  // push_only
        $display("fifo push only test");

        repeat (count) begin
            gen2drv_mbox.get(tr);

            @(posedge fifo_vif.clk);
            #1;  // 1ns 지연된 posedge에서 drive
            
            fifo_vif.push = 1;
            fifo_vif.push_data = tr.push_data;
            fifo_vif.pop = 0;

            $display(
            "%t: push = %d, pop = %d, push_data = %d, pop_data = %d, full = %d, empty = %d",
            $time, fifo_vif.push, fifo_vif.pop, fifo_vif.push_data, fifo_vif.pop_data, fifo_vif.full, fifo_vif.empty);
            -> event_gen_next;
        end
    endtask

    task pop_only(int count);  //pop_only
        $display("fifo pop only test");

        repeat (count) begin
            gen2drv_mbox.get(tr);

            @(posedge fifo_vif.clk);
            #1;  // 1ns 지연된 posedge에서 drive

            fifo_vif.push = 0;
            fifo_vif.push_data = 0;
            fifo_vif.pop = 1;

            $display(
            "%t: push = %d, pop = %d, push_data = %d, pop_data = %d, full = %d, empty = %d",
            $time, fifo_vif.push, fifo_vif.pop, fifo_vif.push_data, fifo_vif.pop_data, fifo_vif.full, fifo_vif.empty);
            -> event_gen_next;
        end
    endtask



    task run();
        forever begin
            gen2drv_mbox.get(tr);
            tr.debug_print("DRV");
            @(posedge fifo_vif.clk);
            #1;
            fifo_vif.push = tr.push;
            fifo_vif.pop = tr.pop;
            fifo_vif.push_data = tr.push_data;
        end
    endtask

endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual fifo_interface fifo_vif;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual fifo_interface fifo_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.fifo_vif = fifo_vif;
    endfunction

    task run();
        forever begin
        @(negedge fifo_vif.clk); 
            tr = new;  // tr 생성
            tr.push = fifo_vif.push;
            tr.push_data = fifo_vif.push_data;
            tr.pop = fifo_vif.pop;
            tr.pop_data = fifo_vif.pop_data;
            tr.full = fifo_vif.full;
            tr.empty = fifo_vif.empty;
            mon2scb_mbox.put(tr);  
            tr.debug_print("MON");
        end
    endtask

endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event event_gen_next;
    int total_cnt = 0, pass_cnt = 0, fail_cnt = 0;
    // byte mem[256];  

    bit [7:0] fifo_que[$:16];
    bit [7:0] compare_data; 

    function new(mailbox#(transaction) mon2scb_mbox, event event_gen_next);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.event_gen_next = event_gen_next;
    endfunction

    task run();
        forever begin 
            mon2scb_mbox.get(tr);
            tr.debug_print("SCB");
            total_cnt ++;
            if (tr.push && (!tr.full)) begin
                fifo_que.push_front(tr.push_data);
            end
            if (tr.pop && (!tr.empty)) begin
                // pass, fail decision
                compare_data = fifo_que.pop_back();
                if (tr.pop_data == compare_data) begin // pop_back한 것과 pop_data가 같은 지 비교
                    pass_cnt ++;
                    $display("%t: pass pop ~, expected = %d, actual = %d ", $time, compare_data, tr.pop_data);
                end else begin
                    fail_cnt ++;
                    $display("%t: fail pop = %d, pop_data = %d, empty = %d", $time, tr.pop, tr.pop_data, tr.empty);
                end
            end
            -> event_gen_next;
        end
    endtask
                                    
endclass

class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event event_gen_next;

    virtual fifo_interface fifo_vif;

    int run_count;

    function new(virtual fifo_interface fifo_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, event_gen_next);
        drv = new(gen2drv_mbox, event_gen_next, fifo_vif);
        mon = new(mon2scb_mbox, fifo_vif);
        scb = new(mon2scb_mbox, event_gen_next);

        this.fifo_vif = fifo_vif;
    endfunction

    task run();
        // reset test by assertion
        drv.preset();

        // push only test for full signal "1"
        run_count = 16;
        fork
        gen.run(run_count);
        drv.push_only(run_count);  
        join
        $display("[ENV] push only test end");
        #10; 
        if (fifo_vif.full) $display("pass : push only test");
        else $display("fail : push only test");
        #20;
        
        fork
        gen.run(run_count);
        drv.pop_only(run_count);  
        join
        $display("[ENV] pop only test end");
        #10; 
        if (fifo_vif.empty) $display("pass : pop only test");
        else $display("fail : pop only test");
        #20;

        fork
        gen.run(100);
        drv.run();
        mon.run();
        scb.run();
        join_any
        #20;
        $display("fifo constraint random test end");
        $display("env run task end");
        $display("____________________");
        $display("** FIFO Verification **");
        $display("** total test num = %2d **", scb.total_cnt);
        $display("** pass test num = %2d **", scb.pass_cnt);
        $display("** fail test num = %2d **", scb.fail_cnt);
        $display("********************");
        $stop;
    endtask

endclass

module tb_fifo_sv ();

    fifo_interface fifo_if ();

    environment env;

    fifo_sv dut (

        .clk(fifo_if.clk), //Input
        .rst(fifo_if.rst), //Input
        .push_data(fifo_if.push_data),//Input
        .push(fifo_if.push), //Input
        .pop(fifo_if.pop), //Input
        .pop_data(fifo_if.pop_data), //output
        .full(fifo_if.full),//output
        .empty(fifo_if.empty)//output

    );

    always #5 fifo_if.clk = ~fifo_if.clk;

    initial begin
        fifo_if.clk = 0;
        env = new(fifo_if);
        env.run();
    end
endmodule
