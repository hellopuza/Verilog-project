module snake_field
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = (SIZE_X * SIZE_Y) * 2'd3,
    parameter    SBITS = $clog2(SIZE_X * SIZE_Y)
)
(
    input   wire                clk,
    input   wire                rst,
    input   wire                start,
    input   wire                step,
    input   wire    [1:0]       snake_dir,
    input   wire    [SBITS-1:0] seed,

    output  reg [FIELD_SIZE-1:0]    field
    // each cell contain 3 bits: (0) 000 - cell empty, (1) 100 - snake up, (2) 010 - snake right
    // (3) 110 - snake down, (4) 001 snake left, (5) 101 - apple
);

localparam XBITS = $clog2(SIZE_X);
localparam YBITS = $clog2(SIZE_Y);

reg [XBITS-1:0] tail_pos_x;
reg [YBITS-1:0] tail_pos_y;

reg [XBITS-1:0] head_pos_x;
reg [YBITS-1:0] head_pos_y;

reg [1:0] true_dir;

localparam POSBITS = $clog2(FIELD_SIZE);

// calc tail and head positions on field
wire [POSBITS-1:0] tail_pos = (tail_pos_y * SIZE_X + tail_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos = (head_pos_y * SIZE_X + head_pos_x) * 2'd3;

// calc positions that up/down/left/right then head on field
wire [POSBITS-1:0] head_pos_u = ((head_pos_y - 1'd1) * SIZE_X + head_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos_d = ((head_pos_y + 1'd1) * SIZE_X + head_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos_r = (head_pos_y * SIZE_X + head_pos_x + 1'd1) * 2'd3;
wire [POSBITS-1:0] head_pos_l = (head_pos_y * SIZE_X + head_pos_x - 1'd1) * 2'd3;

// output values from head's and tail's cells from field
wire [2:0] tail_cell = {field[tail_pos + 2'd2], field[tail_pos + 1'd1], field[tail_pos]};
wire [2:0] head_cell = {field[head_pos + 2'd2], field[head_pos + 1'd1], field[head_pos]};

// output values from cells that up/down/left/right from head cell
wire [2:0] head_cell_u = {field[head_pos_u + 2'd2], field[head_pos_u + 1'd1], field[head_pos_u]};
wire [2:0] head_cell_d = {field[head_pos_d + 2'd2], field[head_pos_d + 1'd1], field[head_pos_d]};
wire [2:0] head_cell_r = {field[head_pos_r + 2'd2], field[head_pos_r + 1'd1], field[head_pos_r]};
wire [2:0] head_cell_l = {field[head_pos_l + 2'd2], field[head_pos_l + 1'd1], field[head_pos_l]};

wire apple_was_eaten = ((true_dir == 2'd0) & (head_cell_u == 3'd5)) |
                       ((true_dir == 2'd1) & (head_cell_d == 3'd5)) |
                       ((true_dir == 2'd2) & (head_cell_r == 3'd5)) |
                       ((true_dir == 2'd3) & (head_cell_l == 3'd5));

wire eat_yourself = (true_dir == 2'd0) & (head_cell_u != 3'd0) & (head_cell_u != 3'd5) |
                    (true_dir == 2'd1) & (head_cell_d != 3'd0) & (head_cell_d != 3'd5) |
                    (true_dir == 2'd2) & (head_cell_r != 3'd0) & (head_cell_r != 3'd5) |
                    (true_dir == 2'd3) & (head_cell_l != 3'd0) & (head_cell_l != 3'd5);

wire bump_in_wall = ((true_dir == 2'd0) & (head_pos_y == {YBITS{1'd0}})) |
                    ((true_dir == 2'd1) & (head_pos_x == SIZE_X-1'd1))   |
                    ((true_dir == 2'd2) & (head_pos_y == SIZE_Y-1'd1))   |
                    ((true_dir == 2'd3) & (head_pos_x == {XBITS{1'd0}}));

reg alive;

integer ix;
integer iy;
integer shift_x;
integer shift_y;

always @(posedge clk)
begin
    if (rst)
    begin
        tail_pos_x <= {XBITS{1'b0}};
        tail_pos_y <= {XBITS{1'b0}};
        head_pos_x <= {XBITS{1'b0}};
        head_pos_y <= {XBITS{1'b0}};
        field <= {FIELD_SIZE{1'b0}};
        true_dir <= 2'd0;
        alive <= 1'b0;
    end
    else if (start)
    begin
        alive <= 1'b1;

        field[2:0] <= 3'd5; // apple in (0,0) - mb will be fix

        for (iy = 0; iy < SIZE_Y; iy = iy + 1'd1)
        begin
            for (ix = 0; ix < SIZE_X; ix = ix + 1'd1)
            begin
                {field[(iy * SIZE_X + ix) * 2'd3 + 2'd2],
                 field[(iy * SIZE_X + ix) * 2'd3 + 1'd1],
                 field[(iy * SIZE_X + ix) * 2'd3]} <= ((1'd0 < ix) & (ix < 4'd5) & (iy == 1'd1)) ? 3'd2 : 3'd0;
            end
        end

        tail_pos_x <= 1'd1;
        tail_pos_y <= 1'd1;
        head_pos_x <= 4'd4;
        head_pos_y <= 1'd1;
        true_dir <= 2'd1;
    end
    else if (step & alive)
    begin
        true_dir <= ((true_dir ^ snake_dir) == 2'd2) ? true_dir : snake_dir;

        // mark field after movement:
        // 1) change direction of previous head cell
        {field[head_pos + 2'd2], field[head_pos + 1'd1], field[head_pos]} <= true_dir + 1'd1;

        // 2) move set new head cell and pos
        if (true_dir == 2'd0)           // move up
        begin
            head_pos_y <= head_pos_y - 1'd1;
            {field[head_pos_u + 2'd2], field[head_pos_u + 1'd1], field[head_pos_u]} <= 3'd1;
        end
        else if (true_dir == 2'd1)      // move right
        begin
            head_pos_x <= head_pos_x + 1'd1;
            {field[head_pos_r + 2'd2], field[head_pos_r + 1'd1], field[head_pos_r]} <= 3'd2;
        end
        else if (true_dir == 2'd2)      // move down
        begin
            head_pos_y <= head_pos_y + 1'd1;
            {field[head_pos_d + 2'd2], field[head_pos_d + 1'd1], field[head_pos_d]} <= 3'd3;
        end
        else if (true_dir == 2'd3)      // move left
        begin
            head_pos_x <= head_pos_x - 1'd1;
            {field[head_pos_l + 2'd2], field[head_pos_l + 1'd1], field[head_pos_l]} <= 3'd4;
        end

        // apple was eaten?
        if (apple_was_eaten)
        begin // grow
            // set new apple
            {field[plant[seed]*2'd3+2'd2],
             field[plant[seed]*2'd3+1'd1],
             field[plant[seed]*2'd3]} <= 3'd5;
        end
        else
        begin // not grow
            // tail movement
            if (tail_cell == 3'd1)
                tail_pos_y <= tail_pos_y - 1'd1;
            else if (tail_cell == 3'd2)
                tail_pos_x <= tail_pos_x + 1'd1;
            else if (tail_cell == 3'd3)
                tail_pos_y <= tail_pos_y + 1'd1;
            else if (tail_cell == 3'd4)
                tail_pos_x <= tail_pos_x - 1'd1;

            // 3) clear previous tail cell if not grow
            {field[tail_pos + 2'd2], field[tail_pos + 1'd1], field[tail_pos]} <= 3'd0;
        end

        // still alive?
        if (eat_yourself | bump_in_wall)
            alive <= 1'b0;
    end
end

wire [SBITS*SIZE_X*SIZE_Y-1:0]	plant;

possible_apple
#(
    .SIZE_X     (SIZE_X),
    .SIZE_Y     (SIZE_Y)
) possible_apple
(
    .seed       (seed),
    .field      (field),
    .sets_seed  (plant)
);

endmodule