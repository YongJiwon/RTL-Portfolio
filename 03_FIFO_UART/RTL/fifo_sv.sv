`timescale 1ns / 1ps

module fifo_sv (

    input logic clk,
    input logic rst,
    input logic [7:0] push_data,
    input logic push,
    input logic pop,
    output logic [7:0] pop_data,
    output logic full,
    output logic empty
);

    logic [3:0] w_wptr_waddr, w_rptr_raddr;

    control_unit U_CNTL_UNIT (
        .*, // 포트 이름과 연결해준 이름이 같은 경우 *로 생략 가능
        .wptr (w_wptr_waddr),
        .rptr (w_rptr_raddr)
    );

    reg_file U_REG_FILE (
        .*, // systemverilog가 같은 이름은 자동으로 연결해줌 (clk, rst)
        .wdata(push_data),
        .waddr(w_wptr_waddr),
        .raddr(w_rptr_raddr),
        .we(((~full) & push)),
        .rdata(pop_data)
    );

endmodule

module control_unit (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic [3:0] wptr,
    output logic [3:0] rptr,
    output logic full,
    output logic empty
);

    logic [3:0] wptr_reg, wptr_next;
    logic [3:0] rptr_reg, rptr_next;
    logic empty_reg, empty_next, full_reg, full_next;

    assign wptr  = wptr_reg;
    assign rptr  = rptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            wptr_reg  <= 0;
            rptr_reg  <= 0;
            empty_reg <= 1;
            full_reg  <= 0;
        end else begin
            wptr_reg  <= wptr_next;
            rptr_reg  <= rptr_next;
            empty_reg <= empty_next;
            full_reg  <= full_next;
        end
    end

    always_comb begin  // 조합논리 연산을 의미
        wptr_next  = wptr_reg;
        rptr_next  = rptr_reg;
        empty_next = empty_reg;
        full_next  = full_reg;
        case ({
            push, pop
        })  // 2bit를 결합 연산자로 하면 상태가 됨
            2'b10: begin  // push only
                if (!full_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 1'b0;
                    if (wptr_next == rptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            2'b01: begin  // pop only
                if (!empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                    if (rptr_next == wptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end
            2'b11: begin  // push, pop same time
                if (full_reg) begin  // full일 경우 pop만 진행
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else if (empty_reg) begin  // empty일 경우 push만 진행
                    wptr_next  = wptr_reg + 1;
                    empty_next = 1'b0;
                end else begin // full, empty가 아닐 경우 pop, push 다 진행
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
            end
        endcase
    end
endmodule


module reg_file (
    input  logic       clk,
    input  logic [7:0] wdata,
    input  logic [3:0] waddr,
    input  logic [3:0] raddr,
    input  logic       we,
    output logic [7:0] rdata
);

    logic [7:0] reg_file [0:15]; // 8bit짜리 저장공간이 16개 존재 (4bit니까 16개)

    // datapath의 register 출력은 read address가 변하면 조합출력으로 나가도록 설계 
    assign rdata = reg_file[raddr]; // raddr에 주소를 넣으면 주소에 저장된 값이 rdata로 read

    always_ff @(posedge clk) begin  // sram엔 reset이 없음
        if (we) begin
            reg_file[waddr] <= wdata; // wdata가 waddr 주소의 memory에 저장
        end
    end

endmodule


