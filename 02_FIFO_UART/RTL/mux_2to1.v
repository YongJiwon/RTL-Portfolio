`timescale 1ns / 1ps

module mux_2to1 (
    input wire [3:0] digit_ones,
    input wire [3:0] digit_tens,
    input wire digit_sel,
    output wire [3:0] digit_out
);
    assign digit_out = (digit_sel) ? digit_ones : digit_tens;
endmodule
