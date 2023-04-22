module clk_div2 (
    input   wire    clk,
    input   wire    rst,
    output  reg     clk_div2
);

always @(posedge clk)
begin
    clk_div2 <= rst ? 1'd0 : ~clk_div2;
end

endmodule