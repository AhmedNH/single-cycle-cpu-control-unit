# Automated MIPS-Style CPU Control Unit in Verilog

A structural Verilog implementation of a MIPS-style single-cycle CPU, built from primitive logic gates up through a complete control unit. The project evolves across four iterations, progressively automating the control signals from manual software logic to fully hardware-driven combinational circuits.

---

## CPU Architecture

```
         +--------+     +--------+     +--------+     +--------+     +--------+
clk ---->|   IF   |---->|   ID   |---->|   EX   |---->|   DM   |---->|   WB   |
         | Fetch  |     | Decode |     | Execute|     |  Data  |     | Write  |
         +--------+     +--------+     +--------+     | Memory |     |  Back  |
              |              |              |          +--------+     +--------+
              |         +--------+          |               |              |
              |         | Reg    |          |               |              |
              |         | File   |          v               |              |
              +-------->|        |       +-----+            |              |
                        +--------+       | ALU |            |              |
                             ^           +-----+            |              |
                             |                              |              |
                             +------------------------------+--------------+
                                        Write Back

Control:  yC1 (opcode decoder) --> yC2 (datapath signals) --> yC3/yC4 (ALU control)
```

---

## Pipeline Stages

| Module | Stage | Description |
|---|---|---|
| `yIF` | Instruction Fetch | Holds the PC register, increments it by 4 each cycle using `yAlu`, reads the instruction from memory |
| `yID` | Instruction Decode | Extracts register numbers, sign-extends the immediate, reads from the register file |
| `yEX` | Execute | Selects ALU operands via `yMux`, performs the operation via `yAlu` |
| `yDM` | Data Memory | Reads or writes memory based on `MemRead`/`MemWrite` control signals |
| `yWB` | Write Back | Selects between ALU result and memory output via `yMux` to write back to the register file |
| `yPC` | Program Counter | Computes branch target, jump target, and interrupt entry point; selects next PC |

---

## Control Unit

Split across four modules that decode the instruction's opcode and function code into all required datapath and ALU control signals:

### `yC1` — Instruction Type Decoder
Decodes the 6-bit opcode using combinational logic gates into five mutually exclusive instruction type signals:

| Signal | Opcode | Instruction |
|---|---|---|
| `rtype` | `000000` | R-format (add, sub, and, or, slt) |
| `lw` | `100011` | Load word |
| `sw` | `101011` | Store word |
| `branch` | `000100` | Branch equal |
| `jump` | `000010` | Jump |

### `yC2` — Datapath Signal Generator
Derives all six datapath control signals from the instruction type using purely combinational logic:

| Signal | Logic |
|---|---|
| `RegDst` | `rtype` |
| `ALUSrc` | `NOR(rtype, branch)` |
| `RegWrite` | `NOR(branch, sw)` |
| `Mem2Reg` | `lw` |
| `MemRead` | `lw` |
| `MemWrite` | `sw` |

### `yC3` — ALUop Generator
Maps instruction type to a 2-bit `ALUop` code that feeds into `yC4`.

### `yC4` — ALU Operation Selector
Decodes `ALUop` and the 6-bit function code into the 3-bit `op` signal for `yAlu`:

| `op` | Operation |
|---|---|
| `000` | AND |
| `001` | OR |
| `010` | ADD |
| `110` | SUB |
| `111` | SLT (set less than) |

---

## Building Blocks

All built structurally from primitive gates — no behavioral `always` blocks in the datapath:

| Module | Description |
|---|---|
| `yMux1` | 1-bit 2-to-1 multiplexer (NOT, AND, OR gates) |
| `yMux` | Parameterised N-bit 2-to-1 multiplexer (array of `yMux1`) |
| `yMux4to1` | Parameterised N-bit 4-to-1 multiplexer (three `yMux` stages) |
| `yAdder1` | 1-bit full adder (XOR, AND, OR gates) |
| `yAdder` | 32-bit ripple-carry adder (array of `yAdder1`) |
| `yArith` | 32-bit add/subtract unit (inverts `b` and sets `cin=1` for subtraction) |
| `yAlu` | 32-bit ALU with AND, OR, ADD, SUB, SLT, and zero-flag detection |

---

## Four-Iteration Evolution

### LabN1 — Manual Software Control
All control signals (`RegDst`, `ALUSrc`, `RegWrite`, etc.) are set explicitly in Verilog `initial` blocks by decoding the opcode in software. Demonstrates the full set of signals required for each instruction type.

### LabN2 — Partial Hardware Control (`yC1` + `yC2`)
The main datapath signals are now generated automatically by the hardware control modules `yC1` and `yC2`. The ALU `op` signal is still set manually in software.

### LabN3 — Full Hardware Control (`yC1` through `yC4`)
All control signals including the ALU `op` are generated entirely by hardware. The testbench contains no manual signal assignments — the chip runs automatically.

### LabN4 — Integrated `yChip`
Everything is encapsulated inside a single `yChip` top-level module. The testbench instantiates only `yChip` and observes outputs, fully abstracting the internal control and datapath.

---

## Test Program

`ram.dat` initialises memory with a MIPS program that iterates over an integer array, computes the sum and OR-reduction, and stores the results:

```
array = [1, 3, 5, 7, 9, 11]   (at addresses 0x50–0x68)

Loop:
  t0 = array[t5]
  if t0 == 0: jump to done
  s0 = s0 + t0      # sum
  a0 = a0 | t0      # or reduction
  t5 += 4
  jump loop

done:
  mem[0x20] = s0    # save sum
  mem[0x24] = a0    # save or reduction
```

---

## Running

Requires a Verilog simulator such as [Icarus Verilog](http://iverilog.icarus.com/).

```bash
# Run the fully automated version (LabN4)
iverilog -o sim cpu.v LabN4.v && vvp sim

# Run earlier iterations
iverilog -o sim cpu.v LabN1.v && vvp sim
iverilog -o sim cpu.v LabN2.v && vvp sim
iverilog -o sim cpu.v LabN3.v && vvp sim
```

---

## Project Structure

```
Automated MIPS-Style CPU Control Unit in Verilog/
├── cpu.v      # All datapath and control modules
├── LabN1.v    # Testbench: fully manual control signals
├── LabN2.v    # Testbench: yC1 + yC2 hardware control
├── LabN3.v    # Testbench: full hardware control (yC1-yC4)
├── LabN4.v    # Testbench: yChip top-level integration
└── ram.dat    # Memory image: array sum/OR program
```
