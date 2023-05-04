module grid
#(
    parameter   SIZE_X         = 8'd10,
    parameter   SIZE_Y         = 8'd10,
    parameter   CELL_SIZE      = 4'd10,
    parameter   LINE_THICKNESS = 4'd1,
    parameter   CELL_BITS      = 4'd1,
    parameter   XBITS          = $clog2(SIZE_X),
    parameter   YBITS          = $clog2(SIZE_Y),
    parameter   GDBITS         = CELL_BITS * SIZE_X * SIZE_Y
)
(
    input   [9:0]           pos_x,
    input   [9:0]           pos_y,
    input   [9:0]           point_pos_x,
    input   [9:0]           point_pos_y,
    input   [GDBITS-1:0]    data,

    output  [XBITS-1:0]     cell_pos_x,
    output  [YBITS-1:0]     cell_pos_y,
    output                  point_inside,
    output  [CELL_BITS-1:0] cell_type
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

assign cell_pos_x = indexes_x[SIZE_X-1];
assign cell_pos_y = indexes_y[SIZE_Y-1];

localparam INDBITS = $clog2(GDBITS);
wire [INDBITS-1:0] index = (cell_pos_x == SIZE_X) | (cell_pos_y == SIZE_Y) ? SIZE_Y * SIZE_X * CELL_BITS :
                           (cell_pos_y * SIZE_X + cell_pos_x) * CELL_BITS;

generate for (Gi = 0; Gi < CELL_BITS; Gi = Gi + 1)
begin: loop_cell
    assign cell_type[Gi] = (index == SIZE_Y * SIZE_X * CELL_BITS) ? {CELL_BITS{1'b0}} : data[index + Gi];
end
endgenerate

endmodule