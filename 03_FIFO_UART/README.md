# UART + FIFO RTL Design

## Overview

This project implements a UART communication system with dedicated RX FIFO and TX FIFO modules using Verilog HDL.

The objective of this project is to design and integrate UART Receiver, UART Transmitter, Baud Rate Generator, and FIFO modules to build a reliable serial communication system on FPGA.

The design was verified through RTL simulation and FPGA hardware testing using a PC UART terminal (ComportMaster).

---

## Features

* UART Receiver
* UART Transmitter
* Baud Rate Generator
* RX FIFO
* TX FIFO
* FIFO-based Data Buffering
* Continuous Serial Communication
* FPGA Hardware Verification

---

## Project Structure

```text
03_UART_FIFO
├── README.md
├── RTL
│   ├── uart_rx.v
│   ├── uart_tx.v
│   ├── fifo_sv.sv
│   ├── uart_fifo_top.sv
│   └── ...
├── TB
│   ├── tb_fifo_sv.sv
│   └── tb_uart_fifo_top.sv
├── Images
└── Docs
```

---

## System Architecture

```text
          PC Terminal
               │
           UART RX
               │
        +--------------+
        | UART Receiver|
        +--------------+
               │
            RX FIFO
               │
            TX FIFO
               │
        +--------------+
        | UART Transmitter |
        +--------------+
               │
           UART TX
               │
          PC Terminal
```

---

## Main Modules

### uart_rx.v

* UART Receiver FSM
* Serial-to-Parallel Conversion
* Start/Stop Bit Detection

### uart_tx.v

* UART Transmitter FSM
* Parallel-to-Serial Conversion
* Baud Tick Transmission

### fifo_sv.sv

* Circular Buffer
* Write Pointer
* Read Pointer
* FIFO Full Detection
* FIFO Empty Detection

### uart_fifo_top.sv

* UART RX Integration
* UART TX Integration
* RX FIFO
* TX FIFO
* FIFO-based Data Flow

---

## Verification

The design was verified through RTL simulation and FPGA hardware testing.

Verification items include:

* UART RX Operation
* UART TX Operation
* FIFO Write
* FIFO Read
* FIFO Full / Empty Status
* Continuous Serial Data Transfer

Hardware verification was performed using ComportMaster on Basys3 FPGA.

---

## Skills

* Verilog HDL
* UART Protocol
* FIFO Design
* Circular Buffer
* Finite State Machine (FSM)
* FPGA RTL Design
* Hardware Verification

---

## What I Learned

Through this project, I gained practical experience in designing UART communication modules and integrating FIFO buffers into the data path.

Implementing independent RX and TX FIFOs improved my understanding of hardware buffering, UART timing, FSM design, and data flow management.

This project strengthened my RTL design skills and served as a foundation for later communication projects involving UART and I2C.

---

## Future Improvements

* Parameterized FIFO Depth
* Configurable Baud Rate
* Overflow / Underflow Protection
* AXI4-Lite Interface Integration
* Interrupt-based UART Communication
