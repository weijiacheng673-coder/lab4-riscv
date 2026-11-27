// 32x32 Register File with two async read ports, one sync write port, and direct a0 probe.
module reg_file #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] ad1,
    input  logic [ADDR_WIDTH-1:0] ad2,
    input  logic [ADDR_WIDTH-1:0] ad3,
    input  logic                  we3,
    input  logic [DATA_WIDTH-1:0] wd3,
    output logic [DATA_WIDTH-1:0] rd1,
    output logic [DATA_WIDTH-1:0] rd2,
    output logic [DATA_WIDTH-1:0] a0
);

    logic [DATA_WIDTH-1:0] reg_array [0:(1<<ADDR_WIDTH)-1];

    initial begin : init_regs
        integer i;
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            reg_array[i] = {DATA_WIDTH{1'b0}};
        end
    end

    always_ff @(posedge clk) begin
        // Protect x0 (zero register) against writes.
        if (we3 && (ad3 != {ADDR_WIDTH{1'b0}})) begin
            reg_array[ad3] <= wd3;
        end
    end

    assign rd1 = (ad1 == {ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : reg_array[ad1];
    assign rd2 = (ad2 == {ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : reg_array[ad2];
    assign a0  = reg_array[10]; // x10 == a0

endmodule
