`timescale 1ns / 1ps

module top_rv32i_soc (
    input logic clk,
    input logic rst
);

    logic [31:0] instr_code, instr_addr, daddr, dwdata, drdata;
    logic [3:0] alu_control;
    logic [2:0] mem_mode;
    logic dwe;
    
    instruction_mem U_INSTR_ROM (.*);
    data_mem U_DATA_RAM (.*);
    rv32i_cpu U_CPU (.*);
endmodule