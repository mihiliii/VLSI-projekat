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

    // dummy registers
    wire [15:0] w_dummy16;
    wire [31:0] w_dummy32;

    // init parameters
    localparam INIT_FIRST_INSTRUCTION = 6'd8;
    localparam INIT_STACK_POINTER     = 6'd63;

    
    localparam MEM_WE_READ  = 1'b0;
    localparam MEM_WE_WRITE = 1'b1;

    reg r_mem_we;
    reg [ADDR_WIDTH-1:0] r_mem_addr;
    reg [DATA_WIDTH-1:0] r_mem_data;
    assign mem_we   = r_mem_we;
    assign mem_addr = r_mem_addr;
    assign mem_data = r_mem_data;

    reg [DATA_WIDTH-1:0] r_out;
    assign out = r_out;

    /**
    *
    */

    reg [3:0] phase, phase_next;

    reg PC_ld, PC_inc;
    wire [ADDR_WIDTH-1:0] PC_out;
    assign pc = PC_out;

    reg SP_ld, SP_dec;
    wire [ADDR_WIDTH-1:0] SP_out;
    assign sp = SP_out;

    reg IR_ld;
    reg [DATA_WIDTH-1:0] IR_in, IR_out;

    reg A_ld;
    reg [DATA_WIDTH-1:0] A_in;
    wire [DATA_WIDTH-1:0] A_out;

    /**
    *
    */ 

    localparam INSTRUCTION_MOV  = 4'b0000;
    localparam INSTRUCTION_IN   = 4'b0111;
    localparam INSTRUCTION_OUT  = 4'b1000;
    localparam INSTRUCTION_ADD  = 4'b0001;
    localparam INSTRUCTION_SUB  = 4'b0010;
    localparam INSTRUCTION_MUL  = 4'b0011;
    localparam INSTRUCTION_DIV  = 4'b0100;
    localparam INSTRUCTION_STOP = 4'b1111; 

    wire [3:0] op_code, addr1, addr2, addr3;
    assign op_code = IR_out[15:12];
    assign addr1 = IR_out[11:8];
    assign addr2 = IR_out[7:4];
    assign addr3 = IR_out[3:0];

    reg [3:0] alu_oc;
    wire [DATA_WIDTH-1:0] alu_a;
    wire [DATA_WIDTH-1:0] alu_b;
    wire [DATA_WIDTH-1:0] alu_out;
    assign alu_a = A_out;
    assign alu_b = mem_in;
    assign alu_out = A_in;

    register #(6) PC(
        .clk(clk), .rst_n(rst_n), .out(PC_out), .ld(PC_ld), .in(INIT_FIRST_INSTRUCTION),
        .inc(PC_inc),
        .cl(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(6) SP(
        .clk(clk), .rst_n(rst_n), .out(SP_out), .ld(SP_ld), .in(INIT_STACK_POINTER), .dec(SP_dec),
        .cl(1'b0), .inc(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(16) IR(
        .clk(clk), .rst_n(rst_n), .in(IR_in), .ld(IR_ld),
        .out(w_dummy16), .cl(1'b0), .inc(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(16) A(.clk(clk), .rst_n(rst_n), .out(A_out), .ld(A_ld), .in(A_in),
        .cl(1'b0), .inc(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    alu #(16) ALU(.oc(alu_oc), .a(alu_a), .b(alu_b), .f(alu_out));

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            
        end 
        else begin
            phase <= phase_next;
        end
    end

    always @(*) begin
        phase_next = phase + 1'b1;
        IR_ld = 1'b0;
        PC_inc = 1'b0;
        A_ld = 1'b0;
        case (phase)
            0: begin // fetch0
                r_mem_we = MEM_WE_READ;
                r_mem_addr = PC_out;
            end
            1: begin // fetch1
                IR_in = mem_in;
                IR_ld = 1'b1;
                PC_inc = 1'b1;
            end
            2: begin // decode
                case (op_code)
                    INSTRUCTION_IN:
                        phase_next = 3;
                    INSTRUCTION_OUT:
                        phase_next = 6;
                    INSTRUCTION_ADD:
                        phase_next = 9;
                endcase
            end
            3: begin // in0
                r_mem_addr = addr1[2:0];
                if (addr1[3]) begin
                    r_mem_we = MEM_WE_READ;
                end
                else begin
                    r_mem_we = MEM_WE_WRITE;
                    r_mem_data = in;
                    phase_next = 0;
                end
            end
            4: begin // in1
                A_in = mem_in;
                A_ld = 1'b1;
            end
            5: begin // in2
                r_mem_we = MEM_WE_WRITE;
                r_mem_addr = A_out;
                r_mem_data = in;
                phase_next = 0;
            end
            6: begin // out0
                r_mem_we = MEM_WE_READ;
                r_mem_addr = addr1[2:0];
                if (addr1[3] == 0) begin
                    phase_next = 9;
                end
            end
            7: begin // out1
                A_in = mem_in;
                A_ld = 1'b1;
            end
            8: begin // out2
                r_mem_we = MEM_WE_READ;
                r_mem_addr = A_out;
            end
            9: begin // out3
                r_out = mem_in;
                phase_next = 0;
            end
            10: begin // add0
                r_mem_we = MEM_WE_READ;
                r_mem_addr = addr2[2:0];
                // if (addr2[3] == 1) begin
                //     phase_next = ..;
                // end
            end
            11: begin // add1
                A_in = mem_in;
                A_ld = 1'b1;
                r_mem_we = MEM_WE_READ;
                r_mem_addr = addr3[2:0];
                // if (addr3[3] == 1) begin
                //     phase_next = ...;
                // end
            end
            12: begin // add2
                A_in = alu_out;
                A_ld = 1'b1;
                // if (addr3[3] == 1) begin
                //     phase_next = ...;
                // end
            end
        endcase
    end

endmodule