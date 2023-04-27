module random
#(
    parameter   MODULUS = 10,
    parameter   NBITS   = $clog2(MODULUS)
)
(
    input               clk,
    input               rst,
    output  [NBITS-1:0] number
);

counter
#(
    .MODULUS    (MODULUS)
) counter_counter
(
    .clk        (clk),
    .rst        (rst),
    .incr       (1'd1),
    .number     (number),
    .set_data   (),
    .data       ()
);

endmodule