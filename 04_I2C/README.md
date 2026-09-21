# I2C Communication System

## Overview

This project implements an FPGA-based I2C communication system using SystemVerilog.

The project consists of

* I2C Master
* I2C Slave
* UART Interface
* UVM Verification Environment

The communication between Master and Slave was verified through RTL simulation and UVM testbench.

---

## Features

* I2C Master RTL
* I2C Slave RTL
* UART Interface
* FPGA Top Module
* UVM Verification
* Functional Coverage
* Constraint Files

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

During FPGA-to-FPGA hardware testing between the I2C Master and Slave boards, the same data was sometimes received correctly, while in other cases the entire received data sequence was consistently shifted by one bit.

Because the transmitted data itself was valid and the error appeared as a consistent bit shift rather than random data corruption or loss, the issue was identified as a timing and synchronization problem between clock domains (CDC).

This hardware test highlighted the importance of proper clock-domain synchronization and stable sampling timing when interfacing communication modules implemented with different timing domains.

## Future Improvements

The clock-domain crossing path can be improved by applying appropriate synchronization techniques and reviewing the timing relationship between the UART and I2C interfaces.

The I2C sampling timing can also be further verified in both simulation and FPGA hardware to ensure that SDA is sampled at a stable point relative to SCL.

For continuous UART-to-I2C communication, an intermediate FIFO can be added to buffer incoming UART data while the I2C interface is busy.

Expected improvements include:

* Improving clock-domain synchronization
* Stabilizing data sampling across clock domains
* Buffering UART input while the I2C interface is busy
* Supporting longer and continuous data transfers more reliably
