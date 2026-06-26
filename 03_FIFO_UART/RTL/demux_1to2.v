`timescale 1ns / 1ps

module demux_1to2 (
    input  wire btnR,
    input  wire btnL,
    input  wire btnD,
    input  wire sel,
    output reg  stopwatch_btnR,
    output reg  stopwatch_btnL,
    output reg  stopwatch_btnD,
    output reg  watch_btnR,
    output reg  watch_btnL,
    output reg  watch_btnD
);

    always @(*) begin
        case (sel)
            1'b0: begin
                stopwatch_btnR = btnR;
                stopwatch_btnL = btnL;
                stopwatch_btnD = btnD;
                watch_btnR = 0;
                watch_btnL = 0;
                watch_btnD = 0;
            end
            1'b1: begin
                watch_btnR = btnR;
                watch_btnL = btnL;
                watch_btnD = btnD;
                stopwatch_btnR = 0;
                stopwatch_btnL = 0;
                stopwatch_btnD = 0;
            end
            default: begin
                stopwatch_btnR = btnR;
                stopwatch_btnL = btnL;
                stopwatch_btnD = btnD;
                watch_btnR = 0;
                watch_btnL = 0;
                watch_btnD = 0;
            end
        endcase
    end
endmodule
