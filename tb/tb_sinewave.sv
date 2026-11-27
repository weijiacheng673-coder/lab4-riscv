`timescale 1ns/1ps

// Self-checking SystemVerilog testbench for Lab 4 Stretched Goal (Software Sinewave Generator).
module tb_sinewave;

    logic        clk;
    logic        rst;
    logic [31:0] a0;

    logic [7:0] expected_lut [0:255];

    integer sample_idx;
    integer samples_checked;
    integer cycle;

    top #(
        .DATA_WIDTH(32),
        .MEM_FILE  ("rom/sinewave.hex"),
        .DATA_FILE ("rom/sinerom.mem")
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
        $readmemh("rom/sinerom.mem", expected_lut);
        $dumpfile("sinewave.vcd");
        $dumpvars(0, tb_sinewave);

        rst             = 1'b1;
        sample_idx      = 0;
        samples_checked = 0;

        // Hold reset for 2 rising edges, then release.
        @(posedge clk);
        @(posedge clk);
        #1;
        rst = 1'b0;

        for (cycle = 0; cycle < 1600; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            // PC == 0x10 means lbu a0, 0(a1) at 0x0c just committed on this posedge.
            if (dut.pc == 32'h0000_0010) begin
                if (a0 !== {24'd0, expected_lut[sample_idx]}) begin
                    $display("FAIL at cycle %0d (idx=%0d): expected a0 = %0d, got a0 = %0d",
                             cycle, sample_idx, expected_lut[sample_idx], a0);
                    $fatal(1, "Sinewave output mismatch!");
                end

                if ((samples_checked < 256 &&
                     (sample_idx == 0 || sample_idx == 32 || sample_idx == 64 ||
                      sample_idx == 96 || sample_idx == 128 || sample_idx == 160 ||
                      sample_idx == 192 || sample_idx == 224 || sample_idx == 255)) ||
                    (samples_checked >= 256 && sample_idx == 0 && samples_checked < 260)) begin
                    $display("[cycle %4d] idx=%3d, samples=%3d, a0=%3d (0x%02x)",
                             cycle, sample_idx, samples_checked, a0, a0[7:0]);
                end

                samples_checked = samples_checked + 1;
                if (sample_idx == 255) begin
                    sample_idx = 0;
                end else begin
                    sample_idx = sample_idx + 1;
                end
            end
        end

        if (samples_checked < 512) begin
            $fatal(1, "Insufficient sinewave samples checked: %0d (expected >= 512)", samples_checked);
        end

        $display("Checked %0d sinewave samples across >=2 full 256-sample periods.", samples_checked);
        $display("PASS: Lab 4 Stretched Goal sinewave generator verified!");
        $finish;
    end

endmodule
