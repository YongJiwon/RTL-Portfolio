`timescale 1ns / 1ps

module counter_8 (
    input wire clk,
    input wire rst_n,
    output reg [2:0] digit_sel
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_sel <= 3'd0;
        end else begin
            digit_sel <= digit_sel + 3'd1;
        end
    end

endmodule

