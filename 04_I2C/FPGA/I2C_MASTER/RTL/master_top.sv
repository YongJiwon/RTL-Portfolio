`timescale 1ns / 1ps

module master_top #(
    parameter int CLK_FREQ_HZ     = 100_000_000,
    parameter int UART_BAUD       = 9600,
    parameter int UART_OVERSAMPLE = 16,
    parameter logic [6:0] SLAVE_ADDR = 7'h42
)(
    input  logic clk,       // 100MHz system clock
    input  logic reset,     // Active High system reset
    input  logic uart_rxd,  // Physical UART RX pin from PC
    output logic scl,       // I2C SCL output to external slave board
    inout  wire  sda        // I2C SDA bidirectional pin to external slave board
);
    typedef enum logic [3:0] {
        IDLE       = 4'd0, // Wait for uart_rx rx_done pulse
        SEND_START = 4'd1, // Issue I2C START command pulse
        WAIT_START = 4'd2, // Wait until START command is done
        SEND_ADDR  = 4'd3, // Send {SLAVE_ADDR, write bit}
        WAIT_ADDR  = 4'd4, // Wait for address byte done and ACK sample
        SEND_DATA  = 4'd5, // Send UART payload byte
        WAIT_DATA  = 4'd6, // Wait for data byte done and ACK sample
        SEND_STOP  = 4'd7, // Issue I2C STOP command pulse
        WAIT_STOP  = 4'd8  // Wait until STOP command is done
    } state_t;

    // uart_rx consumes a 16x oversampling enable. For a 100MHz clock and
    // 9600 baud, this count is about 651 system clocks per tick. One full
    // UART bit then lasts 16 ticks, or about 10417 system clocks.
    localparam int UART_TICK_COUNT = (CLK_FREQ_HZ + ((UART_BAUD * UART_OVERSAMPLE) / 2)) /
                                     (UART_BAUD * UART_OVERSAMPLE);

    state_t state;

    logic       b_tick;
    logic       rx_done;
    logic [7:0] uart_rx_data;
    logic [7:0] uart_data_latched;

    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] tx_data;
    logic [7:0] i2c_rx_data;
    logic       ack_in;
    logic       ack_out;
    logic       i2c_busy;
    logic       i2c_done;
    logic       busy_seen;
    logic       ack_error;

    assign ack_in = 1'b1; // Read path is unused; NACK if a read command is ever issued

    baud_tick_gen #(
        .F_COUNT(UART_TICK_COUNT)
    ) U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(reset),
        .o_b_tick(b_tick)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(reset),
        .b_tick(b_tick),
        .rx(uart_rxd),
        .rx_data(uart_rx_data),
        .rx_done(rx_done)
    );

    I2C_Master_top U_I2C_MASTER_TOP (
        .clk(clk),
        .reset(reset),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .rx_data(i2c_rx_data),
        .ack_in(ack_in),
        .ack_out(ack_out),
        .busy(i2c_busy),
        .done(i2c_done),
        .scl(scl),
        .sda(sda)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state             <= IDLE;
            cmd_start         <= 1'b0;
            cmd_write         <= 1'b0;
            cmd_read          <= 1'b0;
            cmd_stop          <= 1'b0;
            tx_data           <= 8'h00;
            uart_data_latched <= 8'h00;
            busy_seen         <= 1'b0;
            ack_error         <= 1'b0;
        end else begin
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;

            case (state)
                IDLE: begin
                    busy_seen <= 1'b0;
                    ack_error <= 1'b0;
                    if (rx_done) begin
                        uart_data_latched <= uart_rx_data;
                        state             <= SEND_START;
                    end
                end

                SEND_START: begin
                    cmd_start <= 1'b1;
                    state     <= WAIT_START;
                end

                WAIT_START: begin
                    if (i2c_busy) begin
                        busy_seen <= 1'b1;
                    end
                    if ((busy_seen || i2c_busy) && i2c_done) begin
                        busy_seen <= 1'b0;
                        tx_data   <= {SLAVE_ADDR, 1'b0};
                        state     <= SEND_ADDR;
                    end
                end

                SEND_ADDR: begin
                    cmd_write <= 1'b1;
                    state     <= WAIT_ADDR;
                end

                WAIT_ADDR: begin
                    if (i2c_busy) begin
                        busy_seen <= 1'b1;
                    end
                    if ((busy_seen || i2c_busy) && i2c_done) begin
                        busy_seen <= 1'b0;
                        ack_error <= ack_error | ack_out;
                        tx_data   <= uart_data_latched;
                        state     <= SEND_DATA;
                    end
                end

                SEND_DATA: begin
                    cmd_write <= 1'b1;
                    state     <= WAIT_DATA;
                end

                WAIT_DATA: begin
                    if (i2c_busy) begin
                        busy_seen <= 1'b1;
                    end
                    if ((busy_seen || i2c_busy) && i2c_done) begin
                        busy_seen <= 1'b0;
                        ack_error <= ack_error | ack_out;
                        state     <= SEND_STOP;
                    end
                end

                SEND_STOP: begin
                    cmd_stop <= 1'b1;
                    state    <= WAIT_STOP;
                end

                WAIT_STOP: begin
                    if (i2c_busy) begin
                        busy_seen <= 1'b1;
                    end
                    if ((busy_seen || i2c_busy) && i2c_done) begin
                        busy_seen <= 1'b0;
                        state     <= IDLE;
                    end
                end

                default: begin
                    state     <= IDLE;
                    busy_seen <= 1'b0;
                end
            endcase
        end
    end
endmodule
