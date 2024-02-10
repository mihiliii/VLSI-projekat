module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input[2:0] btn,
    input [9:0] sw,
    output [9:0] led,
    output [27:0] hex
);

    wire clk_div_out;
    clk_div #(DIVISOR) clk_div_inst(.clk(clk), .rst_n(rst_n), .out(clk_div_out));

    wire mem_we;
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_data;
    wire [DATA_WIDTH-1:0] mem_out;
    wire [ADDR_WIDTH-1:0] pc, sp;

    wire [DATA_WIDTH-1:0] cpu_out;

    assign led[4:0] = cpu_out[4:0];
    memory memory_inst(clk_div_out, mem_we, mem_addr, mem_data, mem_out);

    wire [3:0] sp_tens, sp_ones;
    wire [3:0] pc_tens, pc_ones;

    bcd bcd_sp(.in(sp), .tens(sp_tens), .ones(sp_ones));
    bcd bcd_pc(.in(pc), .tens(pc_tens), .ones(pc_ones));

    ssd ssd_sp_tens (.in(sp_tens), .out(hex[27:21]));
    ssd ssd_sp_ones (.in(sp_ones), .out(hex[20:14]));
    ssd ssd_pc_tens (.in(pc_tens), .out(hex[13:7]));
    ssd ssd_pc_ones (.in(pc_ones), .out(hex[6:0]));

    cpu #(ADDR_WIDTH, DATA_WIDTH) CPU (
        .clk(clk_div_out),
        .rst_n(sw[9]),
        .mem_in(mem_out),
        .in({{(DATA_WIDTH-4){1'b0}},{sw[3:0]}}),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_data(mem_data),
        .out(cpu_out),
        .pc(pc),
        .sp(sp)
    );
    
endmodule