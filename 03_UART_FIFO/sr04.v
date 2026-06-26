module sr04(
    input  wire       clk,
    input  wire       rst,
    input  wire       u_tick,      // 1us tick
    input  wire       sr04_start,
    input  wire       echo,
    output reg        trig,
    output reg [8:0]  dist
);

    parameter IDLE     = 2'd0;
    parameter START    = 2'd1;
    parameter WAIT     = 2'd2;
    parameter RESPONSE = 2'd3;

    reg [1:0] state, next_state;

    reg [5:0]  t_cnt;
    reg [5:0]  dist_counter_reg;
    reg [8:0]  dist_reg;

    reg [15:0] wait_timeout;
    reg [15:0] response_timeout;

    // echo 동기화
    reg echo_d1, echo_d2;
    wire echo_sync;

    assign echo_sync = echo_d2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            echo_d1 <= 0;
            echo_d2 <= 0;
        end else begin
            echo_d1 <= echo;
            echo_d2 <= echo_d1;
        end
    end

    // 상태 천이
    always @(*) begin
        case (state)
            IDLE: begin
                if (sr04_start)
                    next_state = START;
                else
                    next_state = IDLE;
            end

            START: begin
                if (t_cnt >= 10)
                    next_state = WAIT;
                else
                    next_state = START;
            end

            WAIT: begin
                if (echo_sync)
                    next_state = RESPONSE;
                else if (wait_timeout >= 16'd30000)   // 30ms timeout
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            RESPONSE: begin
                if (!echo_sync)
                    next_state = IDLE;
                else if (response_timeout >= 16'd30000) // 30ms timeout
                    next_state = IDLE;
                else
                    next_state = RESPONSE;
            end

            default: next_state = IDLE;
        endcase
    end

    // 상태 레지스터 및 trig 제어
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            trig  <= 0;
            t_cnt <= 0;
            wait_timeout <= 0;
            response_timeout <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    trig <= 0;
                    t_cnt <= 0;
                    wait_timeout <= 0;
                    response_timeout <= 0;
                end

                START: begin
                    trig <= 1;
                    if (u_tick)
                        t_cnt <= t_cnt + 1;
                end

                WAIT: begin
                    trig <= 0;
                    if (u_tick)
                        wait_timeout <= wait_timeout + 1;
                end

                RESPONSE: begin
                    trig <= 0;
                    if (u_tick)
                        response_timeout <= response_timeout + 1;
                end

                default: begin
                    trig <= 0;
                end
            endcase
        end
    end

    // 거리 계산
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dist <= 0;
            dist_reg <= 0;
            dist_counter_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    dist_reg <= 0;
                    dist_counter_reg <= 0;
                end

                RESPONSE: begin
                    if (echo_sync) begin
                        if (u_tick) begin
                            if (dist_counter_reg >= 57) begin
                                dist_counter_reg <= 0;

                                if (dist_reg < 9'd511)
                                    dist_reg <= dist_reg + 1;
                            end else begin
                                dist_counter_reg <= dist_counter_reg + 1;
                            end
                        end
                    end else begin
                        dist <= dist_reg;
                    end
                end

                default: begin
                    // 유지
                end
            endcase
        end
    end

endmodule