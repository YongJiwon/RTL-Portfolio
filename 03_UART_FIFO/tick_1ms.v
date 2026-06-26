module tick_1ms #(
    parameter CLOCK_FREQ_HZ = 100_000_000,
    parameter TICK_HZ = 1000,
    localparam TICK_COUNT = CLOCK_FREQ_HZ / TICK_HZ,
    localparam CNT_WIDTH = $clog2(TICK_COUNT)
)(
    input  wire clk,
    input  wire rst_n,
    output reg  tick_1ms
);

    reg [CNT_WIDTH-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            tick_1ms <= 0;
        end else begin
            if (count == TICK_COUNT-1) begin
                count <= 0;
                tick_1ms <= 1;
            end else begin
                count <= count + 1;
                tick_1ms <= 0;
            end
        end
    end

endmodule