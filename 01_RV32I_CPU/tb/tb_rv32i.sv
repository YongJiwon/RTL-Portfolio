`timescale 1ns / 1ps

module tb_rv32i;

    logic clk, rst;

    always #5 clk = ~clk;   
    top_rv32i_soc dut(.*);

    

initial begin
    clk = 1;
    rst = 1;
    //repeat (2) 
    @(negedge clk);
    rst = 0;
    repeat (150) @(negedge clk);
    
    $stop;
end
endmodule
