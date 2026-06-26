`timescale 1ns / 1ps



module tb_dedicated_cpu;


logic       clk;
logic       rst;
logic [7:0] out;


always #5 clk = ~clk;

dedicated_cpu dut(.*   );


initial begin
    clk = 0;
    rst = 1;
    @(negedge clk);
    @(negedge clk);
    rst = 0;
    #1000;
    $stop;

end


endmodule
