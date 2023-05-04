module field_calculate
#(
	parameter	SIZE_X	= 10,
	parameter	SIZE_Y	= 10,
	parameter   FIELD_SIZE = (SIZE_X * SIZE_Y) * 3
)
(
	input	wire	clk,
	input	wire	rst,
	input	wire	step,
	input	wire [15:0]	lengh, // snake's lengh
	input	[SNAKE_SIZE - 1:0]	snake_xy, // array that contain snake's coordinates

	output	[15:0]	empty_cells,				// number of empty cells
	output	[FIELD_SIZE - 1:0]	field,	// describe field
	output  reg field2apple,
	output  wire	apple_done
	// each cell contain 2 bits: 00 - cell empty, 01 - snake, 10 - apple, 11 - block
	// total cell: SIZE_X * SIZE_Y
);

reg [15:0] emp_cells;
reg [15:0] emp;
reg [FIELD_SIZE - 1:0] temp_field;
wire [6:0] rand;

integer temp;
assign empty_cells = emp_cells;
assign field = temp_field;

always @(posedge clk)
begin
	field2apple <= step;
	if (rst)
	begin
		emp_cells <= 16'b0;
		emp <= 16'b0;
	end
	else
	begin
		for (temp = 0; temp < (SIZE_X * SIZE_Y - 1); temp = temp + 1)
		begin
			emp_cells = (temp_field[2 * temp] == 2'b01) ? emp_cells : emp_cells + 1;
		end	
	end
end

reg [SIZE_X*SIZE_Y-1:0] check_any;

assign apple_done = (check_any != {SIZE_X*SIZE_Y{1'b0}}) ? 1'b1 : 1'b0;
endmodule