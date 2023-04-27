module game_behavior
#(
	parameter	SIZE_X	= 10, // set x field size
	parameter	SIZE_Y	= 10  // set y field size
)
(
	input										clk,
	input										rst,
	input										check,
	input										key, // 00 - w, 01 - a, 11 - s, 10 - d
	input	[8 * (SIZE_X * SIZE_Y) * 2 - 1:0]	snake_xy,
	input	[2 * SIZE_X * SIZE_Y - 1:0]			field,

	output dead,
	output grow
);

wire [15:0] index = snake_xy[7:0] * 2 + snake_xy[15:8] * SIZE_X * 2;
reg [1:0] result;

assign dead = result[0];
assign grow = result[1];

always @(posedge clk)
begin
	if (rst) 
	begin
		result <= 2'b0;		
	end
	else
	if (check)
	begin
		if (((snake_xy[7:0] == 0) && (key == 2'b01)) || snake_xy[7:0] == (SIZE_X - 1) && key == 2'b10) result <= 2'b01; // left-right border dead
		else
		if (((snake_xy[7:0] == 0) && (key == 2'b00)) || snake_xy[7:0] == (SIZE_X - 1) && key == 2'b11) result <= 2'b01; // up-down border dead
		else
		if (index == (SIZE_X * SIZE_Y - 1)) // right-down corner 
		begin
			if (field[index - 2 * SIZE_X] == 2'b01 && key == 2'b00) result <= 2'b01; // w
			if (field[index - 2] == 2'b01 && key == 2'b01) result <= 2'b01; // a
			if (field[index + 2 * SIZE_Y] == 2'b01 && key == 2'b11) result <= 2'b01; // s
			if (field[index + 2] == 2'b01 && key == 2'b10) result <= 2'b01; // d
		end
		else
		begin
			if (field[index - 2 * SIZE_X] == 2'b10 && key == 2'b00) result <= 2'b10; // w
			if (field[index - 2] == 2'b10 && key == 2'b01) result <= 2'b10; // a
			if (field[index + 2 * SIZE_Y] == 2'b10 && key == 2'b11) result <= 2'b10; // s
			if (field[index + 2] == 2'b10 && key == 2'b10) result <= 2'b10; // d
		end
	end
end
endmodule