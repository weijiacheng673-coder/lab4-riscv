// Top-Level Single-Cycle RISC-V CPU (addi + bne subset, Lecture 7 Slide 24).
module top #(
    parameter DATA_WIDTH = 32,
    parameter MEM_FILE   = "rom/program.hex"
) (
    input  logic                  clk,
    input  logic                  rst,
    output logic [DATA_WIDTH-1:0] a0
);

    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] instr;
    logic [DATA_WIDTH-1:0] imm_op;
    logic [DATA_WIDTH-1:0] reg_op1;
    logic [DATA_WIDTH-1:0] reg_op2;
    logic [DATA_WIDTH-1:0] alu_op2;
    logic [DATA_WIDTH-1:0] alu_out;

    logic       reg_write;
    logic [2:0] alu_ctrl;
    logic       alu_src;
    logic [1:0] imm_src;
    logic       pc_src;
    logic       eq;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    pc_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_pc_unit (
        .clk    (clk),
        .rst    (rst),
        .pc_src (pc_src),
        .imm_op (imm_op),
        .pc     (pc)
    );

    instr_mem #(
        .ADDR_WIDTH(DATA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH (256),
        .MEM_FILE  (MEM_FILE)
    ) u_instr_mem (
        .pc    (pc),
        .instr (instr)
    );

    sign_extend u_sign_extend (
        .instr   (instr),
        .imm_src (imm_src),
        .imm_op  (imm_op)
    );

    control_unit u_control_unit (
        .instr     (instr),
        .eq        (eq),
        .reg_write (reg_write),
        .alu_ctrl  (alu_ctrl),
        .alu_src   (alu_src),
        .imm_src   (imm_src),
        .pc_src    (pc_src)
    );

    reg_file #(
        .ADDR_WIDTH(5),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_reg_file (
        .clk (clk),
        .ad1 (rs1),
        .ad2 (rs2),
        .ad3 (rd),
        .we3 (reg_write),
        .wd3 (alu_out),
        .rd1 (reg_op1),
        .rd2 (reg_op2),
        .a0  (a0)
    );

    assign alu_op2 = alu_src ? imm_op : reg_op2;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (
        .alu_op1  (reg_op1),
        .alu_op2  (alu_op2),
        .alu_ctrl (alu_ctrl),
        .alu_out  (alu_out),
        .eq       (eq)
    );

endmodule
