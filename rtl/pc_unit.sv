// Program Counter Unit: holds PC, computes PC+4 and PC+ImmOp, selects next_pc.
module pc_unit #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  pc_src,
    input  logic [DATA_WIDTH-1:0] imm_op,
    output logic [DATA_WIDTH-1:0] pc
);

    logic [DATA_WIDTH-1:0] inc_pc;
    logic [DATA_WIDTH-1:0] branch_pc;
    logic [DATA_WIDTH-1:0] next_pc;

    assign inc_pc    = pc + {{(DATA_WIDTH-3){1'b0}}, 3'd4};
    assign branch_pc = pc + imm_op;
    assign next_pc   = pc_src ? branch_pc : inc_pc;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= {DATA_WIDTH{1'b0}};
        end else begin
            pc <= next_pc;
        end
    end

endmodule
