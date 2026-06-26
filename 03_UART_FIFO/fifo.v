`timescale 1ns / 1ps

                
module fifo#(
    parameter DEPTH = 4,
    BIT_WIDTH = ($clog2(DEPTH)-1)
)(
    input clk,
    input rst,
    input [7:0] push_data,
    input push,
    input pop,
    output [7:0] pop_data,
    output full,
    output empty
);


wire  [BIT_WIDTH:0] w_wptr, w_rptr;


// register_file 인스턴스 수정
register_file #( 
    .DEPTH(DEPTH)
) U_FILE (                
    .clk(clk),
    .wdata(push_data),
    .waddr(w_wptr), 
    .raddr(w_rptr), 
    .we(((~full)&push)),
    .rdata(pop_data)
);

// control_unit 인스턴스 수정
control_unit #( 
    .DEPTH(DEPTH)
) U_CU (
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .wptr(w_wptr),
    .rptr(w_rptr),
    .full(full),
    .empty(empty)
);



endmodule




module register_file // == RAM
#(  parameter   DEPTH = 4
)(                
    input clk,
    input [7:0] wdata,
    input [1:0] waddr,
    input [1:0] raddr,
    input we,
    output [7:0] rdata
);
    
    reg [7:0] register_file [0:3];

    always @(posedge clk) begin
        if (we) begin
            register_file[waddr]  <= wdata;
        end     
    end

    assign rdata = register_file[raddr];

endmodule



module control_unit 
#(  parameter   DEPTH = 4,
                BIT_WIDTH = ($clog2(DEPTH)-1) //2^n-1
)(
    input clk,
    input rst,
    input push,
    input pop,
    output [BIT_WIDTH:0] wptr,
    output [BIT_WIDTH:0] rptr,
    output full,
    output empty
);
    


    //wptr and rptr move with empty & full condition
    reg [BIT_WIDTH:0] wptr_reg, wptr_next;
    reg [BIT_WIDTH:0] rptr_reg, rptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;




always @(posedge clk or posedge rst) begin
    if (rst) begin
        wptr_reg <=0;
        rptr_reg <=0;
        full_reg <=1'b0;
        empty_reg <=1'b1; //init
    end else begin
        wptr_reg <= wptr_next;
        rptr_reg <= rptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

assign wptr = wptr_reg; 
assign rptr = rptr_reg;
assign full = full_reg;
assign empty = empty_reg;


always @(*) begin //This is a next Condition FSM
    wptr_next = wptr_reg;
    rptr_next = rptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;

    case({push,pop}) 
        2'b00:begin
            if (empty_reg) begin
                wptr_next = 0;
                rptr_next = 0;
                if (wptr_next == rptr_next) begin
                    empty_next = 1'b1;
                    full_next = 1'b0;
                end
            end
        end
        2'b01:begin //pop only & Not EMPTY
            if (!empty_reg) begin
                rptr_next = rptr_reg + 1'b1; //Stable transition for CL
                full_next = 1'b0; //This is not empty and Full condition
                if (wptr_reg == rptr_next) begin // ☆State Control By "_reg" ☆
                    //full_next = 1'b1;
                    empty_next = 1'b1; //State Update By "_next"
                end 
            end
        end
        2'b10:begin //push only & Not FULL
            if (!full_reg) begin
                wptr_next = wptr_reg + 1'b1; //Stable transition for CL
                empty_next = 1'b0;
                if (wptr_next == rptr_reg) begin  //☆ State Update By "_next" ☆
                    full_next = 1'b1; //State Update By "_next"
                    //empty_next = 1'b0;
                end
            end
        end
        2'b11:begin //push and pop coincidence
            if (full_reg) begin
                rptr_next = rptr_reg + 1'b1;
                full_next = 1'b0;
            end else if (empty) begin
                wptr_next = wptr_reg + 1'b1;
                empty_next = 1'b0;
            end else begin
                wptr_next = wptr_reg + 1'b1;
                rptr_next = rptr_reg + 1'b1;
            end
        end

    endcase
    
end






endmodule