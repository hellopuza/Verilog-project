module counter
#(
	parameter   MODULUS = 10,
    parameter   NBITS   = $clog2(MODULUS)
)
(
    input   wire                clk,
    input   wire                rst,
    input   wire                incr,
    input   wire                set_data,
    input   wire    [NBITS-1:0] data,
    output  reg     [NBITS-1:0] number
);

always @(posedge clk)
begin
    if (rst)
        number <= {NBITS{1'd0}};

    else if (set_data)
        number <= data;

    else if (incr)
        number <= (number == (MODULUS - 1)) ? {NBITS{1'd0}} : number + 1'd1;
end

endmodule