# Lab 4 – A Very Basic RISC-V CPU

Imperial College London — EIE2 Instruction Architectures & Compilers (Lab 4)

## Overview
A simplified single-cycle RISC-V CPU implementing `addi` and `bne` to execute a software binary counter (outputting on register `a0` / `x10`).

- **Base Goal**: Execute `addi` and `bne` to run the Lab 1 binary counter (`0 -> 254` wrap-around) in software.
- **Stretched Goal**: Add a Data Memory load instruction (e.g., `lw` / `lbu`) and `ResultSrc` MUX to implement a software sinewave generator.

## Repository Structure
```text
lab4-riscv/
├── rtl/
│   ├── pc_unit.sv       # PC register, +4 adder, branch target adder, PCsrc MUX
│   ├── instr_mem.sv     # Word-aligned instruction ROM loading rom/program.hex
│   ├── sign_extend.sv   # Immediate sign-extension (I-type, S-type, B-type)
│   ├── control_unit.sv  # Opcode/funct3 & EQ decoder
│   ├── reg_file.sv      # 32x32 register file (x0 hardwired to 0, a0 probe)
│   ├── alu.sv           # ALU (ADD, SUB, AND, OR, SLT) + EQ flag
│   └── top.sv           # Top-level single-cycle CPU integration
├── tb/
│   ├── tb_top.sv        # Self-checking SystemVerilog testbench (Icarus Verilog)
│   ├── cpu_tb.cpp       # C++ Verilator testbench
│   └── doit.sh          # Verilator build & run script (Linux/WSL/macOS)
├── rom/
│   ├── program.s        # Lab 4 binary counter assembly (Slide 22)
│   └── program.hex      # Assembled 32-bit hex dump (Slide 22)
├── .gitignore
└── README.md
```

## Module & Port Summary (Ref: Lecture 7 Slide 24)
| Module | Inputs | Outputs | Notes |
| :--- | :--- | :--- | :--- |
| `pc_unit` | `clk`, `rst`, `pc_src`, `imm_op[31:0]` | `pc[31:0]` | Synchronous active-high reset to `0` |
| `instr_mem` | `pc[31:0]` | `instr[31:0]` | Reads `rom_array[pc[9:2]]` |
| `sign_extend` | `instr[31:0]`, `imm_src[1:0]` | `imm_op[31:0]` | `00`=I-type, `01`=S-type, `10`=B-type |
| `control_unit` | `instr[31:0]`, `eq` | `reg_write`, `alu_ctrl[2:0]`, `alu_src`, `imm_src[1:0]`, `pc_src` | `addi` (`0x13`), `bne` (`0x63`, `f3=1`) |
| `reg_file` | `clk`, `ad1[4:0]`, `ad2[4:0]`, `ad3[4:0]`, `we3`, `wd3[31:0]` | `rd1[31:0]`, `rd2[31:0]`, `a0[31:0]` | `x0` writes ignored; `a0` = `x10` |
| `alu` | `alu_op1[31:0]`, `alu_op2[31:0]`, `alu_ctrl[2:0]` | `alu_out[31:0]`, `eq` | `eq = (alu_op1 == alu_op2)` |
| `top` | `clk`, `rst` | `a0[31:0]` | Connects all 6 submodules + `alu_src` MUX |

## Running Simulation

Run from the repository root (`lab4-riscv/`) so `rom/program.hex` is found via relative path.

### Option 1: Icarus Verilog (`iverilog` + `vvp`)
```bash
iverilog -g2012 -o sim.vvp rtl/pc_unit.sv rtl/instr_mem.sv rtl/sign_extend.sv rtl/control_unit.sv rtl/reg_file.sv rtl/alu.sv rtl/top.sv tb/tb_top.sv
vvp sim.vvp
```

### Option 2: Verilator (Linux / WSL / macOS)
```bash
chmod +x tb/doit.sh
./tb/doit.sh
```

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
