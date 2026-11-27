# Lab 4 – A Very Basic RISC-V CPU

Imperial College London — EIE2 Instruction Architectures & Compilers (Lab 4)

## Overview
A simplified single-cycle RISC-V CPU implementing `addi` and `bne` to execute a software binary counter (outputting on register `a0` / `x10`).

- **Base Goal**: Execute `addi` and `bne` to run the Lab 1 binary counter in software.
- **Stretched Goal**: Add a Data Memory load instruction (e.g., `lw` / `lbu`) and `ResultSrc` MUX to implement a software sinewave generator.

## Repository Structure
```text
lab4-riscv/
├── rtl/            # SystemVerilog hardware modules (top, pc, instr_mem, control, sign_ext, regfile, alu)
├── tb/             # Verilator C++ testbenches & Vbuddy scripts
├── rom/            # Assembly source & machine-code hex files
│   ├── program.s   # Lab 4 binary counter assembly (Slide 22)
│   └── program.hex # Assembled 32-bit hex dump (Slide 22)
├── .gitignore
└── README.md
```

## Module Division (Ref: Lecture 7 Slide 24)
| Subsystem | Modules | Key Signals |
| :--- | :--- | :--- |
| **PC Unit** | `pc_reg`, `pc_mux`, adders (`+4`, `+ImmOp`) | `clk`, `rst`, `PCsrc`, `ImmOp`, `PC` |
| **Fetch & Decode** | `instr_mem`, `control_unit`, `sign_extend` | `PC`, `instr`, `EQ`, `RegWrite`, `ALUctrl`, `ALUsrc`, `IMMsrc`, `PCsrc`, `ImmOp` |
| **Execute & RegFile** | `reg_file`, `alu_mux`, `alu` | `rs1`, `rs2`, `rd`, `WD3`, `WE3`, `ALUout`, `EQ`, `a0` |
| **Top & Verification** | `top.sv`, `tb/cpu_tb.cpp` | `clk`, `rst`, `a0` |

## Team Git Workflow
1. Create a feature branch for your module:
   ```bash
   git checkout -b feat/<module-name>
   ```
2. Commit your changes and push to GitHub:
   ```bash
   git add .
   git commit -m "Implement <module-name>"
   git push -u origin feat/<module-name>
   ```
3. Open a Pull Request on GitHub to merge into `main`.
