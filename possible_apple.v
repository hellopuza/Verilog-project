module possible_apple
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = (SIZE_X * SIZE_Y) * 2'd3,
    parameter    SBITS = $clog2(SIZE_X * SIZE_Y)
)
(
    input   wire    [SBITS-1:0] 		seed,
    input   wire 	[FIELD_SIZE-1:0]    field,

    output  wire    [SBITS-1:0] apple_pos
);

wire [SBITS-1:0] sets_seed [SIZE_X * SIZE_Y - 1:0];
assign sets_seed[0] = SIZE_X * SIZE_Y - 1;

genvar Gi;
generate for (Gi = 1; Gi < SIZE_X * SIZE_Y; Gi = Gi + 1)
begin: loop1
    assign sets_seed[Gi] = (field[(Gi + 1) * 3 - 1:Gi * 3] == 3'd0) ? Gi : sets_seed[Gi - 1];
end
endgenerate

assign apple_pos = sets_seed[seed];

endmodule