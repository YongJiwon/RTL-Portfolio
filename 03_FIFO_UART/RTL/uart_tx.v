`timescale 1ns / 1ps

module uart_tx (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,   // 전송하고자 하는 신호
    input        b_tick,    // baud rate마다 한번씩
    output       tx_busy,
    output       tx         // 전송된 결과.
);
    // 5개의 state 지정
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    parameter BIT_CNT = 7;  // 전송하고자 하는 데이터의 (비트 - 1)

    reg [2:0] c_state, n_state;
    reg tx_reg, tx_next;
    // tx data register
    reg [7:0] data_reg, data_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg tx_busy_reg, tx_busy_next;


    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;


    // 값 초기화
    always @(posedge clk, posedge rst) begin
        if (rst) begin  //

            c_state        <= IDLE;
            tx_reg         <= 1'b1;
            data_reg       <= 8'h00;
            bit_cnt_reg    <= 3'b000;
            b_tick_cnt_reg <= 4'b0;
            tx_busy_reg    <= 0;

        end else begin
            c_state        <= n_state;
            tx_reg         <= tx_next;
            data_reg       <= data_next;
            bit_cnt_reg    <= bit_cnt_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
            tx_busy_reg    <= tx_busy_next;
        end
    end

    always @(*) begin
        n_state         = c_state;  // state
        tx_next         = tx_reg;  // tx output
        data_next       = data_reg;  // 전송된 값
        bit_cnt_next    = bit_cnt_reg;  // 전송중인 데이터 비트 순번
        b_tick_cnt_next = b_tick_cnt_reg;
        tx_busy_next    = tx_busy_reg;

        // current_state
        case (c_state)
            IDLE: begin
                tx_next      = 1'b1;
                tx_busy_next = 1'b0;
                if (tx_start) begin
                    tx_busy_next    = 1'b1;
                    data_next       = tx_data;
                    b_tick_cnt_next = 0;
                    n_state         = START;
                end
            end

            START: begin
                tx_next = 1'b0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        bit_cnt_next = 3'b000;
                        n_state = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end

                end
            end

            DATA: begin
                // parallel output
                //tx_next = data_reg[bit_cnt_reg];

                // serial output
                // data_reg 의 0번 비트를 출력으로.
                tx_next = data_reg[0];

                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        if (bit_cnt_reg == BIT_CNT) begin
                            n_state = STOP;
                        end else begin
                            data_next = {1'b0, data_reg[7:1]};
                            bit_cnt_next = bit_cnt_reg + 1;
                            n_state = DATA;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        tx_busy_next = 1'b0;
                        n_state = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end

            end
        endcase
    end
endmodule