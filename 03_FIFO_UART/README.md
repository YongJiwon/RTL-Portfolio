# UART + FIFO Verification using UVM

## Overview

This project implements and verifies a UART communication system with a FIFO buffer using Verilog/SystemVerilog and UVM.

The design integrates a UART Receiver, a single FIFO, and a UART Transmitter into one RTL design. Functional verification was performed through a UVM-based testbench, focusing on correct data transfer and FIFO behavior rather than FPGA hardware implementation.

---

## Features

- UART Receiver
- UART Transmitter
- Baud Rate Generator
- Single FIFO Buffer
- UART + FIFO Integration
- UVM-based Verification
- RTL Simulation
- Waveform Analysis

---

## Directory Structure

```text
03_UART_FIFO
├── README.md
├── RTL
│   ├── uart_rx.v
│   ├── uart_tx.v
│   ├── fifo_sv.sv
│   └── uart_fifo_top.sv
├── UVM
│   ├── tb_uart_fifo_top.sv
│   └── ...
├── Images
└── Docs
```

---

## System Architecture

```text
             UVM Testbench
                    │
                    ▼
              +-----------+
              | UART RX   |
              +-----------+
                    │
                    ▼
              +-----------+
              |   FIFO    |
              +-----------+
                    │
                    ▼
              +-----------+
              | UART TX   |
              +-----------+
                    │
                    ▼
          RTL Simulation Waveform
```

---

## Main Modules

### uart_rx.v

Implements the UART Receiver.

- Start bit detection
- Serial-to-parallel conversion
- Baud tick sampling
- Receive FSM

---

### fifo_sv.sv

Implements a parameterized single FIFO buffer.

Features include:

- Circular Buffer
- Write Pointer
- Read Pointer
- Full Detection
- Empty Detection
- FIFO Memory Control

---

### uart_tx.v

Implements the UART Transmitter.

- Parallel-to-serial conversion
- Baud tick transmission
- Stop bit generation
- Transmit FSM

---

### uart_fifo_top.sv

Top-level module integrating

- UART Receiver
- FIFO
- UART Transmitter

into a complete UART communication path.

---

## Verification

Functional verification was performed using a SystemVerilog/UVM environment.

Verification items include:

- UART RX operation
- FIFO write operation
- FIFO read operation
- UART TX operation
- FIFO Full / Empty behavior
- End-to-end data transfer

Waveform analysis was used to verify correct RTL behavior.

---

## Verification Environment

The verification environment consists of:

- UVM Test
- Sequence
- Driver
- Monitor
- Scoreboard
- DUT

Stimulus is generated through UVM sequences, applied by the driver, observed by the monitor, and checked by the scoreboard.

---

## Skills

- Verilog HDL
- SystemVerilog
- UVM
- UART Protocol
- FIFO Design
- RTL Design
- RTL Verification
- Waveform Debugging

---

## What I Learned

Through this project, I gained practical experience in designing and verifying UART communication hardware.

I learned how FIFO buffering improves data flow between UART modules and how UVM can be used to build a reusable verification environment.

The project also strengthened my understanding of UART timing, FIFO control logic, RTL verification methodology, and waveform-based debugging.

---

## Future Improvements

Possible future improvements include:

- Configurable FIFO depth
- Assertion-Based Verification (SVA)
- Functional Coverage
- Randomized UVM Sequences
- Overflow / Underflow verification
- Error Injection Test Cases
