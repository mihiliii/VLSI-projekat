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
    register register_init(.clk(clk), .rst_n(rst_n), .cl(cl), .ld(ld), .in(in), .inc(inc),
                            .dec(dec), .sr(sr), .ir(ir), .sl(sl), .il(il), .out(out));

    integer i;

    initial begin
        for (i = 0; i < 2**11; i = i + 1) begin
            {oc, a, b} = i;
            $strobe("time = %4d, oc = %b, a = %b, b = %b, f = %b", $time, oc, a, b, f);
            #10;
        end
        $stop;
        { cl, ld, in, inc, dec, sr, ir, sl, il } = 12'h000;
        clk = 1'b0;
        rst_n = 1'b0;
        #7 rst_n = 1'b1;
        #3;
        for (i = 0; i < 1000; i = i + 1) begin
            cl = $urandom % 2;
            ld = $urandom % 2;
            in = $urandom % 16;
            inc = $urandom % 2;
            dec = $urandom % 2;
            sr = $urandom % 2;
            ir = $urandom % 2;
            sl = $urandom % 2;
            il = $urandom % 2;
            #5 $strobe("time = %4d ", $time,
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
            #5;
        end
        $finish;
    end

    always #5 clk = ~clk;

endmodule;