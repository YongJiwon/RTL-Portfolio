`timescale 1ns / 1ps


module tb_TimerCounter;
    logic clk;
    logic rst_n;
    logic cnt_en;
    logic intr_en;
    logic [31:0] psc;
    logic [31:0] arr;
    logic [31:0] o_cnt;
    logic intr;
    logic [31:0] i_cnt;
    logic cnt_valid;

    TimerCounter dut(.*);
    initial clk = 0;
    always #5 clk = ~clk;

    


    task automatic TIM_SetPSC(logic [31:0] prescale);
        psc = prescale;
        
    endtask

    task automatic TIM_SetARR(logic [31:0] autoReload);
        arr = autoReload;
        
    endtask

    task automatic TIM_EnTimer();
        cnt_en = 1;
        
    endtask
    task automatic TIM_DisTimer();
        cnt_en = 0;
    endtask

    task automatic TIM_EnIntr();
        intr_en = 1;
    endtask

    task automatic TIM_DisIntr();
        intr_en = 0;
    endtask

    task automatic TIM_SetCNT(logic [31:0] CNT);
        i_cnt <= CNT;
        cnt_valid <= 1;
        @(posedge clk);
        cnt_valid <= 0;
    endtask


    initial begin
        rst_n = 0;
        i_cnt = 0;
        cnt_valid = 0;
        arr = 0;
        psc = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        TIM_SetPSC(100-1); // output 100MHz / 100 = 1MHz
        TIM_SetARR(1000-1); //TimerCounter 0~999 count, 1ms
        TIM_DisIntr();
        TIM_EnTimer();

        wait(o_cnt == 999);
        @(posedge clk);
        wait(o_cnt == 0);
        @(posedge clk);
        TIM_EnIntr();
        wait(o_cnt == 999);
        @(posedge clk);
        wait(o_cnt == 100);
        @(posedge clk);
        TIM_SetCNT(10);
        wait(o_cnt == 0);
        @(posedge clk);

        #10000;
        $stop;
        $finish;



    end



endmodule
