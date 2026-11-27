// Instruction Memory (ROM): word-addressed 32-bit instruction lookup indexed by PC[9:2].
module instr_mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256,
    parameter MEM_FILE   = "rom/program.hex"
) (
    input  logic [ADDR_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] instr
);

    localparam INDEX_WIDTH = $clog2(MEM_DEPTH);

    logic [DATA_WIDTH-1:0] rom_array [0:MEM_DEPTH-1];

    initial begin : init_rom
        integer i;
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            rom_array[i] = 32'h0000_0013; // NOP (addi x0, x0, 0)
        end
        $readmemh(MEM_FILE, rom_array);
    end

    // PC is byte-addressed; drop lower 2 bits for 32-bit word alignment.
    assign instr = rom_array[pc[INDEX_WIDTH+1:2]];

endmodule
