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

04_I2C
│
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
