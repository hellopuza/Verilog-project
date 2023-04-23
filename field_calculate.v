module field_calculate
#(
	parameter	SIZE_X	= 10, // set x field size
	parameter	SIZE_Y	= 10  // set y field size
)
(
	input	wire	clk,   // clock signal
	input	wire	rst,   // reset signal
	input	wire	step,  // signal next step in game and refresh screen
	input	[0:15]	lengh, // snake's lengh
	input	[0:8 * (SIZE_X * SIZE_Y) * 2 - 1]	snake_xy, // array that contain snake's coordinates

	output	[0:15]	empty_cells,				// number of empty cells
	output	[0:2 * SIZE_X * SIZE_Y - 1]	field	// describe field
	// each cell contain 2 bits: 00 - cell empty, 01 - snake, 10 - apple, 11 - block
	// total cell: SIZE_X * SIZE_Y
);

reg [0:15] emp_cells;
reg [0:2 * SIZE_X * SIZE_Y - 1] temp_field;
reg [0:15] temp;

assign empty_cells = emp_cells;
assign field = temp_field;

always @(posedge clk)
begin
	if (rst) 
	begin
		emp_cells <= 16'b0;	
		for (temp = 0; temp < (2 * SIZE_X * SIZE_Y - 1); temp = temp + 1) 
		begin
			temp_field[temp] <= 1'b0;
		end
	end
	if (step) 
	begin
		for (temp = 0; temp < lengh; temp = temp + 1) 
		begin
			temp_field[snake_xy[temp] + snake_xy[temp + 8] * SIZE_X] <= 2'b01;
		end	
	end
end
endmodule