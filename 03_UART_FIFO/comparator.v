`timescale 1ns / 1ps

module comparator (
    input  wire clk,
    input  wire rst_n,
    input  wire tick,
    output reg  hit
);

    reg [8:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            hit   <= 0;
        end else begin
            if (tick) begin
                if (count == 499) begin
                    count <= 0;
                    hit   <= ~hit;
                end else begin
                    count <= count + 1;
                end
            end
        end
    end
endmodule
