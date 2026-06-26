`timescale 1ns / 1ps

module i2c_slave #(
    parameter logic [6:0] SLAVE_ADDR = 7'h42
)(
    input  wire       clk,
    input  wire       reset_n,
    output logic [7:0] data_out,
    output logic       data_valid,
    inout  wire        sda,
    input  logic        scl
);
    typedef enum logic [2:0] {
        IDLE = 3'b000, // Idle bus state: wait for START condition
        ADDR,          // Receive 7-bit address and write bit
        ADDR_ACK,      // Drive ACK when address matches and write bit is 0
        DATA,          // Receive 8-bit write data
        DATA_ACK,      // Drive ACK after data byte is received
        WAIT_STOP      // Wait for STOP condition and make data_valid pulse
    } state_t;

    state_t state;

    logic [2:0] scl_sync;
    logic [2:0] sda_sync;
    logic [7:0] addr_byte;
    logic [7:0] data_byte;
    logic [2:0] bit_cnt;
    logic       sda_drive_low;
    logic       addr_match;
    logic       write_bit_ok;
    logic       data_ready;

    assign sda = sda_drive_low ? 1'b0 : 1'bz; // Open-drain SDA: drive only 0 or high-Z

    wire scl_rise = (scl_sync[2:1] == 2'b01);
    wire scl_fall = (scl_sync[2:1] == 2'b10);
    wire start_condition = (scl_sync[2] && (sda_sync[2:1] == 2'b10));
    wire stop_condition  = (scl_sync[2] && (sda_sync[2:1] == 2'b01));

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scl_sync <= 3'b111;
            sda_sync <= 3'b111;
        end else begin
            scl_sync <= {scl_sync[1:0], scl};
            sda_sync <= {sda_sync[1:0], sda};
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= IDLE;
            data_out      <= 8'h00;
            data_valid    <= 1'b0;
            addr_byte     <= 8'h00;
            data_byte     <= 8'h00;
            bit_cnt       <= 3'd7;
            sda_drive_low <= 1'b0;
            addr_match    <= 1'b0;
            write_bit_ok  <= 1'b0;
            data_ready    <= 1'b0;
        end else begin
            data_valid <= 1'b0;

            if (start_condition) begin
                state         <= ADDR;
                addr_byte     <= 8'h00;
                data_byte     <= 8'h00;
                bit_cnt       <= 3'd7;
                sda_drive_low <= 1'b0;
                addr_match    <= 1'b0;
                write_bit_ok  <= 1'b0;
                data_ready    <= 1'b0;
            end else begin
                case (state)
                    IDLE: begin
                        sda_drive_low <= 1'b0;
                    end

                    ADDR: begin
                        if (scl_rise) begin
                            addr_byte[bit_cnt] <= sda_sync[2];
                            if (bit_cnt == 3'd0) begin
                                addr_match   <= (addr_byte[7:1] == SLAVE_ADDR);
                                write_bit_ok <= (sda_sync[2] == 1'b0);
                                bit_cnt      <= 3'd7;
                                state        <= ADDR_ACK;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end

                    ADDR_ACK: begin
                        if (!scl_sync[2]) begin
                            sda_drive_low <= addr_match && write_bit_ok;
                        end
                        if (scl_rise) begin
                            state <= (addr_match && write_bit_ok) ? DATA : WAIT_STOP;
                        end
                    end

                    DATA: begin
                        if (!scl_sync[2]) begin
                            sda_drive_low <= 1'b0;
                        end
                        if (scl_rise) begin
                            data_byte[bit_cnt] <= sda_sync[2];
                            if (bit_cnt == 3'd0) begin
                                data_out   <= {data_byte[7:1], sda_sync[2]};
                                data_ready <= 1'b1;
                                bit_cnt    <= 3'd7;
                                state      <= DATA_ACK;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end

                    DATA_ACK: begin
                        if (!scl_sync[2]) begin
                            sda_drive_low <= 1'b1;
                        end
                        if (scl_rise) begin
                            state <= WAIT_STOP;
                        end
                    end

                    WAIT_STOP: begin
                        if (!scl_sync[2]) begin
                            sda_drive_low <= 1'b0;
                        end
                        if (stop_condition) begin
                            sda_drive_low <= 1'b0;
                            if (data_ready) begin
                                data_valid <= 1'b1;
                                data_ready <= 1'b0;
                            end
                            state <= IDLE;
                        end
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
