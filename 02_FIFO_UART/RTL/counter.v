`timescale 1ns / 1ps

module counter (
    input wire clk,
    input wire rst,
    output reg [2:0] digit_sel
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            digit_sel <= 3'd0;
        end else begin
            digit_sel <= digit_sel + 3'd1;
        end
    end

endmodule

