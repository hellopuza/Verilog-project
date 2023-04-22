module keyboard
(
    input           rst,
    input           clk,
    input           ps2_clk,
    input           ps2_dat,
    output  [7:0]   key,
    output          rdy
);

wire ps2_clk_is_low;
button button_ps2_clk_is_low
(
    .rst        (rst),
    .clk        (clk),
    .in_key     (ps2_clk),
    .out_key    (ps2_clk_is_low)
);

reg [3:0] counter_bits;
reg [10:0] data;
reg [7:0] last_code;
assign key = data[8:1];
wire data_ready = (counter_bits == 4'd10);

always @(posedge clk)
begin
    if (rst)
    begin
        data <= {11{1'd0}};
        last_code <= {8{1'd0}};
        counter_bits <= {4{1'd0}};
    end
    else
    begin
        if (ps2_clk_is_low)
        begin
            if (data_ready)
                last_code <= key;

            data[counter_bits] <= ps2_dat;
            counter_bits <= (counter_bits == 4'd10) ? {4{1'd0}} : counter_bits + 1'd1;
        end
    end
end

wire pressed = data_ready & (last_code != 8'hf0) & (key != 8'hf0);
button button_rdy
(
    .rst        (rst),
    .clk        (clk),
    .in_key     (~pressed),
    .out_key    (rdy)
);

endmodule