# FIFO Verification Project (SystemVerilog)

## Overview
This project implements and verifies a synchronous FIFO (First-In-First-Out) design using SystemVerilog.

The goal of this project is to demonstrate fundamental verification skills including:
- Writing RTL modules
- Building a structured testbench
- Verifying functionality using directed tests
- Handling edge cases and corner scenarios

---

## FIFO Design

### Parameters
- `DATA_WIDTH = 8`
- `DEPTH = 8`

### Features
- Synchronous design
- Active-low reset (`rst_n`)
- Write and read operations controlled by `wr_en` and `rd_en`
- Status signals:
  - `full`
  - `empty`

### Internal Mechanism
- Circular buffer implementation
- Write and read pointers (`wr_ptr`, `rd_ptr`)
- Element counter (`count`)

---

## Verification Strategy

A self-checking testbench was implemented to validate the FIFO behavior.

The testbench includes clock generation, reset handling, and multiple directed test scenarios.

---

## Test Scenarios

### TEST 1: Reset Test
Verifies that all internal states are correctly initialized after reset.

### TEST 2: Single Write/Read
Writes a single value and verifies it is correctly read back.

### TEST 3: FIFO Order Test
Validates that data is read in the same order it was written (FIFO behavior).

### TEST 4: Full Condition Test
- Fills the FIFO completely
- Verifies `full` assertion
- Ensures no state change on illegal write

### TEST 5: Simultaneous Read/Write
- Performs read and write in the same cycle
- Verifies:
  - Count remains unchanged
  - Correct data is read
  - New data is properly stored

### TEST 6: Empty (Underflow) Test
- Attempts to read from an empty FIFO
- Verifies no change in internal state

---

## Tools Used

- SystemVerilog
- Icarus Verilog (`iverilog`)
- GTKWave (optional for waveform viewing)

---

## How to Run

```bash
iverilog -g2012 -o sim/fifo_sim rtl/sync_fifo.sv tb/sync_fifo_tb.sv
vvp sim/fifo_sim
