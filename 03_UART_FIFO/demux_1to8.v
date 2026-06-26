`timescale 1ns / 1ps

module demux_1to8 (
    input wire hit,
    input wire [2:0] digit_sel,

    input wire set_mode_sw,
    input wire stopwatch_watch_sw,

    output reg [3:0] digit_0,
    output reg [3:0] digit_1,
    output reg [3:0] digit_2,
    output reg [3:0] digit_3,
    output reg [3:0] digit_4,
    output reg [3:0] digit_5,
    output reg [3:0] digit_6,
    output reg [3:0] digit_7
);

    always @(*) begin
        digit_0 = 4'b1111;
        digit_1 = 4'b1111;
        digit_2 = 4'b1111;
        digit_3 = 4'b1111;
        digit_4 = 4'b1111;
        digit_5 = 4'b1111;
        digit_6 = 4'b1111;
        digit_7 = 4'b1111;
        if (set_mode_sw && !stopwatch_watch_sw) begin
            case (digit_sel)
                3'd0: digit_0 = {3'b111, hit};
                3'd1: digit_1 = {3'b111, hit};
                3'd2: digit_2 = {3'b111, hit};
                3'd3: digit_3 = {3'b111, hit};
                3'd4: digit_4 = {3'b111, hit};
                3'd5: digit_5 = {3'b111, hit};
                3'd6: digit_6 = {3'b111, hit};
                3'd7: digit_7 = {3'b111, hit};
            endcase
        end
    end

endmodule
