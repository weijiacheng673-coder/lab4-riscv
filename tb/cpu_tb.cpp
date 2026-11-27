#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstdint>
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vtop* top = new Vtop;
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("cpu.vcd");

    top->clk = 1;
    top->rst = 1;

    uint32_t expected_count  = 0;
    uint32_t prev_a0         = 0;
    bool     started         = false;
    int      samples_checked = 0;

    for (int cycle = 0; cycle < 1600; ++cycle) {
        for (int clk = 0; clk < 2; ++clk) {
            tfp->dump(2 * cycle + clk);
            top->clk = !top->clk;
            top->eval();
        }

        // Release reset after 2 cycles
        top->rst = (cycle < 2) ? 1 : 0;

        if (cycle >= 5) {
            uint32_t cur_a0 = top->a0;
            // Output updates once per inner loop iteration (every 3 cycles after init).
            if (!started) {
                if (cur_a0 == 0) {
                    started = true;
                }
            } else if (cur_a0 != prev_a0) {
                expected_count = (expected_count == 254) ? 0 : (expected_count + 1);
                if (cur_a0 != expected_count) {
                    std::cerr << "FAIL at cycle " << cycle
                              << ": expected a0=" << expected_count
                              << ", got " << cur_a0 << std::endl;
                    tfp->close();
                    delete top;
                    return 1;
                }
                ++samples_checked;
                if (cur_a0 <= 2 || cur_a0 >= 253) {
                    std::cout << "[cycle " << cycle << "] a0 = " << cur_a0 << std::endl;
                }
            }
            prev_a0 = cur_a0;
        }
    }

    tfp->close();
    delete top;

    if (samples_checked < 500) {
        std::cerr << "FAIL: insufficient transitions checked (" << samples_checked << ")" << std::endl;
        return 1;
    }

    std::cout << "PASS: Lab 4 RISC-V CPU counter verified (" << samples_checked
              << " transitions)!" << std::endl;
    return 0;
}
