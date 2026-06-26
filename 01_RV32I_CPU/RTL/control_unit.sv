`timescale 1ns / 1ps

`include "define.vh"

module control_unit (
    input logic clk,  //Add port
    input logic rst,  //Add port
    input logic [31:0] instr_code,
    output logic rf_we,
    output logic branch,
    output logic jal,
    output logic jalr,
    output logic alusrc_sel,
    output logic [3:0] alu_control,
    output logic [2:0] mem_mode,
    output logic [2:0] rfsrc_sel,
    output logic dwe,
    output logic pc_en  //Add port

);

    typedef enum logic [2:0] {
        IF  = 3'd0,
        ID  = 3'd1,
        EXE = 3'd2,
        MEM = 3'd3,
        WB  = 3'd4
    } state_e;  // <--- 끝에 세미콜론(;)을 꼭 붙여주셔야 합니다.

    logic [2:0] funct3;
    logic [6:0] funct7;  //7bit
    logic [6:0] opcode;  //7bit

    state_e state, next_state;


    assign funct7 = instr_code[31:25];  //7bit
    assign funct3 = instr_code[14:12];  //3bit
    assign opcode = instr_code[6:0];  //7bit

    typedef enum logic [6:0] {
        R_TYPE  = `R_TYPE,
        S_TYPE  = `S_TYPE,
        IL_TYPE = `IL_TYPE,
        I_TYPE  = `I_TYPE,
        B_TYPE  = `B_TYPE,
        UL_TYPE = `UL_TYPE,
        UA_TYPE = `UA_TYPE,
        J_TYPE  = `J_TYPE,
        JL_TYPE = `JL_TYPE
    } opcode_dbg_e;
    opcode_dbg_e opcode_dbg;
    assign opcode_dbg = opcode_dbg_e'(opcode);





    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IF;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        // 1. Latch 방지 및 코드 간소화를 위한 기본값(Default) 선언
        next_state  = state;
        rf_we       = 0;
        branch      = 0;
        alusrc_sel  = 0;
        alu_control = 0;
        mem_mode    = 0;
        dwe         = 0;
        rfsrc_sel   = 0;
        jal         = 0;
        jalr        = 0;
        pc_en       = 0;

        case (state)  // [수정] begin 제거
            IF: begin
                next_state = ID;  // [수정] 다음 상태 지정
                pc_en      = 1;  // [수정] IF 단계에서는 PC 고정 (이전 명령 끝단에서 이미 변경됨)
            end

            ID: begin
                next_state = EXE;  // [수정] 다음 상태 지정
                pc_en      = 0;
            end

            EXE: begin
                case (opcode)  // [수정] begin 제거
                    `R_TYPE: begin
                        next_state = IF;  // [수정] 연산 후 즉시 복귀
                        pc_en       = 0;  // [수정] 다음 사이클에 새 PC 페치를 위해 활성화
                        rf_we = 1'b1;
                        alusrc_sel = 0;
                        alu_control = {funct7[5], funct3};
                    end

                    `I_TYPE: begin
                        next_state = IF;  // [수정] 연산 후 즉시 복귀
                        pc_en       = 0;  // [수정] 다음 사이클에 새 PC 페치를 위해 활성화
                        rf_we = 1'b1;
                        alusrc_sel = 1'b1;
                        rfsrc_sel = 3'b000;  // [수정] 3비트 폭 매칭
                        if (funct3 == 3'b101) begin
                            alu_control = {funct7[5], funct3};
                        end else begin
                            alu_control = {1'b0, funct3};
                        end
                    end

                    `B_TYPE: begin
                        next_state  = IF; // [수정] 분기 판단 후 즉시 복귀
                        pc_en = 0;  // [수정] 결정된 PC 적용
                        branch = 1;
                        alusrc_sel = 0;
                        alu_control = {1'b0, funct3};
                    end

                    `J_TYPE, `JL_TYPE: begin
                        next_state  = IF;
                        pc_en = 0;
                        rf_we = 1;
                        if (opcode == `J_TYPE) begin
                            jalr = 0;
                        end else begin
                            jalr = 1;
                        end
                        jal       = 1;
                        rfsrc_sel = 3'b100;
                    end

                    `UL_TYPE, `UA_TYPE: begin
                        next_state = IF; 
                        pc_en      = 0;
                        rf_we      = 1;
                        if (opcode == `UL_TYPE) begin
                            rfsrc_sel = 3'b010;
                        end else begin
                            rfsrc_sel = 3'b011;
                        end
                    end

                    `S_TYPE, `IL_TYPE: begin
                        next_state  = MEM; 
                        pc_en = 0;
                        alusrc_sel = 1;
                        alu_control = `ADD;
                    end

                    default: begin
                        next_state = IF;
                        pc_en      = 0;
                    end
                endcase
            end

            MEM: begin
                mem_mode = funct3;
                if (opcode == `S_TYPE) begin
                    next_state = IF;
                    pc_en = 0;  // Store 명령 완결 시점 PC 갱신
                    dwe = 1;  // [수정] 데이터 메모리 쓰기 활성화
                end else begin
                    next_state = WB; // Load 명령은 읽어온 값을 레지스터에 써야 하므로 WB로 이동
                    pc_en = 0;
                    dwe = 0;
                end
            end

            WB: begin
                next_state = IF;
                pc_en      = 0;
                if (opcode == `IL_TYPE) begin
                    rf_we = 1;
                    rfsrc_sel = 3'b001;
                end
                else begin
                    rf_we     = 1;
                    rfsrc_sel = 3'b100;
                end
            end

            default: begin
                next_state = IF;
                pc_en      = 0;
            end
        endcase
    end

    /*
always_comb begin
        next_state = state;
        rf_we       = 0;
        branch      = 0;
        alusrc_sel  = 0;
        alu_control = 0;
        mem_mode    = 0;
        dwe         = 0;
        rfsrc_sel   = 0;
        jal         = 0;
        jalr        = 0;
        pc_en       = 0;

    case(state) begin
        IF: pc_en = 1;
        ID: pc_en = 0;
        EXE: begin
            case(opcode) begin
                `R_TYPE: begin
                    rf_we = 1'b1;
                    alusrc_sel = 0;
                    branch     = 0;
                    alu_control = {funct7[5], funct3};
                end
                `I_TYPE: begin
                    rf_we      = 1'b1;
                    alusrc_sel = 1'b1;
                    rfsrc_sel  = 1'b0;
                    if (funct3 == 3'b101) begin
                        alu_control = {funct7[5], funct3};
                    end else begin
                        alu_control = {1'b0, funct3};
                    end             
                end
                `B_TYPE: begin
                    branch     = 1;
                    alusrc_sel = 0;
                    alu_control = {1'b0,funct3};
                end
                `J_TYPE, `JL_TYPE: begin
                    rf_we = 1;
                
                    if (opcode == `J_TYPE) begin
                        jalr = 0;                    
                    end else begin                   
                        jalr = 1;
                    end
                        jal = 1;
                    rfsrc_sel = 3'b100;
                end
                `UL_TYPE, `UA_TYPE: begin
                    rf_we = 1;
                    if (opcode == `UL_TYPE) begin
                        rfsrc_sel = 3'b010;
                    end else begin
                        rfsrc_sel = 3'b011;
                    end
                end
                `S_TYPE ,`IL_TYPE: begin
                    alusrc_sel = 1;
                    alu_control = `ADD;
                end
            end
            endcase
        end 
        
        MEM: begin
            mem_mode = funct3;
            if (opcode == `S_TYPE) next_state = IF;
            else next_state = WB;
        end

        WB: begin
            next_state = IF;
        end
    end
    endcase
 
end

*/






    //single Cycle CL
    /*    always_comb begin
        rf_we       = 1'b0;
        branch     = 0;
        alusrc_sel  = 0;
        alu_control = 4'd0;
        mem_mode    = 3'b0;
        dwe         = 0;
        rfsrc_sel   = 0;
        jal = 0;
        jalr = 0;
        case (opcode)
            `R_TYPE: begin
                rf_we = 1'b1;
                alusrc_sel = 0;
                jal = 0;
                jalr = 0;
                branch     = 0;
                alu_control = {funct7[5], funct3};
                mem_mode = 3'b0;
                rfsrc_sel = 3'b0;
                dwe = 0;
            end
            `S_TYPE: begin
                rf_we = 1'b0;
                alusrc_sel = 1;
                jal = 0;
                jalr = 0;
                branch     = 0;
                alu_control = `ADD;
                mem_mode = funct3;
                dwe = 1;
                rfsrc_sel = 0;
            end
            `IL_TYPE: begin
                rf_we = 1'b1;  // 
                alusrc_sel = 1;
                branch     = 0;
                jal = 0;
                jalr = 0;
                alu_control = `ADD;
                mem_mode = funct3; 
                dwe = 0;
                rfsrc_sel = 1; 
            end
            `I_TYPE: begin
                rf_we      = 1'b1;
                branch     = 0;
                jal = 0;
                jalr = 0;
                alusrc_sel = 1'b1;
                mem_mode   = 3'b0;
                dwe        = 1'b0;
                rfsrc_sel  = 1'b0;
                if (funct3 == 3'b101) begin
                    alu_control = {funct7[5], funct3};
                end else begin
                    alu_control = {1'b0, funct3};
                end             
            end
            `B_TYPE: begin
                rf_we = 1'b0;
                branch     = 1'b1;
                jal = 0;
                jalr = 0;
                alusrc_sel = 1'b0;
                alu_control = {1'b0,funct3};
                mem_mode = 3'b0;
                rfsrc_sel = 0;
                dwe = 0;
            end
            `UL_TYPE, `UA_TYPE: begin
                rf_we = 1'b1;
                branch     = 0;
                jal = 0;
                jalr = 0;
                alusrc_sel = 1'b1;
                alu_control =4'b0;
                mem_mode = 3'b0;
                if (opcode == `UL_TYPE) begin
                    rfsrc_sel = 3'b010;    
                end else begin
                    rfsrc_sel = 3'b011;
                end
                dwe = 0;
            end
            `J_TYPE, `JL_TYPE: begin
                rf_we = 1'b1;
                branch     = 0;
                if (opcode == `J_TYPE) begin
                    jalr = 0;                    
                end else begin                   
                    jalr = 1;
                end
                jal = 1'b1;
                alusrc_sel = 1'b0;
                alu_control = 4'b0;
                mem_mode = 3'b0;
                dwe = 0;
                rfsrc_sel = 3'b100;
            end
        endcase
    end
    */
endmodule

