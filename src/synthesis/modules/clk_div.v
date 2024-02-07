module clk_div #(
    parameter DIVISOR = 50_000_000    
)(
    input clk,
    input rst_n,
    output out
);

    reg out_reg, out_next;
    integer counter_reg, counter_next;
    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= 1'b0;
            counter_reg <= 1'b0;
        end
        else begin
            out_reg <= out_next;
            counter_reg <= counter_next;
        end
    end

    always @(*) begin
        if (counter_reg == DIVISOR - 1)
            counter_next = 0;
        else
            counter_next = counter_reg + 1;
        out_next = (counter_next < DIVISOR / 2) ? 1'b1 : 1'b0;
    end


endmodule