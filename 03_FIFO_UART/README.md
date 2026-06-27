# UART + FIFO SystemVerilog Verification Environment

## Overview

This project implements and verifies a UART + FIFO RTL design using a custom SystemVerilog verification environment.

The purpose of this project was to understand the basic structure of functional verification before applying the UVM framework.  
Instead of using the UVM library, the verification environment was built manually with Transaction, Generator, Driver, Monitor, Scoreboard, Environment, Mailbox, and Virtual Interface.

The DUT consists of a UART Receiver, a single FIFO buffer, and a UART Transmitter.

---

## Design Architecture

```text
UART RX
   ↓
Single FIFO
   ↓
UART TX
```

The FIFO is placed between UART RX and UART TX to buffer received data before transmission.

---

## Verification Architecture

```text
Generator
   ↓
Driver
   ↓
DUT : UART RX → FIFO → UART TX
   ↓
Monitor
   ↓
Scoreboard
```

The Generator creates UART byte transactions.  
The Driver converts each byte into a UART serial frame and drives the DUT `rx` input.  
The Monitor observes the DUT `tx` output and reconstructs the transmitted byte.  
The Scoreboard compares expected data with actual received data.

---

## Main RTL Modules

### uart_rx.v

Implements UART receive logic.

- Start bit detection
- Serial data sampling
- Serial-to-parallel conversion
- RX done signal generation

### fifo_sv.sv

Implements a single FIFO buffer.

- FIFO memory
- Write pointer
- Read pointer
- Full detection
- Empty detection
- Push / Pop control

### uart_tx.v

Implements UART transmit logic.

- Parallel-to-serial conversion
- Start bit generation
- Data bit transmission
- Stop bit generation
- TX busy control

### uart_fifo_top.sv

Top-level module that connects UART RX, FIFO, and UART TX.

---

## Verification Components

### transaction

Stores expected transmit data and actual received data.

```systemverilog
rand bit [7:0] tx_byte;
     bit [7:0] rx_byte;
```

### generator

Creates test data.

- Directed pattern test
- Random byte test

Directed patterns include:

```text
55, AA, F0, 0F, 00, FF
```

### driver

Drives UART serial frames into the DUT `rx` line.

UART frame format:

```text
Start bit(0) + 8 data bits(LSB first) + Stop bit(1)
```

### monitor

Observes the DUT `tx` line and reconstructs UART bytes.

- Detects start bit
- Samples data bits
- Checks stop bit

### scoreboard

Compares expected bytes and actual bytes.

- Expected data queue
- Pass count
- Fail count
- Total transaction count

### environment

Connects all verification components using mailboxes and a virtual interface.

---

## Test Scenario

The testbench supports both directed and random tests.

### Directed Test

Uses fixed byte patterns to verify bit-level UART behavior.

```text
0x55, 0xAA, 0xF0, 0x0F, 0x00, 0xFF
```

### Random Test

Runs random UART byte transactions.

```systemverilog
run_count = 1000;
gen.run_random(run_count);
drv.run(run_count);
```

The scoreboard waits until all generated transactions are checked.

---

## Verification Result

The verification environment checks whether data transmitted into the DUT through `rx` is correctly returned through `tx` after passing through UART RX, FIFO, and UART TX.

At the end of simulation, the scoreboard reports:

```text
total
pass
fail
```

This confirms end-to-end data consistency through the UART + FIFO datapath.

---

## Key Points

- Built a custom SystemVerilog verification environment before learning UVM
- Implemented transaction-based stimulus generation
- Used mailbox-based communication between verification components
- Used a virtual interface to connect class-based verification components with RTL signals
- Verified UART frame generation and reconstruction
- Verified FIFO-based data buffering
- Checked actual output data using a scoreboard

---

## Skills

- Verilog HDL
- SystemVerilog
- Class-based Testbench
- Transaction Modeling
- Mailbox Communication
- Virtual Interface
- UART Protocol
- FIFO Design
- Scoreboard-based Verification
- RTL Simulation
- Waveform Debugging

---

## What I Learned

Through this project, I learned the basic structure of functional verification by building a verification environment manually.

Before applying the UVM framework, I implemented the core verification concepts myself:

- Transaction
- Generator
- Driver
- Monitor
- Scoreboard
- Environment

This helped me understand how verification components exchange data, how expected and actual results are compared, and how a reusable verification structure is organized.

This project became the foundation for later UVM-based verification work.

---

## Future Improvements

- Convert the custom verification environment into a standard UVM structure
- Add functional coverage
- Add SystemVerilog Assertions
- Add overflow / underflow test cases
- Add randomized frame timing
- Add parity/error injection scenarios
