module apple_generation
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = SIZE_X * SIZE_Y,
    parameter    FIELD_BITS = FIELD_SIZE * 2'd3,
    parameter    SBITS = $clog2(FIELD_SIZE),
    parameter    POSBITS = $clog2(FIELD_BITS)
)
(
    input   wire    [SBITS-1:0]         seed,
    input   wire    [FIELD_BITS-1:0]    field,

    output  wire    [POSBITS-1:0] apple_pos
);

/*
genvar Gi;
wire [SBITS-1:0] positions [FIELD_SIZE-1:0];
assign positions[0] = seed;

wire [POSBITS-1:0] field_positions [FIELD_SIZE-1:0];
wire [2:0] field_cells [FIELD_SIZE-1:0];

generate for (Gi = 0; Gi < FIELD_SIZE; Gi = Gi + 1)
begin: field_loop
    assign field_positions[Gi] = ((positions[Gi] >= FIELD_SIZE) ? positions[Gi] - FIELD_SIZE : positions[Gi]) * 2'd3;
    assign field_cells[Gi] = {field[field_positions[Gi] + 2'd2], field[field_positions[Gi] + 1'd1], field[field_positions[Gi]]};
end
endgenerate

generate for (Gi = 1; Gi < FIELD_SIZE; Gi = Gi + 1)
begin: positions_loop
    assign positions[Gi] = (field_cells[Gi - 1] == 3'd0) ? positions[Gi - 1] : positions[Gi - 1] + 1'd1;
end
endgenerate

assign apple_pos = field_positions[FIELD_SIZE - 1];
*/

wire [SBITS-1:0] positions [FIELD_SIZE-1:0];
assign positions[0] = positions[FIELD_SIZE - 1];

genvar Gi;
generate for (Gi = 1; Gi < FIELD_SIZE; Gi = Gi + 1)
begin: loop
    assign positions[Gi] = (field[Gi * 3 + 2:Gi * 3] == 3'd0) ? Gi : positions[Gi - 1];
end
endgenerate

assign apple_pos = positions[seed] * 2'd3;

endmodule