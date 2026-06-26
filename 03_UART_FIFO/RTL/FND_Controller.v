module FND_Controller (
    input  wire       clk,
    input  wire       rst,
    input  wire [8:0] dist,
    output reg  [3:0] fnd_com,
    output reg  [7:0] fnd_data
);

    reg [16:0] refresh_cnt;
    wire [1:0] digit_sel;

    wire [3:0] ones;
    wire [3:0] tens;
    wire [3:0] hundreds;
    reg  [3:0] cur_digit;

    assign digit_sel = refresh_cnt[16:15];

    assign ones     = dist % 10;
    assign tens     = (dist / 10) % 10;
    assign hundreds = (dist / 100) % 10;

    always @(posedge clk or posedge rst) begin
        if (rst)
            refresh_cnt <= 0;
        else
            refresh_cnt <= refresh_cnt + 1;
    end

    always @(*) begin
        case (digit_sel)
            2'd0: begin
                fnd_com   = 4'b1110;
                cur_digit = ones;
            end
            2'd1: begin
                fnd_com   = 4'b1101;
                cur_digit = tens;
            end
            2'd2: begin
                fnd_com   = 4'b1011;
                cur_digit = hundreds;
            end
            2'd3: begin
                fnd_com   = 4'b0111;
                cur_digit = 4'd15;   // 빈 자리
            end
        endcase
    end

    always @(*) begin
        case (cur_digit)
            4'd0: fnd_data = 8'hC0;
            4'd1: fnd_data = 8'hF9;
            4'd2: fnd_data = 8'hA4;
            4'd3: fnd_data = 8'hB0;
            4'd4: fnd_data = 8'h99;
            4'd5: fnd_data = 8'h92;
            4'd6: fnd_data = 8'h82;
            4'd7: fnd_data = 8'hF8;
            4'd8: fnd_data = 8'h80;
            4'd9: fnd_data = 8'h90;
            default: fnd_data = 8'hFF;
        endcase
    end

endmodule
