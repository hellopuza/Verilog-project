module tick_timer
#(
    parameter   MODULUS = 10,
    parameter   NBITS   = $clog2(MODULUS)
)
(
    input               clk,
    input               rst,
    input               incr,
    output              tick,
    output  [NBITS-1:0] number
);

// wire [NBITS-1:0] number;

counter
#(
    .MODULUS    (MODULUS)
) counter_counter
(
    .clk        (clk),
    .rst        (rst),
    .incr       (incr),
    .number     (number),
    .set_data   (),
    .data       ()
);

assign tick = (number == MODULUS - 1);

endmodule