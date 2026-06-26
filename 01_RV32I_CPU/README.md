# RV32I CPU

## 1. Project Overview

This project implements and verifies an RV32I CPU using SystemVerilog.
The CPU is designed with a separated Control Unit, Datapath, Instruction Memory, and Data Memory structure.

The purpose of this project is to understand how RISC-V instructions are executed through the hardware datapath, including instruction fetch, decode, execution, memory access, write-back, branch, and jump control.

## 2. Features

* RV32I base instruction support
* SystemVerilog RTL design
* Control Unit and Datapath separation
* Instruction Memory and Data Memory integration
* Register File, ALU, Program Counter, Immediate Generator implementation
* Load / Store operation support
* Branch / JAL / JALR control support
* C code to RISC-V assembly behavior analysis
* Simulation-based waveform verification

## 3. Supported Instruction Types

| Type   | Description                              |
| ------ | ---------------------------------------- |
| R-Type | Register-register ALU operation          |
| I-Type | Immediate ALU operation                  |
| Load   | Memory read operation                    |
| S-Type | Memory write operation                   |
| B-Type | Conditional branch operation             |
| U-Type | LUI / AUIPC operation                    |
| J-Type | JAL jump operation                       |
| JALR   | Register-based jump and return operation |

## 4. Project Structure

```text
01_RV32I_CPU/
├── README.md
├── RTL/
│   ├── rv32i_cpu.sv
│   ├── rv32i_datapath.sv
│   ├── control_unit.sv
│   ├── instruction_mem.sv
│   ├── data_mem.sv
│   └── define.vh
├── TB/
├── MEM/
│   ├── instruction_code.mem
│   └── instruction_mem_sort.mem
├── Docs/
└── Images/
```

## 5. Architecture

```text
top_rv32i_soc
├── instruction_mem
├── data_mem
└── rv32i_cpu
    ├── control_unit
    └── rv32i_datapath
        ├── Program Counter
        ├── Register File
        ├── ALU
        ├── Immediate Generator
        └── MUX Logic
```

## 6. Main Modules

### rv32i_cpu.sv

Top CPU module.
Connects the Control Unit and Datapath and manages the CPU-level execution flow.

### control_unit.sv

Generates control signals based on opcode, funct3, and funct7 fields.

Main control signals include:

* Register File write enable
* ALU operation control
* ALU source selection
* Memory write enable
* Memory access mode
* Branch control
* JAL / JALR control
* Write-back source selection

### rv32i_datapath.sv

Implements the main data path of the CPU.

Main components:

* Program Counter
* Register File
* ALU
* Immediate Generator
* PC update path
* Branch / Jump target calculation
* Write-back path

### instruction_mem.sv

Stores test instruction programs using memory initialization files.

### data_mem.sv

Implements data memory for load and store instructions.

Supported memory access types:

* Byte
* Half-word
* Word
* Unsigned byte
* Unsigned half-word

## 7. Verification

The CPU was verified through simulation by loading RISC-V assembly-level instruction programs into Instruction Memory.

Verification focused on the following points:

| Instruction Type | Main Verification Signals                 |
| ---------------- | ----------------------------------------- |
| R-Type           | rs1, rs2, alu_result, wb_out, rf_we       |
| I-Type           | imm_extend, alusrc_sel, alu_result, rf_we |
| S-Type           | daddr, dwdata, dwe, mem_mode              |
| B-Type           | branch, b_taken, pc_imm, pc_4, instr_addr |
| JAL              | jal, pc_4, pc_imm, wb_out, rf_we          |
| JALR             | jalr, rs1, instr_addr                     |
| U-Type           | imm_extend, rfsrc_sel, wb_out, rf_we      |

## 8. Verification Scenarios

### 8.1 ALU Operation Verification

R-Type and I-Type instructions were verified by checking ALU inputs, ALU result, and register write-back behavior.

### 8.2 Load / Store Verification

Load and store instructions were verified by checking memory address generation, write data, read data, memory mode, and write enable signals.

### 8.3 Branch Verification

Branch instructions were verified by checking branch condition result, branch target address, and next PC selection.

### 8.4 JAL / JALR Verification

JAL and JALR instructions were verified by checking PC+4 write-back, jump target calculation, return address handling, and register-based PC update.

### 8.5 C Code and Assembly Flow Analysis

A C program was compiled into RISC-V assembly and analyzed at the instruction level.

The verification included:

* Stack frame allocation
* Local variable memory mapping
* Function call and return sequence
* Pointer-based memory access
* Loop and conditional branch execution

## 9. Troubleshooting

### JALR Signal Not Observed

During simulation, the JALR signal initially appeared inactive.

Root cause:

* The simulation time was too short.
* The program had not yet reached the return instruction.

Solution:

* Extended the simulation runtime.
* Checked the PC region where the return instruction was executed.
* Confirmed that JALR was activated at the correct instruction address.

## 10. What I Learned

Through this project, I gained practical experience in:

* RISC-V instruction execution flow
* CPU datapath design
* Control signal generation
* Register File and ALU integration
* Memory access handling
* Branch and jump control
* Assembly-level debugging
* Waveform-based RTL verification

## 11. Tech Stack

* SystemVerilog
* Verilog HDL
* RISC-V RV32I
* Vivado / Simulation Tool
* Assembly-level verification

## 12. Summary

This project demonstrates the implementation and verification of an RV32I CPU using SystemVerilog.
The main focus was not only RTL implementation but also understanding how each instruction type moves through the datapath and how control signals affect CPU execution.

The project helped strengthen my understanding of RTL design, CPU architecture, and waveform-based debugging.
