// Arithmetic Logic Unit: supports ADD, SUB, AND, OR, SLT and outputs equality flag EQ.
module alu #(
    parameter DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0] alu_op1,
    input  logic [DATA_WIDTH-1:0] alu_op2,
    input  logic [2:0]            alu_ctrl,
    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  eq
);

    always_comb begin
        case (alu_ctrl)
            3'b000:  alu_out = alu_op1 + alu_op2;
            3'b001:  alu_out = alu_op1 - alu_op2;
            3'b010:  alu_out = alu_op1 & alu_op2;
            3'b011:  alu_out = alu_op1 | alu_op2;
            3'b101:  alu_out = ($signed(alu_op1) < $signed(alu_op2))
                               ? {{(DATA_WIDTH-1){1'b0}}, 1'b1}
                               : {DATA_WIDTH{1'b0}};
            default: alu_out = {DATA_WIDTH{1'b0}};
        endcase
    end

    assign eq = (alu_op1 == alu_op2);

endmodule
