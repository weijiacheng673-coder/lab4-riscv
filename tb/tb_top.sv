`timescale 1ns/1ps

// Self-checking SystemVerilog testbench for Lab 4 single-cycle RISC-V CPU.
module tb_top;

    logic        clk;
    logic        rst;
    logic [31:0] a0;

    integer expected_count;
    integer samples_checked;
    integer cycle;

    top #(
        .DATA_WIDTH(32),
        .MEM_FILE  ("rom/program.hex")
    ) dut (
        .clk (clk),
        .rst (rst),
        .a0  (a0)
    );

    // 100 MHz clock (10ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_top);

        rst             = 1'b1;
        expected_count  = 0;
        samples_checked = 0;

        // Hold reset for 2 rising edges, then release.
        @(posedge clk);
        @(posedge clk);
        #1;
        rst = 1'b0;

        for (cycle = 0; cycle < 1600; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            // PC == 0x10 means addi a0, a1, 0 at 0x0c just committed on this posedge.
            if (dut.pc == 32'h0000_0010) begin
                if (a0 !== expected_count[31:0]) begin
                    $display("FAIL at cycle %0d: expected a0 = %0d, got a0 = %0d",
                             cycle, expected_count, a0);
                    $fatal(1, "Counter output mismatch!");
                end

                if (expected_count == 0 || expected_count == 1 || expected_count == 2 ||
                    expected_count == 253 || expected_count == 254) begin
                    $display("[cycle %4d] samples=%3d, a0=%3d (0x%02x)",
                             cycle, samples_checked, a0, a0[7:0]);
                end

                samples_checked = samples_checked + 1;
                if (expected_count == 254) begin
                    expected_count = 0;
                end else begin
                    expected_count = expected_count + 1;
                end
            end
        end

        if (samples_checked < 510) begin
            $fatal(1, "Insufficient samples checked: %0d (expected >= 510)", samples_checked);
        end

        $display("Checked %0d counter samples across >=2 full 0..254 loops.", samples_checked);
        $display("PASS: Lab 4 RISC-V CPU counter verified!");
        $finish;
    end

endmodule
