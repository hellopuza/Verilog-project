module possible_apple
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = (SIZE_X * SIZE_Y) * 2'd3,
    parameter    SBITS = $clog2(SIZE_X * SIZE_Y)
)
(
    input	wire    [SBITS-1:0] 		seed,
    input	wire 	[FIELD_SIZE-1:0]    field,

	output	wire	[SBITS*SIZE_X*SIZE_Y-1:0]	sets_seed
);

assign sets_seed[SBITS*SIZE_X*SIZE_Y-1:(SBITS-1)*SIZE_X*SIZE_Y] = SIZE_X*SIZE_Y-1;

genvar Gi;
generate for (Gi = 1; Gi < SIZE_X*SIZE_Y; Gi = Gi + 1)
	begin: loop1
		assign sets_seed[(Gi+1)*SBITS-1:Gi*SBITS] = (field[(Gi+1)*3-1:Gi*3] == 3'd0) ? Gi : sets_seed[(Gi)*SBITS-1:(Gi-1)*SBITS];
	end
endgenerate

endmodule