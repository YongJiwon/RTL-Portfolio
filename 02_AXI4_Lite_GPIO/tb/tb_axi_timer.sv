`timescale 1ns / 1ps

module tb_axi_timer;
	parameter integer C_S00_AXI_DATA_WIDTH	= 32;
	parameter integer C_S00_AXI_ADDR_WIDTH	= 4;
    logic clk;
    logic reset_n;
	logic intr;
	logic  s00_axi_aclk;
	logic  s00_axi_aresetn;
	logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
	logic [2 : 0] s00_axi_awprot;
	logic  s00_axi_awvalid;
	logic  s00_axi_awready;
	logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
	logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
	logic  s00_axi_wvalid;
	logic  s00_axi_wready;
	logic [1 : 0] s00_axi_bresp;
	logic  s00_axi_bvalid;
	logic  s00_axi_bready;
	logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
	logic [2 : 0] s00_axi_arprot;
	logic  s00_axi_arvalid;
	logic  s00_axi_arready;
	logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
	logic [1 : 0] s00_axi_rresp;
	logic  s00_axi_rvalid;
	logic  s00_axi_rready;


    assign s00_axi_aclk = clk;
    assign s00_axi_aresetn = reset_n;
    axi_template_v1_0 dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    localparam TMR_CR_ADDR = 32'h00000000;
    localparam TMR_PSC_ADDR = 32'h00000004;
    localparam TMR_ARR_ADDR = 32'h00000008;
    localparam TMR_CNT_ADDR = 32'h0000000C;
    
    logic [31:0] CR, PSC, ARR, CNT;

    task automatic AXI_WriteData(logic [31:0] addr, logic [31:0] data);
            s00_axi_awaddr <= addr;
            s00_axi_awvalid <= 1;
            s00_axi_wdata <= data;
            s00_axi_wvalid <= 1;
            s00_axi_wstrb <= 4'b1111;
            s00_axi_bready <= 1;
            @(posedge clk);
            wait(s00_axi_awready && s00_axi_wready);
            @(posedge clk);
            s00_axi_awvalid <= 0;
            s00_axi_wvalid <= 0;
            @(posedge clk);
            wait(s00_axi_bvalid);
            @(posedge clk);
            s00_axi_bready <= 0;
            @(posedge clk);
    endtask

    task automatic AXI_ReadData(logic [31:0] addr);
        s00_axi_araddr <= addr;
        s00_axi_arvalid <= 1'b1;
        s00_axi_rready <= 1'b1;
        @(posedge clk);
        wait(s00_axi_arready) @(posedge clk);
        s00_axi_arvalid <= 1'b0;
        s00_axi_rready <= 1'b0;
        @(posedge clk);
    endtask
    
    initial begin
        reset_n = 0;
        s00_axi_awaddr = 0;
        s00_axi_awvalid = 0;
        s00_axi_wdata = 0;
        s00_axi_wvalid = 0;
        s00_axi_wstrb = 0;
        s00_axi_bready = 0;
        s00_axi_araddr = 0;
        s00_axi_arvalid = 0;
        s00_axi_rready = 0;
        s00_axi_awprot = 3'b000;
        s00_axi_arprot = 3'b000;
        
        CR = 0;
        PSC = 0;
        ARR = 0;
        CNT = 0;
        repeat(5) @(posedge clk);    
        reset_n = 1;
        @(posedge clk);

        // 타이머 설정 및 동작 시작
        PSC = 100-1;
        AXI_WriteData(TMR_PSC_ADDR, PSC); // ★ 기존 코드 주소가 TMR_CR_ADDR로 잘못 할당되어 있던 점도 수정
        ARR = 1000-1;
        AXI_WriteData(TMR_ARR_ADDR, ARR);
        CR |= (1<<0)|(1<<1);
        AXI_WriteData(TMR_CR_ADDR, CR);
        
        wait(intr); // 이제 포트가 연결되어 정상적으로 탈출합니다.
        #1000;
        $stop;
        $finish;

    end
		

endmodule
