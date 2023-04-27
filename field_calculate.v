module field_calculate
#(
	parameter	SIZE_X	= 10, // set x field size
	parameter	SIZE_Y	= 10, // set y field size
	parameter   SNAKE_SIZE = 8 * (SIZE_X * SIZE_Y) * 2,
	parameter   FIELD_SIZE = (SIZE_X * SIZE_Y) * 2
)
(
	input	wire	clk,   // clock signal
	input	wire	rst,   // reset signal
	input	wire	step,  // signal next step in game and refresh screen
	input	[15:0]	lengh, // snake's lengh
	input	[SNAKE_SIZE - 1:0]	snake_xy, // array that contain snake's coordinates

	output	[15:0]	empty_cells,				// number of empty cells
	output	[FIELD_SIZE - 1:0]	field	// describe field
	output  reg field2apple;
	// each cell contain 2 bits: 00 - cell empty, 01 - snake, 10 - apple, 11 - block
	// total cell: SIZE_X * SIZE_Y
);

reg [15:0] emp_cells;
reg [FIELD_SIZE - 1:0] temp_field;
reg [15:0] temp;

assign empty_cells = emp_cells;
assign field = temp_field;

always @(posedge clk)
begin
	field2apple <= step;
	if (rst) 
	begin
		emp_cells <= 16'b0;	
		for (temp = 0; temp < (FIELD_SIZE - 1); temp = temp + 1) 
		begin
			temp_field[temp] <= 1'b0;
		end
	end
	if (step) 
	begin
		for (temp = 0; temp < lengh; temp = temp + 1) 
		begin
			temp_field[snake_xy[temp] * 2 + snake_xy[temp + 8] * SIZE_X * 2] <= 2'b01;
		end
		for (temp = 0; temp < (SIZE_X * SIZE_Y - 1); temp = temp + 1)
		begin
			emp_cells = (temp_field[2 * temp] == 2'b01) ? emp_cells : emp_cells + 1;
		end
	end
end
endmodule