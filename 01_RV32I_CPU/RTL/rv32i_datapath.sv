`timescale 1ns / 1ps
`include "define.vh"

module rv32i_datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    input  logic        rf_we,
    input  logic        branch,
    input logic         jal,
    input logic         jalr,
    input logic  [2:0]  rfsrc_sel,
    input logic         alusrc_sel,
    input logic  [31:0] drdata,
    input  logic [ 3:0] alu_control,
    output logic [31:0] instr_addr,
    output logic [31:0] daddr,
    output logic [31:0] dwdata
);

    logic [31:0] rs2, rs1, alu_result, alu_rs2_mux, imm_extend, rf_src_mux_out, wb_out;
    logic [31:0] pc_imm, pc_4;
    logic b_taken;


    assign daddr = alu_result;
    assign dwdata = rs2;

mux_2x1 U_REG_FILE_SRC_MUX(
    .in0(alu_result),
    .in1(drdata),
    .sel(rfsrc_sel),
    .out_mux(rf_src_mux_out)
);



program_counter U_PC(
    .clk(clk),
    .rst(rst),
    .b_taken(b_taken),
    .branch(branch),
    .jal(jal),
    .jalr(jalr),
    .rs1(rs1),
    .pc_in(instr_addr),
    .imm_extend(imm_extend),
    .pc_out(instr_addr),
    .pc_imm(pc_imm),
    .pc_4(pc_4)
);


alu U_ALU (
    .alu_control(alu_control),
    .rs1        (rs1),
    .rs2        (alu_rs2_mux),
    .alu_result (alu_result),
    .b_taken    (b_taken)
);


mux_2x1 U_ALU_RS2_MUX(
    .in0(rs2),
    .in1(imm_extend),
    .sel(alusrc_sel),
    .out_mux(alu_rs2_mux)
);


imm_extend U_IMM_EXTEND (
    .instr_code(instr_code),
    .imm_extend(imm_extend)
);


register_file U_REG_FILE (
    .clk(clk),
    .rf_we(rf_we),
    .waddr(instr_code[11:7]),
    .wdata(wb_out),
    .raddr1(instr_code[19:15]),
    .raddr2(instr_code[24:20]),
    .rdata1(rs1),
    .rdata2(rs2)
);


mux_wb U_WB( //write back
    .in0(alu_result),
    .in1(drdata),
    .in2(imm_extend),
    .in3(pc_imm),
    .in4(pc_4),
    .sel(rfsrc_sel),
    .wb_out(wb_out)
);




endmodule

module program_counter (
    input logic clk,
    input logic rst,
    input logic b_taken,
    input logic branch,
    input logic jal,
    input logic jalr,
    input logic [31:0] rs1,
    input logic [31:0] pc_in,
    input logic [31:0] imm_extend,
    output logic [31:0] pc_out,
    output logic [31:0] pc_auipc,
    output logic [31:0] pc_imm,
    output logic [31:0] pc_4
);

    logic [31:0] pc_reg;  // 현재 주소를 저장하는 플립플롭 레지스터
    logic [31:0] pc_next; // MUX가 결정한 다음 주소 신호 (와이어)
    logic [31:0] pc_jalr;

    assign pc_out = pc_reg;
    assign pc_imm = imm_extend + pc_jalr;
    assign pc_4 = pc_in + 4;
    assign pc_auipc = pc_in + imm_extend;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 0;
        end else begin
            pc_reg <= pc_next; // 조합 회로가 연산해둔 차기 주소를 저장
        end
    end


    mux_2x1 U_PC_JALR_MUX(
        .in0(pc_in),
        .in1(rs1),
        .sel(jalr),
        .out_mux(pc_jalr)
    );

    mux_2x1 U_PC_SRC_MUX(
        .in0(pc_4),
        .in1(pc_imm),
        .sel(jal | jalr | (branch & b_taken)),
        .out_mux(pc_next)
    );


endmodule


