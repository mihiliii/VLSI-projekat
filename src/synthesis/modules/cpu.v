module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output mem_we,
    output [ADDR_WIDTH-1:0] mem_addr,
    output [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);

    reg r_dummy1;
    reg [5:0] r_dummy6;
    reg [15:0] r_dummy16;
    reg [31:0] r_dummy32;
    wire [15:0] w_dummy16;
    wire [31:0] w_dummy32;

    localparam ADDR_FIRST_INSTRUCTION = 6'd8;
    localparam ADDR_STACK_POINTER     = 6'd63;

    localparam MEM_READ  = 1'b0;
    localparam MEM_WRITE = 1'b1;

    reg r_mem_we, r_mem_addr;
    assign mem_we   = r_mem_we;
    assign mem_addr = r_mem_addr;


    integer phase;
    localparam FETCH = 0;
    localparam DECODE = 1;

    reg PC_ld, PC_inc;
    wire [ADDR_WIDTH-1:0] PC_out;
    assign pc = PC_out;

    reg SP_ld, SP_dec;
    wire [ADDR_WIDTH-1:0] SP_out;
    assign sp = SP_out;

    reg IR_ld;
    reg [DATA_WIDTH-1:0] IR_in, IR_out;

    /**
    *
    */ 

    localparam MOV  = 4'b0000;
    localparam IN   = 4'b0111;
    localparam OUT  = 4'b1000;
    localparam ADD  = 4'b0001;
    localparam SUB  = 4'b0010;
    localparam MUL  = 4'b0011;
    localparam DIV  = 4'b0100;
    localparam STOP = 4'b1111; 

    wire [3:0] op_code, addr1, addr2, addr3;
    assign op_code = IR_out[15:12];
    assign addr1 = IR_out[11:8];
    assign addr2 = IR_out[7:4];
    assign addr3 = IR_out[3:0];


    register #(6) PC(
        .clk(clk), .rst_n(rst_n), .out(PC_out), .ld(PC_ld), .in(ADDR_FIRST_INSTRUCTION), .inc(PC_inc),
        .cl(r_dummy1), .dec(r_dummy1), .sr(r_dummy1), .ir(r_dummy1), .sl(r_dummy1), .il(r_dummy1)
    );
    register #(6) SP(
        .clk(clk), .rst_n(rst_n), .out(SP_out), .ld(SP_ld), .in(ADDR_STACK_POINTER), .dec(SP_dec),
        .cl(r_dummy1), .inc(r_dummy1), .sr(r_dummy1), .ir(r_dummy1), .sl(r_dummy1), .il(r_dummy1)
    );
    register #(16) IR(
        .clk(clk), .rst_n(rst_n), .in(IR_in), .ld(IR_ld),
        .out(w_dummy16), .cl(r_dummy1), .inc(r_dummy1), .dec(r_dummy1), .sr(r_dummy1),
        .ir(r_dummy1), .sl(r_dummy1), .il(r_dummy1)
    );
    register #(16) A(.clk(clk), .rst_n(rst_n), 
        .out(w_dummy16), .cl(r_dummy1), .ld(r_dummy1), .in(r_dummy16), .inc(r_dummy1), .dec(r_dummy1), .sr(r_dummy1),
        .ir(r_dummy1), .sl(r_dummy1), .il(r_dummy1)
    );

    always @(posedge clk, negedge rst_n) begin
        
    end

    always @(*) begin
        case (phase)
            FETCH: begin
                r_mem_we = MEM_READ;
                r_mem_addr = PC_out;
                IR_in = mem_in;
                IR_ld = 1'b1;
            end
            DECODE: begin
                
            end
        endcase
    end



endmodule