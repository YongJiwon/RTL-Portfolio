`timescale 1ns / 1ps
module tb_uart_loopback ();

    parameter   //Baud_DELAY = 2_000,
                BAUD_PERIOD = (100_000_000/9600) * 10; //- Baud_DELAY; //1 clock이 10ns이므로 곱하기 10
    reg [7:0] compare_data;
    reg clk, rst, rx;
    wire tx;

    uart_loopback dut (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx)
    );

    always #5 clk = ~clk;

    integer i;

    task SENDER_UART(input [7:0] send_data);  //pc tx 역할 대신 수행
        begin
            //pc tx 모듈 설계

            //start 신호 주기
            rx = 0;
            //start bit
            #(BAUD_PERIOD);
            //data bit
            for (i = 0; i < 8; i = i + 1) begin
                //rx, send_data[0]~[7]
                rx = send_data[i];
                #(BAUD_PERIOD);
            end
            //stop bit
            rx = 1;
            #(BAUD_PERIOD);
            
        end
    endtask


    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;
        compare_data = 8'h30; //ascii '0'
        #10;
        rst = 0;
        @(negedge clk);
        @(negedge clk);

        
        SENDER_UART(compare_data);
        
        #(BAUD_PERIOD*10); 

       /* SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
        SENDER_UART(compare_data);
*/



        $stop;
    end


endmodule
