`timescale 1ns / 1ps

module uart (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       tx_busy,
    output logic       tx
);
    logic b_tick;

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .b_tick(b_tick),
        .tx_busy(tx_busy),
        .tx(tx)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(b_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_b_tick(b_tick)
    );
endmodule

module uart_rx (
    input  logic       clk,
    input  logic       rst,
    input  logic       b_tick,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);
    typedef enum logic [1:0] {
        RX_IDLE  = 2'd0,
        RX_START = 2'd1,
        RX_DATA  = 2'd2,
        RX_STOP  = 2'd3
    } rx_state_t;

    rx_state_t state;
    logic [4:0] tick_cnt;
    logic [2:0] bit_cnt;
    logic [7:0] data_reg;
    logic       rx_meta;
    logic       rx_sync;

    assign rx_data = data_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= RX_IDLE;
            tick_cnt <= 5'd0;
            bit_cnt  <= 3'd0;
            data_reg <= 8'h00;
            rx_done  <= 1'b0;
            rx_meta  <= 1'b1;
            rx_sync  <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
            rx_done <= 1'b0;

            case (state)
                RX_IDLE: begin
                    tick_cnt <= 5'd0;
                    bit_cnt  <= 3'd0;
                    if (!rx_sync) begin
                        state <= RX_START;
                    end
                end

                RX_START: begin
                    if (b_tick) begin
                        if (tick_cnt == 5'd7) begin
                            tick_cnt <= 5'd0;
                            if (!rx_sync) begin
                                state <= RX_DATA;
                            end else begin
                                state <= RX_IDLE;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                RX_DATA: begin
                    if (b_tick) begin
                        if (tick_cnt == 5'd15) begin
                            tick_cnt <= 5'd0;
                            data_reg <= {rx_sync, data_reg[7:1]};
                            if (bit_cnt == 3'd7) begin
                                bit_cnt <= 3'd0;
                                state   <= RX_STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                RX_STOP: begin
                    if (b_tick) begin
                        if ((tick_cnt == 5'd15) || ((tick_cnt > 5'd8) && !rx_sync)) begin
                            tick_cnt <= 5'd0;
                            rx_done  <= 1'b1;
                            state    <= RX_IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                default: begin
                    state    <= RX_IDLE;
                    tick_cnt <= 5'd0;
                    bit_cnt  <= 3'd0;
                end
            endcase
        end
    end
endmodule

module uart_tx (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    input  logic       b_tick,
    output logic       tx_busy,
    output logic       tx
);
    typedef enum logic [1:0] {
        TX_IDLE  = 2'd0,
        TX_START = 2'd1,
        TX_DATA  = 2'd2,
        TX_STOP  = 2'd3
    } tx_state_t;

    tx_state_t state;
    logic [3:0] tick_cnt;
    logic [2:0] bit_cnt;
    logic [7:0] data_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= TX_IDLE;
            tick_cnt <= 4'd0;
            bit_cnt  <= 3'd0;
            data_reg <= 8'h00;
            tx_busy  <= 1'b0;
            tx       <= 1'b1;
        end else begin
            state    <= state;
            tick_cnt <= tick_cnt;
            bit_cnt  <= bit_cnt;
            data_reg <= data_reg;
            tx_busy  <= tx_busy;
            tx       <= tx;

            case (state)
                TX_IDLE: begin
                    tx       <= 1'b1;
                    tx_busy  <= 1'b0;
                    tick_cnt <= 4'd0;
                    bit_cnt  <= 3'd0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= TX_START;
                    end
                end

                TX_START: begin
                    tx <= 1'b0;
                    if (b_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt <= 4'd0;
                            state    <= TX_DATA;
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                TX_DATA: begin
                    tx <= data_reg[0];
                    if (b_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt <= 4'd0;
                            if (bit_cnt == 3'd7) begin
                                bit_cnt <= 3'd0;
                                state   <= TX_STOP;
                            end else begin
                                data_reg <= {1'b0, data_reg[7:1]};
                                bit_cnt  <= bit_cnt + 1'b1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                TX_STOP: begin
                    tx <= 1'b1;
                    if (b_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt <= 4'd0;
                            tx_busy  <= 1'b0;
                            state    <= TX_IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end
                end

                default: begin
                    state    <= TX_IDLE;
                    tick_cnt <= 4'd0;
                    bit_cnt  <= 3'd0;
                    tx_busy  <= 1'b0;
                    tx       <= 1'b1;
                end
            endcase
        end
    end
endmodule

module baud_tick_gen #(
    parameter int F_COUNT = 100_000_000 / (9600 * 16),
    parameter int WIDTH   = (F_COUNT <= 1) ? 1 : $clog2(F_COUNT)
)(
    input  logic clk,
    input  logic rst,
    output logic o_b_tick
);
    logic [WIDTH-1:0] counter_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= '0;
            o_b_tick    <= 1'b0;
        end else begin
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= '0;
                o_b_tick    <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1'b1;
                o_b_tick    <= 1'b0;
            end
        end
    end
endmodule