module imm_extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_extend
);


    always_comb begin
        imm_extend = 32'd0;
        case(instr_code[6:0])
        `S_TYPE : imm_extend = {{20{instr_code[31]}},instr_code[31:25],instr_code[11:7]};
        `IL_TYPE,`I_TYPE, `JL_TYPE : imm_extend = {{20{instr_code[31]}},instr_code[31:20]};
        `B_TYPE : imm_extend = {{20{instr_code[31]}}, instr_code[7], instr_code[30:25], instr_code[11:8], 1'b0};
        `J_TYPE : imm_extend = {{12{instr_code[31]}}, instr_code[19:12], instr_code[20], instr_code[30:21], 1'b0};
        `UL_TYPE, `UA_TYPE : imm_extend = {instr_code[31:12],12'h000};
        endcase
    end
endmodule




module alu (
    input  logic [ 3:0] alu_control,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    output logic [31:0] alu_result,
    output logic b_taken
);
    always_comb begin
        alu_result = 32'd0;
        //R-TYPE RD = RS1 + RS2
        //I-TYPE RD = RS1 + Imm
        case (alu_control)
            `ADD:  alu_result = rs1 + rs2;
            `SUB:  alu_result = rs1 - rs2;
            `AND:  alu_result = rs1 & rs2;
            `OR:   alu_result = rs1 | rs2;
            `XOR:  alu_result = rs1 ^ rs2;
            `SLTU: alu_result = (rs1 < rs2) ? 1 : 0;
            `SLT:  alu_result = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
            `SLL: alu_result = rs1 << rs2;
            `SRL: alu_result = rs1 >> rs2[4:0];
            `SRA: alu_result = $signed(rs1) >>> rs2[4:0];

        endcase
    end    
        always_comb begin
            b_taken = 0;
            case (alu_control[2:0])
               /* `BEQ: b_taken = (rs1 == rs2)?1:0;
                `BNE: b_taken = (rs1 != rs2)?1:0;
                `BLT: b_taken = ($signed(rs1) < $signed(rs2))?1:0;
                `BGE: b_taken = ($signed(rs1) >= $signed(rs2))?1:0;
                `BLTU: b_taken = (rs1 < rs2)?1:0;
                `BGEU: b_taken = (rs1 >= rs2)?1:0;
                */
                                `BEQ: begin
                    if (rs1 == rs2)
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end

                `BNE: begin
                    if (rs1 != rs2)
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end

                `BLT: begin
                    if ($signed(rs1) < $signed(rs2))
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end

                `BGE: begin
                    if ($signed(rs1) >= $signed(rs2))
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end

                `BLTU: begin
                    if (rs1 < rs2)
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end

                `BGEU: begin
                    if (rs1 >= rs2)
                        b_taken = 1'b1;
                    else
                        b_taken = 1'b0;
                end
                            endcase
                        end
    
    
endmodule


module register_file (
    input  logic        clk,
    input  logic        rf_we,   //register file write enable
    input  logic [ 4:0] waddr,
    input  logic [31:0] wdata,
    input  logic [ 4:0] raddr1,
    input  logic [ 4:0] raddr2,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2

);


    logic [31:0] register_file[1:63];
    int i = 0;
    initial begin
        for (i = 1; i < 32; i++) register_file[i] = i;
    end
    always @(posedge clk) begin
        if (rf_we) begin
            register_file[waddr] <= wdata;
        end
    end
    assign rdata1 = (raddr1 != 0) ? register_file [raddr1] :32'd0; // 조합으로 해야 1cycle 내에 처리됨. 순차로 하면 1cycle내에 처리가 안됨.
    assign rdata2 = (raddr2 != 0) ? register_file[raddr2] : 32'd0;



endmodule


module mux_2x1(
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic sel,
    output logic  [31:0] out_mux
);

assign out_mux = (sel) ? in1 : in0;


endmodule


module mux_wb(
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic [31:0] in3,
    input  logic [31:0] in4,
    input  logic [2:0] sel,
    output logic [31:0] wb_out
);



always_comb begin
    wb_out = 32'dx;
    case (sel)
        3'b000: wb_out = in0; //load alu
        3'b001: wb_out = in1; //load data memory
        3'b010: wb_out = in2; //load ADD Upper Imm
        3'b011: wb_out = in3; //load 
        3'b100: wb_out = in4;
    endcase
end




endmodule