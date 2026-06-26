`timescale 1ns / 1ps

module top_sr04_controller(
    input  wire       clk,        // 100MHz 시스템 클럭
    input  wire       rst,        // 리셋 버튼
    input  wire       btn_R,      // 측정을 시작할 버튼
    input  wire       echo,       // 초음파 센서 Echo 신호
    output wire       trig,       // 초음파 센서 Trig 신호
    output wire [3:0] fnd_com,    // FND 공통 단자 (Digit 선택)
    output wire [7:0] fnd_data     // FND 세그먼트 데이터
);

    // 내부 와이어 선언
    wire [8:0] w_dist;
    wire       w_tick_1us;
    wire       w_btn_R;
    
    // 거리 분리용 와이어 (BCD 변환)
    wire [3:0] dist_100, dist_10, dist_1;

    // 1. 버튼 디바운스
    button_debounce U_BTN_DB(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_R),
        .o_btn(w_btn_R)
    );

    // 2. 1us 틱 발생기
    tick_1us U_TICK_1us(
        .clk(clk),
        .rst(rst),
        .tick_1us(w_tick_1us)
    );

    // 3. SR04 초음파 센서 컨트롤러
    sr04 U_SR04(
        .clk(clk),
        .rst(rst),
        .u_tick(w_tick_1us),      // 1us 틱 연결
        .sr04_start(w_btn_R),
        .echo(echo),
        .trig(trig),
        .dist(w_dist)             // 계산된 거리(cm) 출력
    );

    // 4. 거리 데이터 3자리 분리 (간단한 BCD 변환)
    assign dist_100 = (w_dist / 100) % 10;
    assign dist_10  = (w_dist / 10) % 10;
    assign dist_1   = (w_dist % 10);

    // 5. FND 컨트롤러 연결 (기존 모듈 활용)
    // 시계용 포트인 hour와 min에 각각 100단위와 10/1단위를 할당
FND_Controller U_FND_DIST (
    .clk(clk),
    .rst(rst),
    .dist(w_dist),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);

endmodule