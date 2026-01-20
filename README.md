# Single-Cycle CPU Control Unit

A **hardware-focused systems project** implementing a modular single-cycle CPU with fully automated control logic, designed and composed using structural hardware descriptions.

The project demonstrates how **instruction execution, control signal generation, and program counter selection** are implemented at the circuit level, without behavioral shortcuts.

---

## 🔍 Overview

This repository implements a functional single-cycle CPU architecture with:

* A complete datapath
* Automated control unit logic
* Program counter (PC) selection circuitry
* Instruction decoding and ALU control
* Interrupt-based context switching

All control signals required for instruction execution are generated **entirely by hardware modules**, mirroring real CPU design principles.

---

## 🧠 CPU Architecture

### Datapath Components

The CPU datapath consists of modular components responsible for:

* Instruction fetch and decoding
* Register file access
* ALU execution
* Data memory access
* Write-back selection

Each component is instantiated explicitly and connected via well-defined interfaces, enforcing separation of concerns and architectural clarity.

---

### Program Counter (PC) Control

Instruction sequencing is implemented structurally using a dedicated PC-selection module that determines the next instruction address based on:

* Sequential execution
* Conditional branching (`beq`)
* Unconditional jumps
* Interrupt-driven context switches

This logic is implemented using cascaded multiplexers rather than behavioral control flow.

---

## 🧩 Automated Control Unit Design

The control unit is decomposed into multiple hardware modules:

### Instruction Classification

* Decodes opcode fields to classify instructions (R-type, load, store, branch, jump)
* Outputs instruction-type signals used by downstream logic

---

### Control Signal Generation

* Generates datapath control signals such as:
  * Register destination selection
  * ALU operand selection
  * Memory read/write enables
  * Write-back control
* Logic is derived from instruction semantics and implemented declaratively using gates and simple combinational logic

---

### ALU Control Logic

* Separates instruction-level intent from operation-level execution
* Uses a two-stage approach:
  * High-level ALU operation classification
  * Function-code–based operation selection for R-type instructions

This mirrors real-world CPU control-unit design patterns.

---

## 🔁 Interrupt & Context Switching

The CPU supports external interrupts via:

* An interrupt signal
* A configurable entry-point address

When triggered, instruction execution is redirected without external intervention, modeling basic context-switch behavior found in real processors.

---

## 🔄 Structural Validation

Correctness is verified by:

* Matching execution output against known reference results
* Ensuring deterministic behavior across instruction sequences
* Confirming that all control signals are generated internally

No external module assists with instruction execution once the CPU is initialized.

---

## 🛠️ Technologies & Concepts

* **Domain:** Computer Architecture / Digital Systems
* **Design Style:** Structural hardware description
* **Core Concepts:**

  * Single-cycle CPU architecture
  * Datapath and control-unit separation
  * Instruction decoding
  * ALU control logic
  * Program counter selection
  * Interrupt handling
  * Hardware modularity

---

## 🚀 Why This Project Matters

This project demonstrates skills directly relevant to **FAANG-scale systems and hardware-adjacent roles**:

* Deep understanding of how CPUs execute instructions
* Ability to translate ISA semantics into hardware logic
* Experience designing modular, testable systems
* Comfort reasoning about control flow at the circuit level
* Strong foundation for architecture, performance, and low-level systems work

---

## 👤 Author

**Computer Science (Honors)**  
York University  
Third-Year Computer Science Honors Student
