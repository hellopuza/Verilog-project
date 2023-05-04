`define GRID_SIZE_X 20
`define GRID_SIZE_Y 20
`define GRID_CELL_SIZE 4'd10
`define GRID_LINE_THICKNESS 4'd1
`define TICK_TIME_CLK 12000000

module snake_game (
    input           clk,
    input           key0_rst,
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

wire tick;
tick_timer
#(
    .MODULUS    (`TICK_TIME_CLK)
) tick_timer
(
    .clk    (clk),
    .rst    (rst),
    .incr   (1'd1),
    .tick   (tick)
);

wire start;
wire pause;
wire [1:0] snake_dir;
key_control key_control
(
    .clk         (clk),
    .rst         (rst),
    .key         (key),
    .key_pressed (key_pressed),
    .snake_dir   (snake_dir),
    .start       (start),
    .pause       (pause)
);

reg is_running;
always @(posedge clk)
begin
    if (rst)
        is_running <= 1'd0;
    else if (start)
        is_running <= 1'd1;
    else if (pause)
        is_running <= ~is_running;
end

localparam FIELD_SIZE = (`GRID_SIZE_X * `GRID_SIZE_Y) * 2'd3;
wire [FIELD_SIZE-1:0] field;

wire grid_point_inside;
wire [2:0] grid_cell_type;
grid
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y),
    .CELL_SIZE      (`GRID_CELL_SIZE),
    .LINE_THICKNESS (`GRID_LINE_THICKNESS),
    .CELL_BITS      (2'd3)
) grid
(
    .pos_x          ((10'd640 - `GRID_SIZE_X * `GRID_CELL_SIZE) / 2'd2),
    .pos_y          ((10'd480 - `GRID_SIZE_Y * `GRID_CELL_SIZE) / 2'd2),
    .point_pos_x    (point_pos_x),
    .point_pos_y    (point_pos_y),
    .data           (field),
    .point_inside   (grid_point_inside),
    .cell_type      (grid_cell_type)
);

colors colors
(
    .grid_point_inside  (grid_point_inside),
    .grid_cell_type     (grid_cell_type),
    .red                (vga_r),
    .green              (vga_g),
    .blue               (vga_b)
);

snake_field
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y)
) snake_field
(
    .clk        (clk),
    .rst        (rst),
    .start      (start),
    .step       (tick & is_running),
    .snake_dir  (snake_dir),
    .field      (field)
);

endmodule