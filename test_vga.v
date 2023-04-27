`include "keys.v"

`define GRID_SIZE_X 40
`define GRID_SIZE_Y 30
`define GRID_CELL_SIZE 10
`define GRID_LINE_THICKNESS 1

module test_vga (
    input           clk,
    input           key0_rst,
    input           key1_set,
    input           key2_rnd,
    input           key3_rnd_cell,
    input           ps2_clk,
    input           ps2_dat,

    output  [7:0]   vga_r,
    output  [7:0]   vga_g,
    output  [7:0]   vga_b,
    output          vga_clk,
    output          vga_blank_n,
    output          vga_sync_n,
    output          vga_hs,
    output          vga_vs
);

wire rst = ~key0_rst;

wire set;
button button_set
(
    .rst        (rst),
    .clk        (clk),
    .in_key     (key1_set),
    .out_key    (set)
);

wire rnd;
button button_rnd
(
    .rst        (rst),
    .clk        (clk),
    .in_key     (key2_rnd),
    .out_key    (rnd)
);

wire rnd_cell;
button button_rnd_cell
(
    .rst        (rst),
    .clk        (clk),
    .in_key     (key3_rnd_cell),
    .out_key    (rnd_cell)
);

wire [9:0] point_pos_x;
wire [9:0] point_pos_y;

vga vga
(
    .clk            (clk),
    .rst            (rst),
    .vga_clk        (vga_clk),
    .h_sync         (vga_hs),
    .v_sync         (vga_vs),
    .blank_n        (vga_blank_n),
    .sync_n         (vga_sync_n),
    .point_pos_x    (point_pos_x),
    .point_pos_y    (point_pos_y)
);

wire point_inside;
wire cell_is_on;

localparam gd_bits = `GRID_SIZE_X * `GRID_SIZE_Y;
reg [gd_bits-1:0] grid_data;
grid
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y),
    .CELL_SIZE      (`GRID_CELL_SIZE),
    .LINE_THICKNESS (`GRID_LINE_THICKNESS)
) grid
(
    .pos_x          ((640 - `GRID_SIZE_X * `GRID_CELL_SIZE) / 2),
    .pos_y          ((480 - `GRID_SIZE_Y * `GRID_CELL_SIZE) / 2),
    .point_pos_x    (point_pos_x),
    .point_pos_y    (point_pos_y),
    .data           (grid_data),
    .point_inside   (point_inside),
    .cell_is_on     (cell_is_on)
);

wire [7:0] key;
wire key_pressed;
keyboard keyboard
(
    .rst        (rst),
    .clk        (clk),
    .ps2_clk    (ps2_clk),
    .ps2_dat    (ps2_dat),
    .key        (key),
    .rdy        (key_pressed)
);

localparam gsx_bits = $clog2(`GRID_SIZE_X);
wire [gsx_bits-1:0] rnd_x_pos;
random
#(
    .MODULUS    (`GRID_SIZE_X)
) random_rnd_x_pos
(
    .clk    (clk),
    .rst    (rst),
    .number (rnd_x_pos)
);

localparam gsy_bits = $clog2(`GRID_SIZE_Y);
wire [gsy_bits-1:0] rnd_y_pos;
random
#(
    .MODULUS    (`GRID_SIZE_Y)
) random_rnd_y_pos
(
    .clk    (clk),
    .rst    (rst),
    .number (rnd_y_pos)
);

assign {vga_r, vga_g, vga_b} = point_inside & cell_is_on ? {8'hF0, 8'h50, 8'hA0} :
                               point_inside ? {8'h00, 8'h00, 8'h00} :
                               {8'h20, 8'h60, 8'h40};

integer ix, iy;

always @(posedge clk)
begin
    if (rst)
        grid_data <= {gd_bits{1'd0}};

    else if (set)
        grid_data <= {gd_bits{1'd1}};

    else if (rnd_cell)
    begin
        for (ix = 0; ix < `GRID_SIZE_X; ix = ix + 1)
            for (iy = 0; iy < `GRID_SIZE_Y; iy = iy + 1)
                grid_data[iy * `GRID_SIZE_X + ix] <= (rnd_x_pos == ix) & (rnd_y_pos == iy);
    end

    else if (key_pressed)
    begin
        if (key == `KEY_LSHIFT)
            grid_data <= grid_data << 1;

        else if (key == `KEY_RSHIFT)
            grid_data <= grid_data >> 1;
    end
end

endmodule