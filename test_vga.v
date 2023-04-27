`define GRID_SIZE_X 40
`define GRID_SIZE_Y 30
`define GRID_CELL_SIZE 10
`define GRID_LINE_THICKNESS 1
`define TICK_TIME_CLK 12000000

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

wire [1:0] beh;
wire [1:0] snake_dir;
key_control key_control
(
    .clk         (clk),
    .rst         (rst),
    .start       (beh[0]),
    .key         (key),
    .key_pressed (key_pressed),
    .snake_dir   (snake_dir)
);

localparam SNAKE_SIZE = 8 * (`GRID_SIZE_X * `GRID_SIZE_Y) * 2;

wire [15:0] snake_len;
wire [1:0] true_key;
wire [SNAKE_SIZE-1:0] snake_xy;
wire snake2field;
snake_calculate
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y)
) snake_calculate
(
    .clk      (clk),
    .rst      (rst),
    .step     (tick),
    .start    (beh[0]),
    .grow     (beh[1]),
    .lengh    (snake_len),
    .true_key (true_key),
    .key      (snake_dir),
    .snake_xy (snake_xy),
    .snake2field (snake2field)
);

localparam FIELD_SIZE = (`GRID_SIZE_X * `GRID_SIZE_Y) * 2;

wire field2apple;
wire [15:0]	empty_cells;
wire [FIELD_SIZE-1:0] field;
field_calculate
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y)
) field_calculate
(
    .clk    (clk),
    .rst    (rst),
    .step   (snake2field),
    .lengh      (snake_len),
    .snake_xy   (snake_xy),
    .empty_cells (empty_cells),
    .field (field),
    .dead    (beh[0]),
    .grow     (beh[1])
);

game_behavior
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y)
) game_behavior
(
    .clk    (clk),
    .rst    (rst),
    .check   (field2apple),
    .key    (true_key),
    .snake_xy   (snake_xy),
    .field (field),
    .field2apple (field2apple)
);

wire [$clog2(`GRID_SIZE_X)-1:0] cell_pos_x;
wire [$clog2(`GRID_SIZE_Y)-1:0] cell_pos_y;
wire grid_point_inside;
wire [1:0] grid_cell_type;
grid
#(
    .SIZE_X         (`GRID_SIZE_X),
    .SIZE_Y         (`GRID_SIZE_Y),
    .CELL_SIZE      (`GRID_CELL_SIZE),
    .LINE_THICKNESS (`GRID_LINE_THICKNESS),
    .CELL_BITS      (2)
) grid
(
    .pos_x          ((640 - `GRID_SIZE_X * `GRID_CELL_SIZE) / 2),
    .pos_y          ((480 - `GRID_SIZE_Y * `GRID_CELL_SIZE) / 2),
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

endmodule