# Digital Design and Embedded Software Portfolio

Verilog/SystemVerilog 기반 디지털 회로 설계, FPGA 하드웨어 연동, Embedded C 주변장치 제어 및 기능 검증 프로젝트를 정리한 저장소입니다.

## Embedded C와 FPGA 연동 경험

[AXI4-Lite GPIO 프로젝트](02_AXI4_Lite_GPIO/README.md)에서는 Basys3의 MicroBlaze와 GPIO 주변장치를 연결하고, Vitis Embedded C로 LED·FND·버튼을 제어했습니다.

- [GPIO 레지스터 정의](02_AXI4_Lite_GPIO/src/HAL/GPIO/GPIO.h): 구조체, `volatile`, 주변장치 기준 주소를 이용한 MMIO 접근
- [GPIO 제어 함수](02_AXI4_Lite_GPIO/src/HAL/GPIO/GPIO.c): 레지스터 읽기·쓰기와 비트 마스크 기반 핀 제어
- [스톱워치 애플리케이션](02_AXI4_Lite_GPIO/src/ap/StopWatch.c): 버튼 이벤트와 STOP·RUN·CLEAR 상태에 따른 동작
- [GPIO RTL과 IP 패키지](05_Custom_IP/README.md): AXI4-Lite GPIO 인터페이스 및 Vivado IP 패키징 자료

## 프로젝트 목록

| 프로젝트 | 주요 내용 | 자료 |
| --- | --- | --- |
| RV32I CPU | Control Unit·Datapath 구성과 명령어 처리 흐름의 RTL 시뮬레이션 | [01_RV32I_CPU](01_RV32I_CPU/README.md) |
| AXI4-Lite GPIO와 Embedded C | MMIO 주변장치 제어, HAL·애플리케이션 구성, 별도 Timer RTL·테스트벤치 | [02_AXI4_Lite_GPIO](02_AXI4_Lite_GPIO/README.md) |
| UART/FIFO 검증 환경 | SystemVerilog Transaction·Driver·Monitor·Scoreboard 기반 기능 검증 | [03_FIFO_UART](03_FIFO_UART/README.md) |
| I2C 통신 시스템 | I2C Master/Slave, FPGA 간 UART-I2C 연동, UVM 검증 자료 | [04_I2C](04_I2C/README.md) |
| Custom IP 패키징 | GPIO HDL, Vivado IP 메타데이터·드라이버 템플릿 및 관련 소스 | [05_Custom_IP](05_Custom_IP/README.md) |

## 기술과 사용 근거

| 분야 | 저장소의 사용 사례 |
| --- | --- |
| Embedded C | GPIO 레지스터 접근, 포인터·구조체·비트 연산, 버튼 이벤트 및 표시 제어 |
| RTL 설계 | RV32I CPU, UART/FIFO, I2C Master/Slave, GPIO·Timer IP |
| 하드웨어·소프트웨어 연동 | MicroBlaze와 AXI4-Lite 주변장치를 Vitis C 코드에서 제어 |
| 기능 검증 | RTL 파형 분석, SystemVerilog 검증 컴포넌트, UVM·Functional Coverage |
| 개발 환경 | Vivado, Vitis 및 프로젝트별 시뮬레이션 도구 |

각 프로젝트 README에서 소스 구성과 검증 범위를 설명합니다. I2C 실보드 통신에서 확인한 간헐적 비트 밀림과 추가 검토 항목은 [I2C 프로젝트의 Limitations](04_I2C/README.md#limitations)에 정리했습니다.

