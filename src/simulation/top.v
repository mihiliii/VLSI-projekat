module top;

    reg [2:0] oc;
    reg [3:0] a, b;
    wire [3:0] f;

    reg clk, rst_n;
    reg cl, ld, inc, dec, sr, sl;
    reg ir, il;
    reg [3:0] in;
    wire [3:0] out;

    alu alu_init(.oc(oc), .a(a), .b(b), .f(f));
    register register_init(
        .clk(clk), .rst_n(rst_n), .cl(cl), .ld(ld), .in(in), .inc(inc), .dec(dec), .sr(sr),
        .ir(ir), .sl(sl), .il(il), .out(out)
    );

    integer i;

    always #5 clk = ~clk;

    initial begin
        $monitor("time = %4d oc = %b a = %b b = %b f = %b", $time, oc, a, b, f);
        for (i = 0; i < 2 ** 11; i = i + 1) begin
            {oc, a, b} = i;
            #10;
        end
        $stop;
        clk = 1'b0;
        #2 rst_n = 1'b0;
        #3 rst_n = 1'b1;
        for (i = 0; i < 1000; i = i + 1) begin
            {cl, ld, in, inc, dec, sr, ir, sl, il} = $urandom % (2 ** 12);
            #10;
        end
        $finish;
    end

    always @(out) begin
        $strobe("time = %4d ", $time,
                    "rst_n = %b ", rst_n,
                    "cl = %b ", cl,
                    "ld = %b ", ld, 
                    "in = %b ", in, 
                    "inc = %b ", inc,
                    "dec = %b ", dec, 
                    "sr = %b ", sr,
                    "ir = %b ", ir,
                    "sl = %b ", sl,
                    "il = %b ", il,
                    "out = %b", out
        );
    end


endmodule