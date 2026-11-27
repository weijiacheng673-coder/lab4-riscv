// Data Memory: byte-addressed 256B RAM/ROM supporting byte (lbu/sb) and word (lw/sw) access.
module data_mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256,
    parameter DATA_FILE  = "rom/sinerom.mem"
) (
    input  logic                  clk,
    input  logic                  mem_write,
    input  logic                  byte_mode,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH-1:0] read_data
);

    localparam INDEX_WIDTH = $clog2(MEM_DEPTH);

    logic [7:0] mem_array [0:MEM_DEPTH-1];

    logic [INDEX_WIDTH-1:0] a0_idx;
    logic [INDEX_WIDTH-1:0] a1_idx;
    logic [INDEX_WIDTH-1:0] a2_idx;
    logic [INDEX_WIDTH-1:0] a3_idx;

    initial begin : init_data_mem
        integer i;
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem_array[i] = 8'h00;
        end
        $readmemh(DATA_FILE, mem_array);
    end

    assign a0_idx = addr[INDEX_WIDTH-1:0];
    assign a1_idx = a0_idx + {{(INDEX_WIDTH-1){1'b0}}, 1'b1};
    assign a2_idx = a0_idx + {{(INDEX_WIDTH-2){1'b0}}, 2'd2};
    assign a3_idx = a0_idx + {{(INDEX_WIDTH-2){1'b0}}, 2'd3};

    assign read_data = byte_mode
                       ? {24'd0, mem_array[a0_idx]}
                       : {mem_array[a3_idx], mem_array[a2_idx], mem_array[a1_idx], mem_array[a0_idx]};

    always_ff @(posedge clk) begin
        if (mem_write) begin
            if (byte_mode) begin
                mem_array[a0_idx] <= write_data[7:0];
            end else begin
                mem_array[a0_idx] <= write_data[7:0];
                mem_array[a1_idx] <= write_data[15:8];
                mem_array[a2_idx] <= write_data[23:16];
                mem_array[a3_idx] <= write_data[31:24];
            end
        end
    end

endmodule
