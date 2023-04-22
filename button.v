module button
(
    input   rst,
    input   clk,
    input   in_key,
    output  out_key
);

reg [1:0] but;
assign out_key = but[1] & ~but[0];

always @(posedge clk)
begin
    if (rst)
        but <= 2'h0;
    else
    begin
        but[0] <= in_key;
        but[1] <= but[0];
    end
end

endmodule