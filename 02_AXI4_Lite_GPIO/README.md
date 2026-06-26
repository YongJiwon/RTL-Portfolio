# AXI4-Lite Timer Custom IP

## Overview

This project implements a custom AXI4-Lite Timer IP using Verilog.

A configurable timer module (`TimerCounter`) was integrated with an AXI4-Lite Slave interface, allowing software to control the timer through memory-mapped registers.

The project was verified at both the RTL level and the AXI bus transaction level using dedicated testbenches.

---

## Features

- Custom AXI4-Lite Slave IP
- Configurable Prescaler (PSC)
- Auto Reload Register (ARR)
- Counter Register (CNT)
- Interrupt Generation
- Memory-mapped Register Access
- RTL Verification
- AXI Bus Verification

---

## Project Structure

```text
05_AXI_Timer_Custom_IP
├── README.md
├── RTL
│   ├── TimerCounter.v
│   ├── axi_template_v1_0.v
│   └── axi_template_v1_0_S00_AXI.v
├── TB
│   ├── tb_TimerCounter.sv
│   └── tb_axi_timer.sv
└── Images
```

---

## Architecture

```text
               AXI4-Lite Master
                      │
                      ▼
          AXI4-Lite Slave Interface
        (axi_template_v1_0_S00_AXI)
                      │
        Memory-Mapped Registers
                      │
                      ▼
              TimerCounter
                      │
                Interrupt Output
```

---

## Register Map

| Address | Register | Description |
|---------|----------|-------------|
| 0x00 | Control Register | Timer Enable / Interrupt Enable |
| 0x04 | PSC | Prescaler |
| 0x08 | ARR | Auto Reload Value |
| 0x0C | CNT | Counter Value |

---

## Timer Features

The TimerCounter module supports:

- Programmable Prescaler
- Configurable Auto Reload
- Counter Initialization
- Counter Enable
- Interrupt Enable
- Overflow Interrupt Generation

---

## Verification

### RTL Verification

`tb_TimerCounter.sv`

Verified:

- Counter Increment
- Prescaler Operation
- Auto Reload
- Interrupt Generation
- Counter Initialization

### AXI Verification

`tb_axi_timer.sv`

Verified:

- AXI Write Transaction
- AXI Read Transaction
- Register Access
- Timer Configuration
- Interrupt Operation

---

## Skills

- Verilog HDL
- AXI4-Lite
- Custom IP Design
- Memory-Mapped Register Design
- RTL Verification
- Testbench Development
- Vivado IP Packaging

---

## What I Learned

Through this project, I learned how to integrate a user-designed hardware module with an AXI4-Lite interface and expose it as a memory-mapped peripheral.

I also gained experience verifying both the internal timer logic and AXI bus transactions using dedicated testbenches.
