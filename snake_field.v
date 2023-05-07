module snake_field
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = (SIZE_X * SIZE_Y) * 2'd3
)
(
    input   wire                    clk,
    input   wire                    rst,
    input   wire                    start,
    input   wire [$clog2(SIZE_X*SIZE_Y)-1:0]seed,
    input   wire                    step,
    input   wire    [1:0]           snake_dir,

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

// gen seed for apple
// wire [POSBITS-1:0] seed = tail_pos + head_pos;

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

        // head movement
        if (true_dir == 2'd0)           // move up
        begin
            head_pos_y <= head_pos_y - 1'd1;
            {field[head_pos_u + 2'd2], field[head_pos_u + 1'd1], field[head_pos_u]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd1)      // move right
        begin
            head_pos_x <= head_pos_x + 1'd1;
            {field[head_pos_r + 2'd2], field[head_pos_r + 1'd1], field[head_pos_r]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd2)      // move down
        begin
            head_pos_y <= head_pos_y + 1'd1;
            {field[head_pos_d + 2'd2], field[head_pos_d + 1'd1], field[head_pos_d]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd3)      // move left
        begin
            head_pos_x <= head_pos_x - 1'd1;
            {field[head_pos_l + 2'd2], field[head_pos_l + 1'd1], field[head_pos_l]} <= true_dir + 1'd1;
        end

        // apple was eaten?
        if ((true_dir == 2'd0 & {field[head_pos_u+2'd2],field[head_pos_u+1'd1],field[head_pos_u]} == 3'd5) | 
            (true_dir == 2'd1 & {field[head_pos_r+2'd2],field[head_pos_r+1'd1],field[head_pos_r]} == 3'd5) | 
            (true_dir == 2'd2 & {field[head_pos_d+2'd2],field[head_pos_d+1'd1],field[head_pos_d]} == 3'd5) | 
            (true_dir == 2'd3 & {field[head_pos_l+2'd2],field[head_pos_l+1'd1],field[head_pos_l]} == 3'd5))
        begin // grow
            // search free cell starting at seed
            shift_x = -1;
            shift_y = -1;
            for (iy = 0; iy < SIZE_Y; iy = iy + 1'd1)
            begin
                for (ix = 0; ix < SIZE_X; ix = ix + 1'd1)
                begin
                    if (shift_x == -1 & shift_y == -1) 
                    begin
                        if (seed+ix+iy*SIZE_X < FIELD_SIZE)
                        begin
                            if ({field[(seed+ix+iy*SIZE_X)*2'd3+2'd2],
                                 field[(seed+ix+iy*SIZE_X)*2'd3+1'd1],
                                 field[(seed+ix+iy*SIZE_X)*2'd3]} == 3'd0)
                            begin
                                shift_x = ix;
                                shift_y = iy;
                            end
                        end
                        else
                        begin
                            if ({field[(seed+ix+iy*SIZE_X)*2'd3+2'd2-FIELD_SIZE],
                                 field[(seed+ix+iy*SIZE_X)*2'd3+1'd1-FIELD_SIZE],
                                 field[(seed+ix+iy*SIZE_X)*2'd3-FIELD_SIZE]} == 3'd0)
                            begin
                                shift_x = SIZE_X - ix;
                                shift_y = SIZE_Y - iy;
                            end
                        end
                    end
                end
            end
            // set new apple
            {field[(seed+shift_x+shift_y*SIZE_X)*2'd3+2'd2],
             field[(seed+shift_x+shift_y*SIZE_X)*2'd3+1'd1],
             field[(seed+shift_x+shift_y*SIZE_X)*2'd3]} <= 3'd5;
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
        end

        // mark field after movement:
        // 1) change direction of previous head cell
        {field[head_pos + 2'd2], field[head_pos + 1'd1], field[head_pos]} <= true_dir + 1'd1; 

        // 2) clear previous tail cell
        {field[tail_pos + 2'd2], field[tail_pos + 1'd1], field[tail_pos]} <= 3'd0; 

        // still alive?
        if ((true_dir == 2'd0 & ({field[head_pos_u+2'd2],field[head_pos_u+1'd1],field[head_pos_u]} != 3'd0   | 
                                 {field[head_pos_u+2'd2],field[head_pos_u+1'd1],field[head_pos_u]} != 3'd5)) | 
            (true_dir == 2'd1 & ({field[head_pos_r+2'd2],field[head_pos_r+1'd1],field[head_pos_r]} != 3'd0   | 
                                 {field[head_pos_r+2'd2],field[head_pos_r+1'd1],field[head_pos_r]} != 3'd5)) | 
            (true_dir == 2'd2 & ({field[head_pos_d+2'd2],field[head_pos_d+1'd1],field[head_pos_d]} != 3'd0   | 
                                 {field[head_pos_d+2'd2],field[head_pos_d+1'd1],field[head_pos_d]} != 3'd5)) | 
            (true_dir == 2'd3 & ({field[head_pos_l+2'd2],field[head_pos_l+1'd1],field[head_pos_l]} != 3'd0   | 
                                 {field[head_pos_l+2'd2],field[head_pos_l+1'd1],field[head_pos_l]} != 3'd5)))
            alive <= 1'b0; // eat yourself

        if ((true_dir == 2'd0 & head_pos_y == 0) | 
            (true_dir == 2'd1 & head_pos_x == SIZE_X-1) | 
            (true_dir == 2'd2 & head_pos_y == SIZE_Y-1) | 
            (true_dir == 2'd3 & head_pos_x == 0))
            alive <= 1'b0; // bump in wall
    end
end
endmodule