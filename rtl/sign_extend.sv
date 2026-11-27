// Immediate Sign Extension Unit supporting I-type, S-type, and B-type formats.
module sign_extend (
    input  logic [31:0] instr,
    input  logic [1:0]  imm_src,
    output logic [31:0] imm_op
);

    always_comb begin
        case (imm_src)
            2'b00:   imm_op = {{20{instr[31]}}, instr[31:20]};                               // I-Type
            2'b01:   imm_op = {{20{instr[31]}}, instr[31:25], instr[11:7]};                 // S-Type
            2'b10:   imm_op = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-Type
            default: imm_op = 32'd0;
        endcase
    end

endmodule
