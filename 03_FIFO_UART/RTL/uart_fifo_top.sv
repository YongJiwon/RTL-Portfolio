`timescale 1ns / 1ps

module uart_fifo_top ( // TOP Module [uart rx] -> [fifo push] -> [fifo pop] -> [uart tx]
    input logic clk,
    input logic rst,
    input logic rx,
    output logic tx
);


//uart
logic tx_start;
logic [7:0] rx_data;
logic rx_done;
logic tx_busy;
logic [7:0] tx_data;

//fifo
logic fifo_push;
logic fifo_pop;
logic [7:0] fifo_wdata;
logic [7:0] fifo_rdata;
logic fifo_full;
logic fifo_empty;


uart U_UART(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .rx(rx),  
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_busy(tx_busy),
    .tx(tx)
);

fifo_sv U_FIFO(
    .clk(clk),
    .rst(rst),
    .push_data(fifo_wdata),
    .push(fifo_push),
    .pop(fifo_pop),
    .pop_data(fifo_rdata),
    .full(fifo_full),
    .empty(fifo_empty)
);


assign fifo_push = rx_done && !fifo_full;
assign fifo_wdata = rx_data;

    //※TX 제어는 FSM 권장※
    //※ 아래는 개념용. 실제로는 fifo_pop과 tx_start를 1클럭 펄스로 만들어야 함.※



typedef enum logic [1:0] {
    IDLE,
    LOAD,
    START, 
    WAIT_BUSY
} state_t;


state_t state, next_state;



always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        tx_start <= 0;
        fifo_pop <= 0;
        tx_data <= 0;
    end else begin
        tx_start <= 0;
        fifo_pop <=0;
        case (state)
            IDLE: begin
                if(!fifo_empty && !tx_busy) begin  //FIFO가 비지 않았고, tx가 동작중이 아니라면 fifo pop에서 받아서 tx로 내보내기
                    fifo_pop <=1;
                    state <= LOAD;
                end
            end
            LOAD: begin
                tx_data <= fifo_rdata;
                state <= START;
            end
            START: begin
                tx_start <= 1;
                state <= WAIT_BUSY;
            end
            WAIT_BUSY: begin
                if(tx_busy) begin
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase
    end
end



endmodule
