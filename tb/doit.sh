#!/bin/sh
set -e

# Run from the repository root (d:\antigravity\lab4-riscv) so rom/program.hex resolves cleanly.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

rm -rf obj_dir cpu.vcd

verilator -Wall --cc --trace \
    -Irtl \
    rtl/pc_unit.sv \
    rtl/instr_mem.sv \
    rtl/sign_extend.sv \
    rtl/control_unit.sv \
    rtl/reg_file.sv \
    rtl/alu.sv \
    rtl/data_mem.sv \
    rtl/top.sv \
    --top-module top \
    --exe tb/cpu_tb.cpp

make -j -C obj_dir/ -f Vtop.mk Vtop

./obj_dir/Vtop
