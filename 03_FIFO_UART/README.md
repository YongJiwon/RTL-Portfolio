# UART Loopback with FIFO Buffer

## Overview

This project implements a UART loopback system using Verilog.

Unlike a basic UART loopback, two FIFO buffers are inserted between the UART receiver and transmitter to decouple the receive and transmit paths, improving data handling during continuous communication.

The design was verified on FPGA hardware by transmitting serial data from a PC and receiving the same data back through the UART interface.

---

## Features

- UART Receiver
- UART Transmitter
- Configurable Baud Rate Generator
- RX FIFO
- TX FIFO
- UART Loopback
- Continuous Serial Communication
- FPGA Hardware Verification

---

## Project Structure

```text
03_UART_FIFO
├── README.md
├── RTL
│   ├── uart.v
│   ├── fifo.v
│   ├── uart_loopback.v
│   └── ...
├── Images
└── Docs
```

---

## Architecture

```text
           PC Terminal
                │
             UART RX
                │
          +-------------+
          | UART RX     |
          +-------------+
                │
            RX FIFO
                │
            TX FIFO
                │
          +-------------+
          | UART TX     |
          +-------------+
                │
             UART TX
                │
           PC Terminal
```

---

## Main Modules

### uart.v

Implements:

- UART Receiver
- UART Transmitter
- Baud Tick Generator

### fifo.v

Implements:

- Parameterized FIFO
- Push / Pop Control
- Full Detection
- Empty Detection
- Circular Buffer

### uart_loopback.v

Integrates:

- UART
- RX FIFO
- TX FIFO

and performs UART loopback communication.

---

## Verification

The design was verified by transmitting serial data from a PC terminal.

Verification items included:

- UART RX Operation
- FIFO Push
- FIFO Pop
- UART TX Operation
- Continuous Character Transmission
- FIFO Full / Empty Behavior

---

## Skills

- Verilog HDL
- UART Protocol
- FIFO Design
- Circular Buffer
- FPGA
- RTL Design
- Hardware Verification

---

## What I Learned

Through this project, I learned how FIFO buffers can decouple UART reception and transmission.

By separating the receive and transmit paths with independent FIFOs, continuous serial communication became more reliable and data flow management became simpler.

This project also strengthened my understanding of UART timing, FIFO pointer control, and hardware-level debugging.

---

## Future Improvements

Possible future improvements include:

- Configurable FIFO depth
- Overflow and underflow protection
- Interrupt-driven UART communication
- AXI4-Lite interface integration
