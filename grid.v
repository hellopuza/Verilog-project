module grid
#(
	parameter   SIZE_X         = 10,
	parameter   SIZE_Y         = 10,
	parameter   CELL_SIZE      = 10,
	parameter   LINE_THICKNESS = 1,
    parameter   XBITS          = $clog2(SIZE_X),
    parameter   YBITS          = $clog2(SIZE_Y),
    parameter   GDBITS         = SIZE_X * SIZE_Y
)
(
    input   [9:0]           pos_x,
    input   [9:0]           pos_y,
    input   [9:0]           point_pos_x,
    input   [9:0]           point_pos_y,
    input   [GDBITS-1:0]    data,

    output              point_inside,
    output              cell_is_on
);

localparam size_x = SIZE_X * CELL_SIZE;
localparam size_y = SIZE_Y * CELL_SIZE;

assign point_inside = (point_pos_x >= pos_x) & (point_pos_x < pos_x + size_x - LINE_THICKNESS) &
                      (point_pos_y >= pos_y) & (point_pos_y < pos_y + size_y - LINE_THICKNESS);

wire [9:0] bias_x = point_pos_x - pos_x;
wire [9:0] bias_y = point_pos_y - pos_y;

wire [XBITS-1:0] indexes_x [SIZE_X-1:0];
wire [YBITS-1:0] indexes_y [SIZE_Y-1:0];

assign indexes_x[0] = (bias_x >= 0) & (bias_x < CELL_SIZE - LINE_THICKNESS) ? {XBITS{1'd0}} : SIZE_X;
assign indexes_y[0] = (bias_y >= 0) & (bias_y < CELL_SIZE - LINE_THICKNESS) ? {YBITS{1'd0}} : SIZE_Y;

genvar Gi;
generate for (Gi = 1; Gi < SIZE_X; Gi = Gi + 1)
begin: loop_x
    assign indexes_x[Gi] = (bias_x >= Gi * CELL_SIZE) &
                           (bias_x < (Gi + 1) * CELL_SIZE - LINE_THICKNESS) ? Gi : indexes_x[Gi - 1];
end
endgenerate
generate for (Gi = 1; Gi < SIZE_Y; Gi = Gi + 1)
begin: loop_y
    assign indexes_y[Gi] = (bias_y >= Gi * CELL_SIZE) &
                           (bias_y < (Gi + 1) * CELL_SIZE - LINE_THICKNESS) ? Gi : indexes_y[Gi - 1];
end
endgenerate

wire [XBITS-1:0] i_x = indexes_x[SIZE_X-1];
wire [YBITS-1:0] i_y = indexes_y[SIZE_Y-1];

assign cell_is_on = (i_x == SIZE_X) | (i_y == SIZE_Y) ? 1'd0 : data[i_y * SIZE_X + i_x];

endmodule