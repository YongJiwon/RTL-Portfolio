# I2C Communication System

## Overview

This project implements an FPGA-based I2C communication system using SystemVerilog.

The project consists of

- I2C Master
- I2C Slave
- UART Interface
- UVM Verification Environment

The communication between Master and Slave was verified through RTL simulation and UVM testbench.

---

## Features

- I2C Master RTL
- I2C Slave RTL
- UART Interface
- FPGA Top Module
- UVM Verification
- Functional Coverage
- Constraint Files

---

## Directory Structure

```text
04_I2C
├── FPGA
│   ├── I2C_MASTER
│   │   ├── RTL
│   │   └── xdc
│   │
│   └── I2C_SLAVE
│       ├── RTL
│       └── xdc
│
├── UVM
│   ├── rtl
│   └── tb
│
└── Images
```

## Limitations

The current implementation directly bridges the UART and I2C interfaces without an intermediate buffer.

During hardware testing, short messages were transmitted successfully. However, long or continuous data streams occasionally experienced data loss due to the processing speed difference between the UART and I2C interfaces.

This limitation was observed during FPGA-to-FPGA communication between the I2C Master and Slave boards.

## Future Improvements

To improve communication reliability, a FIFO buffer can be inserted between the UART and I2C modules.

Expected improvements include:

- Preventing data loss during continuous transmission
- Buffering UART input while the I2C bus is busy
- Improving throughput between UART and I2C interfaces
- Supporting longer data packets with higher reliability
