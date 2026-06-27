`timescale 1ns / 1ps
`include "define.vh"

module data_mem (
    input logic clk,
    input logic dwe,
    input logic [2:0] mem_mode,
    input logic [31:0] daddr,
    input logic [31:0] dwdata,
    output logic [31:0] drdata
);
    logic [31:0] data_ram[0:63];
    assign data_ram[0] = 0;
    /*initial begin
        for (int i = 0; i < 256; i++) begin
            data_ram[i] = 32'd0;
        end
    end
*/
    // =========================================================================
    // 1. 저장(Store) 블록: 동기 순차회로 (always_ff)
    // =========================================================================
    always_ff @(posedge clk) begin
        if (dwe) begin
            case (mem_mode)
                `SW: begin
                    data_ram[daddr[31:2]] <= dwdata;
                end
                `SB: begin
                    case (daddr[1:0])
                        2'b00: data_ram[daddr[31:2]][7:0]   <= dwdata[7:0];
                        2'b01: data_ram[daddr[31:2]][15:8]  <= dwdata[7:0];
                        2'b10: data_ram[daddr[31:2]][23:16] <= dwdata[7:0];
                        2'b11: data_ram[daddr[31:2]][31:24] <= dwdata[7:0];
                    endcase
                end
                `SH: begin
                    case (daddr[1])
                        1'b0: data_ram[daddr[31:2]][15:0]  <= dwdata[15:0];
                        1'b1: data_ram[daddr[31:2]][31:16] <= dwdata[15:0];
                    endcase
                end
                default: data_ram[daddr[31:2]] <= data_ram[daddr[31:2]];
            endcase
        end
    end

    // =========================================================================
    // 2. 로드(Load) 블록: 조합회로 (always_comb)
    // =========================================================================
    logic [31:0] full_word;
    assign full_word = data_ram[daddr[31:2]];

    always_comb begin
        drdata = 32'd0; // latch 방지용 초기화
        
        case (mem_mode)
            // LW (funct3 = 3'b010)
            `SW: begin 
                drdata = full_word;
            end
            
            // LB (funct3 = 3'b000) -> 부호 확장
            `SB: begin 
                case (daddr[1:0])
                    2'b00: drdata = {{24{full_word[7]}},  full_word[7:0]};
                    2'b01: drdata = {{24{full_word[15]}}, full_word[15:8]};
                    2'b10: drdata = {{24{full_word[23]}}, full_word[23:16]};
                    2'b11: drdata = {{24{full_word[31]}}, full_word[31:24]};
                endcase
            end
            
            // LBU (funct3 = 3'b100) -> [수정] 정의된 매크로 연결로 불일치 해결
            `LBU: begin 
                case (daddr[1:0])
                    2'b00: drdata = {24'd0, full_word[7:0]};
                    2'b01: drdata = {24'd0, full_word[15:8]};
                    2'b10: drdata = {24'd0, full_word[23:16]};
                    2'b11: drdata = {24'd0, full_word[31:24]};
                endcase
            end
            
            // LH (funct3 = 3'b001) -> 부호 확장
            `SH: begin
                case (daddr[1])
                    1'b0: drdata = {{16{full_word[15]}}, full_word[15:0]};
                    1'b1: drdata = {{16{full_word[31]}}, full_word[31:16]};
                endcase
            end
            
            // LHU (funct3 = 3'b101) -> [수정] 정의된 매크로 연결로 불일치 해결
            `LHU: begin 
                case (daddr[1])
                    1'b0: drdata = {16'd0, full_word[15:0]};
                    1'b1: drdata = {16'd0, full_word[31:16]};
                endcase
            end
            
            default: drdata = full_word;
        endcase
    end

endmodule