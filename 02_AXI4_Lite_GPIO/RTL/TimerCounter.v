`timescale 1ns / 1ps



module TimerCounter(
    input  wire     clk,
    input  wire     rst_n,
    input  wire     cnt_en,
    input  wire     intr_en,
    input  wire     [31:0] psc,
    input  wire     [31:0] arr,
    input  wire     cnt_valid,
    input  wire     [31:0] i_cnt,
    output wire     [31:0] o_cnt,
    output wire     intr
);

reg [31:0] counter;
reg [31:0] psc_counter;
reg psc_tick;
reg intr_tick;


assign o_cnt = counter;
assign intr = intr_tick & intr_en;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        psc_counter <= 0;
        psc_tick <= 1'b0;
    end else begin
        if (cnt_en) begin
            if(psc_counter == psc) begin
                psc_counter <= 0;
                psc_tick <= 1'b1;
            end else begin
                psc_counter <= psc_counter + 1'b1;
                psc_tick <= 1'b0;
            end
        end 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        intr_tick <= 1'b0;
    end else begin
        intr_tick <= 1'b0;
        if(cnt_valid) begin
            counter <= i_cnt;
        end
        else if(cnt_en) begin
            if(psc_tick) begin
                if(counter == arr) begin
                    counter <= 0;
                    intr_tick <= 1'b1;
                end else begin
                    counter <= counter + 1;
                    intr_tick <= 1'b0;
                end
            end 
        end
        else begin
            counter <= counter;
        end
    end
end






endmodule
