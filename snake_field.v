module snake_field
#(
    parameter    SIZE_X = 8'd10,
    parameter    SIZE_Y = 8'd10,
    parameter    FIELD_SIZE = (SIZE_X * SIZE_Y) * 2'd3
)
(
    input   wire            clk,
    input   wire            rst,
    input   wire            start,
    input   wire            step,
    input   wire    [1:0]   snake_dir,

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
wire [POSBITS-1:0] tail_pos = (tail_pos_y * SIZE_X + tail_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos = (head_pos_y * SIZE_X + head_pos_x) * 2'd3;

wire [POSBITS-1:0] head_pos_u = ((head_pos_y - 1'd1) * SIZE_X + head_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos_d = ((head_pos_y + 1'd1) * SIZE_X + head_pos_x) * 2'd3;
wire [POSBITS-1:0] head_pos_r = (head_pos_y * SIZE_X + head_pos_x + 1'd1) * 2'd3;
wire [POSBITS-1:0] head_pos_l = (head_pos_y * SIZE_X + head_pos_x - 1'd1) * 2'd3;

wire [2:0] tail_cell = {field[tail_pos + 2'd2], field[tail_pos + 1'd1], field[tail_pos]};
wire [2:0] head_cell = {field[head_pos + 2'd2], field[head_pos + 1'd1], field[head_pos]};

integer ix;
integer iy;

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
        for (iy = 0; iy < SIZE_Y; iy = iy + 1'd1)
        begin
            for (ix = 0; ix < SIZE_X; ix = ix + 1'd1)
            begin
                {field[(iy * SIZE_X + ix) * 2'd3 + 2'd2],
                 field[(iy * SIZE_X + ix) * 2'd3 + 1'd1],
                 field[(iy * SIZE_X + ix) * 2'd3]} = ((1'd0 < ix) & (ix < 4'd5) & (iy == 1'd1)) ? 3'd2 : 3'd0;
            end
        end

        tail_pos_x <= 1'd1;
        tail_pos_y <= 1'd1;
        head_pos_x <= 4'd4;
        head_pos_y <= 1'd1;
        true_dir <= 2'd1;
    end
    else if (step)
    begin
        true_dir <= ((true_dir ^ snake_dir) == 2'd2) ? true_dir : snake_dir;

        if (tail_cell == 3'd1)
            tail_pos_y <= tail_pos_y - 1'd1;
        else if (tail_cell == 3'd2)
            tail_pos_x <= tail_pos_x + 1'd1;
        else if (tail_cell == 3'd3)
            tail_pos_y <= tail_pos_y + 1'd1;
        else if (tail_cell == 3'd4)
            tail_pos_x <= tail_pos_x - 1'd1;

        if (true_dir == 2'd0)
        begin
            head_pos_y <= head_pos_y - 1'd1;
            {field[head_pos_u + 2'd2], field[head_pos_u + 1'd1], field[head_pos_u]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd1)
        begin
            head_pos_x <= head_pos_x + 1'd1;
            {field[head_pos_r + 2'd2], field[head_pos_r + 1'd1], field[head_pos_r]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd2)
        begin
            head_pos_y <= head_pos_y + 1'd1;
            {field[head_pos_d + 2'd2], field[head_pos_d + 1'd1], field[head_pos_d]} <= true_dir + 1'd1;
        end
        else if (true_dir == 2'd3)
        begin
            head_pos_x <= head_pos_x - 1'd1;
            {field[head_pos_l + 2'd2], field[head_pos_l + 1'd1], field[head_pos_l]} <= true_dir + 1'd1;
        end

        {field[head_pos + 2'd2], field[head_pos + 1'd1], field[head_pos]} <= true_dir + 1'd1;
        {field[tail_pos + 2'd2], field[tail_pos + 1'd1], field[tail_pos]} <= 3'd0;
    end
end
endmodule