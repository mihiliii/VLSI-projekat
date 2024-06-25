module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem_in,
    input [DATA_WIDTH-1:0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);


    /* CPU STARTING ADDRESS POINTERS */
    localparam INIT_FIRST_INSTRUCTION = 6'd8;
    localparam INIT_STACK_POINTER     = 6'd63;

    /* MEMORY READ/WRITE BITS */
    localparam MEM_WE_READ_BIT  = 1'b0;
    localparam MEM_WE_WRITE_BIT = 1'b1;

    /* CPU INSTRUCTION BITS */
    localparam INSTRUCTION_MOV  = 4'b0000;
    localparam INSTRUCTION_IN   = 4'b0111;
    localparam INSTRUCTION_OUT  = 4'b1000;
    localparam INSTRUCTION_ADD  = 4'b0001;
    localparam INSTRUCTION_SUB  = 4'b0010;
    localparam INSTRUCTION_MUL  = 4'b0011;
    localparam INSTRUCTION_DIV  = 4'b0100;
    localparam INSTRUCTION_STOP = 4'b1111; 

    /* ALU INSTRUCTION BITS */
    localparam ALU_OPERATION_ADD = 3'b000;
    localparam ALU_OPERATION_SUB = 3'b001;
    localparam ALU_OPERATION_MUL = 3'b010;
    localparam ALU_OPERATION_DIV = 3'b011;
    localparam ALU_OPERATION_NOT = 3'b100;
    localparam ALU_OPERATION_XOR = 3'b101;
    localparam ALU_OPERATION_OR  = 3'b110;
    localparam ALU_OPERATION_AND = 3'b111;

    /* ADDRESS DIRECT/INDIRECT BIT */
    localparam ADDR_DIRECT_BIT   = 1'b0;
    localparam ADDR_INDIRECT_BIT = 1'b1;

    /* SEQ REGISTERS */
    reg [4:0] state_reg, state_next;
    reg [DATA_WIDTH-1:0] out_reg, out_next;
    assign out = out_reg;

    /* PC REGISTER */
    reg PC_ld, PC_inc;
    wire [ADDR_WIDTH-1:0] PC_out;
    assign pc = PC_out;

    /* SP REGISTER */
    reg SP_ld, SP_dec, SP_inc;
    wire [ADDR_WIDTH-1:0] SP_out;
    assign sp = SP_out;

    /* IR REGISTER */
    reg IR_HIGH_ld;
    wire [DATA_WIDTH-1:0] IR_HIGH_in;
    wire [DATA_WIDTH-1:0] IR_HIGH_out;
    assign IR_HIGH_in = mem_in;

    reg IR_LOW_ld;
    wire [DATA_WIDTH-1:0] IR_LOW_in;
    wire [DATA_WIDTH-1:0] IR_LOW_out;
    assign IR_LOW_in = mem_in;

    /*
    *    --------- --------- --------- --------- --------- --------- --------- --------- 
    *   | OP CODE | OP CODE | OP CODE | OP CODE |   D/I   |  ADDR1  |  ADDR1  |  ADDR1  |  15 - 8
    *   |   D/I   |  ADDR2  |  ADDR2  |  ADDR2  |   D/I   |  ADDR3  |  ADDR3  |  ADDR3  |  7  - 0
    *    --------- --------- --------- --------- --------- --------- --------- ---------  
    */
    wire [3:0] IR_OP_CODE;
    wire IR_ADDRESS1_DI, IR_ADDRESS2_DI, IR_ADDRESS3_DI;
    wire [2:0] IR_ADDRESS1, IR_ADDRESS2, IR_ADDRESS3;
    assign IR_OP_CODE     = IR_HIGH_out[15:12];
    assign IR_ADDRESS1_DI = IR_HIGH_out[11];
    assign IR_ADDRESS1    = IR_HIGH_out[10:8];
    assign IR_ADDRESS2_DI = IR_HIGH_out[7];
    assign IR_ADDRESS2    = IR_HIGH_out[6:4];
    assign IR_ADDRESS3_DI = IR_HIGH_out[3];
    assign IR_ADDRESS3    = IR_HIGH_out[2:0];

    /* ACCUMULATOR */
    reg A_ld;
    reg [DATA_WIDTH-1:0] A_in;
    wire [DATA_WIDTH-1:0] A_out;

    /* ALU UNIT */
    reg [3:0] ALU_oc;
    wire [DATA_WIDTH-1:0] ALU_a;
    wire [DATA_WIDTH-1:0] ALU_b;
    wire [DATA_WIDTH-1:0] ALU_out;
    assign ALU_a = A_out;
    assign ALU_b = mem_in;

    register #(.DATA_WIDTH(6)) PC(
        .clk(clk), .rst_n(rst_n), .out(PC_out), .ld(PC_ld), .in(INIT_FIRST_INSTRUCTION),
        .inc(PC_inc),
        .cl(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(.DATA_WIDTH(6)) SP(
        .clk(clk), .rst_n(rst_n), .out(SP_out), .ld(SP_ld), .in(INIT_STACK_POINTER), .dec(SP_dec),
        .inc(SP_inc),
        .cl(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(.DATA_WIDTH(16)) IR_HIGH(
        .clk(clk), .rst_n(rst_n), .in(IR_HIGH_in), .ld(IR_HIGH_ld), .out(IR_HIGH_out), 
        .cl(1'b0), .inc(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(.DATA_WIDTH(16)) IR_LOW(
        .clk(clk), .rst_n(rst_n), .in(IR_LOW_in), .ld(IR_LOW_ld), .out(IR_LOW_out),
        .cl(1'b0), .inc(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    register #(.DATA_WIDTH(16)) A(.clk(clk), .rst_n(rst_n), .out(A_out), .ld(A_ld), .in(A_in),
        .cl(1'b0), .inc(1'b0), .dec(1'b0), .sr(1'b0), .ir(1'b0), .sl(1'b0), .il(1'b0)
    );
    alu #(.DATA_WIDTH(16)) ALU(.oc(ALU_oc), .a(ALU_a), .b(ALU_b), .f(ALU_out));

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= 0;
            out_reg <= 0;
        end 
        else begin
            state_reg <= state_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        state_next = state_reg + 1'b1;
        out_next = out_reg;
        PC_ld = 1'b0;
        PC_inc = 1'b0;
        SP_ld = 1'b0;
        SP_dec = 1'b0;
        SP_inc = 1'b0;
        IR_HIGH_ld = 1'b0;
        IR_LOW_ld = 1'b0;
        A_ld = 1'b0;
        A_in = ALU_out;
        ALU_oc = 4'h0;
        mem_we = 1'bz;
        mem_addr = {(ADDR_WIDTH-1){1'bz}};
        mem_data = {(DATA_WIDTH-1){1'bz}};
        
        case (state_reg)
            5'd0: begin // INIT
                PC_ld = 1'b1;
                SP_ld = 1'b1;
            end
            5'd1: begin // FETCH0;
                mem_we = MEM_WE_READ_BIT;
                mem_addr = PC_out;
            end
            5'd2: begin // FETCH1;
                IR_HIGH_ld = 1'b1;
                PC_inc = 1'b1;
            end
            5'd3: begin // DECODE0;
                case (IR_OP_CODE)
                    INSTRUCTION_DIV:
                        state_next = 5'd1; // FETCH 
                    INSTRUCTION_IN:
                        state_next = 5'd6; // IN
                    INSTRUCTION_OUT:
                        state_next = 5'd9; // OUT
                    INSTRUCTION_ADD:
                        state_next = 5'd12; // ALU
                    INSTRUCTION_SUB:
                        state_next = 5'd12; // ALU
                    INSTRUCTION_MUL:
                        state_next = 5'd12; // ALU
                    INSTRUCTION_STOP:
                        state_next = 5'd18; // STOP
                    INSTRUCTION_MOV: 
                        if ({IR_ADDRESS3_DI, IR_ADDRESS3} == 4'b0000)
                            state_next = 5'd25; // MOV
                        else if ({IR_ADDRESS3_DI, IR_ADDRESS3} == 4'b1000)
                            state_next = 5'd4;
                    default: // ERROR
                        state_next = 5'd31;
                endcase
            end
            5'd4: begin // FETCH2
                mem_we = MEM_WE_READ_BIT;
                mem_addr = PC_out; 
            end
            5'd5: begin // FETCH3
                IR_LOW_ld = 1'b1;
                PC_inc = 1'b1;
                state_next = 5'd29;
            end
            5'd6: begin // IN0
                mem_we = MEM_WE_READ_BIT;
                mem_addr = IR_ADDRESS1;
                if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT) begin
                    state_next = 5'd8; // IN2
                end
            end
            5'd7: begin // IN1
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd8: begin // IN2
                mem_we = MEM_WE_WRITE_BIT;
                mem_addr = mem_in;
                mem_data = in;
                state_next = 5'd1; // FETCH0
            end
            5'd9: begin // OUT0
                mem_we = MEM_WE_READ_BIT;
                mem_addr = IR_ADDRESS1;
                if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT) begin
                    state_next = 5'd11; // OUT2
                end
            end
            5'd10: begin // OUT1
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd11: begin // OUT2
                out_next = mem_in;
                state_next = 5'd1; // FETCH0
            end
            5'd12: begin // ALU0
                mem_we = MEM_WE_READ_BIT;
                mem_addr = IR_ADDRESS2;
                if (IR_ADDRESS2_DI == ADDR_DIRECT_BIT) begin
                    state_next = 5'd14;    
                end
            end
            5'd13: begin // ALU1
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd14: begin // ALU2
                A_in = mem_in;
                A_ld = 1'b1;
                mem_we = MEM_WE_READ_BIT;
                mem_addr = IR_ADDRESS3;
                if (IR_ADDRESS3_DI == ADDR_DIRECT_BIT) begin
                    state_next = 5'd16;    
                end
            end
            5'd15: begin // ALU3
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd16: begin // ALU4
                case (IR_OP_CODE)
                    INSTRUCTION_ADD:
                        ALU_oc = ALU_OPERATION_ADD;
                    INSTRUCTION_SUB:
                        ALU_oc = ALU_OPERATION_SUB;
                    INSTRUCTION_MUL:
                        ALU_oc = ALU_OPERATION_MUL;
                    default:
                        ALU_oc = ALU_OPERATION_ADD;
                endcase;
                A_in = ALU_out;
                A_ld = 1'b1;
                if (IR_ADDRESS1_DI == ADDR_INDIRECT_BIT) begin
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS1;
                end
            end
            5'd17: begin // ALU5
                mem_we = MEM_WE_WRITE_BIT;
                mem_data = A_out;
                if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT)
                    mem_addr = IR_ADDRESS1;
                else if (IR_ADDRESS1_DI == ADDR_INDIRECT_BIT)
                    mem_addr = mem_in;
                state_next = 5'd1;
            end
            5'd18: begin // STOP0
                if (IR_ADDRESS1 != 3'h0) begin
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS1;
                    if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT) 
                        state_next = 5'd20;
                end 
                else 
                    state_next = 5'd20;
            end
            5'd19: begin // STOP1
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd20: begin // STOP2
                if (IR_ADDRESS1 != 3'h0)
                    out_next = mem_in;
                if (IR_ADDRESS2 != 3'h0) begin
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS2;
                    if (IR_ADDRESS2_DI == ADDR_DIRECT_BIT) 
                        state_next = 5'd22;
                end
                else
                    state_next = 5'd22;
            end 
            5'd21: begin // STOP3
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd22: begin // STOP4
                if (IR_ADDRESS2 != 3'h0)
                    out_next = mem_in;
                if (IR_ADDRESS3 != 3'h0) begin
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS3;
                    if (IR_ADDRESS3_DI == ADDR_DIRECT_BIT) 
                        state_next = 5'd24;
                end
                else
                    state_next = 5'd31;
            end 
            5'd23: begin // STOP5
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd24: begin // STOP6
                out_next = mem_in;
                state_next = 5'd31;
            end
            5'd25: begin // MOV0
                mem_we = MEM_WE_READ_BIT;
                mem_addr = IR_ADDRESS2;
                if (IR_ADDRESS2_DI == ADDR_DIRECT_BIT)
                    state_next = 5'd27;
            end
            5'd26: begin // MOV1
                mem_we = MEM_WE_READ_BIT;
                mem_addr = mem_in;
            end
            5'd27: begin // MOV2
                if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT) begin
                    mem_we = MEM_WE_WRITE_BIT;
                    mem_addr = IR_ADDRESS1;
                    mem_data = mem_in;
                    state_next = 5'd1;
                end else begin
                    A_in = mem_in;
                    A_ld = 1'b1;
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS1;
                end
            end
            5'd28: begin // MOV3
                mem_we = MEM_WE_WRITE_BIT;
                mem_addr = mem_in;
                mem_data = A_out;
                state_next = 1'b1;
            end
            5'd29: begin // MOV 1000 1
                if (IR_ADDRESS1_DI == ADDR_DIRECT_BIT) begin
                    mem_we = MEM_WE_WRITE_BIT;
                    mem_addr = IR_ADDRESS1;
                    mem_data = IR_LOW_out;
                    state_next = 5'd1;
                end else begin
                    mem_we = MEM_WE_READ_BIT;
                    mem_addr = IR_ADDRESS1;
                end
            end
            5'd30: begin // MOV 1000 2
                mem_we = MEM_WE_WRITE_BIT;
                mem_addr = mem_in;
                mem_data = IR_LOW_out;
                state_next = 5'd1;
            end
            default:
                state_next <= state_reg;
        endcase
    end

endmodule