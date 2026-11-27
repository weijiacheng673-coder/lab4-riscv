// Control Unit: decodes opcode/funct3 and ALU eq flag into datapath control signals.
module control_unit (
    input  logic [31:0] instr,
    input  logic        eq,
    output logic        reg_write,
    output logic [2:0]  alu_ctrl,
    output logic        alu_src,
    output logic [1:0]  imm_src,
    output logic        pc_src,
    output logic        mem_write,
    output logic        result_src,
    output logic        byte_mode
);

    logic [6:0] op;
    logic [2:0] funct3;

    assign op     = instr[6:0];
    assign funct3 = instr[14:12];

    always_comb begin
        reg_write  = 1'b0;
        alu_ctrl   = 3'b000;
        alu_src    = 1'b0;
        imm_src    = 2'b00;
        pc_src     = 1'b0;
        mem_write  = 1'b0;
        result_src = 1'b0;
        byte_mode  = 1'b0;

        case (op)
            7'b0000011: begin
                // I-type Load (lw / lbu)
                if (funct3 == 3'b010) begin
                    reg_write  = 1'b1;
                    alu_src    = 1'b1;
                    imm_src    = 2'b00;
                    alu_ctrl   = 3'b000;
                    result_src = 1'b1;
                    byte_mode  = 1'b0;
                end else if (funct3 == 3'b100) begin
                    reg_write  = 1'b1;
                    alu_src    = 1'b1;
                    imm_src    = 2'b00;
                    alu_ctrl   = 3'b000;
                    result_src = 1'b1;
                    byte_mode  = 1'b1;
                end
            end
            7'b0100011: begin
                // S-type Store (sw / sb)
                if (funct3 == 3'b010) begin
                    mem_write = 1'b1;
                    alu_src   = 1'b1;
                    imm_src   = 2'b01;
                    alu_ctrl  = 3'b000;
                    byte_mode = 1'b0;
                end else if (funct3 == 3'b000) begin
                    mem_write = 1'b1;
                    alu_src   = 1'b1;
                    imm_src   = 2'b01;
                    alu_ctrl  = 3'b000;
                    byte_mode = 1'b1;
                end
            end
            7'b0010011: begin
                // I-type ALU (addi)
                if (funct3 == 3'b000) begin
                    reg_write = 1'b1;
                    alu_src   = 1'b1;
                    imm_src   = 2'b00;
                    alu_ctrl  = 3'b000;
                    pc_src    = 1'b0;
                end
            end
            7'b1100011: begin
                // B-type branch (beq / bne)
                reg_write = 1'b0;
                alu_src   = 1'b0;
                imm_src   = 2'b10;
                alu_ctrl  = 3'b001;
                if (funct3 == 3'b000) begin
                    pc_src = eq;
                end else if (funct3 == 3'b001) begin
                    pc_src = ~eq;
                end
            end
            default: begin
                // Unsupported opcodes leave defaults deasserted.
            end
        endcase
    end

endmodule
