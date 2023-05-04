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
	output	[FIELD_SIZE - 1:0]	field,	// describe field
	output  reg field2apple
	// each cell contain 2 bits: 00 - cell empty, 01 - snake, 10 - apple, 11 - block
	// total cell: SIZE_X * SIZE_Y
);

reg [15:0] emp_cells;
reg [15:0] emp;
reg [FIELD_SIZE - 1:0] temp_field;
wire [6:0] rand;
reg gen_flag;

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
end

genvar Gi;

generate for (Gi = 0; Gi < SIZE_X * SIZE_Y; Gi = Gi + 1)
begin: loop
	always @(posedge clk) 
	begin
		if (rst)
		begin
			if (Gi == 0)
			begin
				temp_field[Gi*2] <= 2'b10;
			end
			else
			begin
				temp_field[Gi*2] <= 2'b0;
			end
		end
		else
		begin
			if (step)
			begin
				for (temp = 0; temp < lengh; temp = temp + 1) 
				begin
					if (snake_xy[temp] + snake_xy[temp + 8] * SIZE_X == Gi) 
					begin
						temp_field[Gi * 2] <= 2'b01;
					end
				end
			end
		end
	end
end
endgenerate

// always @(posedge clk)
// begin
// 	if (step) 
// 	begin
// 		for (temp = 0; temp < lengh; temp = temp + 1) 
// 		begin
// 			temp_field[snake_xy[temp] * 2 + snake_xy[temp + 8] * SIZE_X * 2] <= 2'b01;
// 		end

// 		// need additional module
// 		// for (temp = 0; temp < (SIZE_X * SIZE_Y - 1); temp = temp + 1)
// 		// begin
// 		// 	emp_cells = (temp_field[2 * temp] == 2'b01) ? emp_cells : emp_cells + 1;
// 		// end
// 	end
// 		// temp
// 	if (gen_flag)
// 	begin
// 		if (rand > 99)
// 		begin
// 			if(field[(rand - 7'd100) * 2 + 1 : (rand - 7'd100) * 2] == 2'b00)
// 			begin
// 				field[(rand - 7'd100) * 2 + 1 : (rand - 7'd100) * 2] <= 2'b10;
// 				gen_flag <= 1'b0;
// 			end
// 		end
// 		else
// 		begin
// 			if(field[(rand) * 2 + 1 : (rand) * 2] == 2'b00)
// 			begin
// 				field[(rand) * 2 + 1 : (rand) * 2] <= 2'b10;
// 				gen_flag <= 1'b0;
// 			end
// 		end
// 	end
// end

// get_random 
// #(
// 	MODULUS(SIZE_X * SIZE_Y)
// ) get_random
// (
// 	.clk(clk),
// 	.rst(rst),
// 	.number(rand)
// );
endmodule