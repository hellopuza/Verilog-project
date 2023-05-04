module snake_calculate
#(
	parameter	SIZE_X	= 10, // set x field size
	parameter	SIZE_Y	= 10, // set y field size
	parameter   SNAKE_SIZE = 8 * (SIZE_X * SIZE_Y) * 2
)
(
	input	wire	clk,   // clock signal
	input	wire	rst,   // reset signal
	input	wire	step,  // signal next step in game and refresh screen
	input	wire	start, // signal that game is started
	input	wire	grow,  // signal that snake is grown
	input	[1:0]	key,   // 00 - w, 01 - a, 11 - s, 10 - d

	output	[15:0]	lengh, // snake's lengh
	output	[1:0]	true_key, // don't changed value of prev_key if it's conflicted with new value
	output	[SNAKE_SIZE - 1:0]	snake_xy, // array that contain snake's coordinates
	output  reg snake2field
	// for each snake's cells need 2 baits for x and y coordinates := 8 * 2
	// max snake's lengh is full grid := SIZE_X * SIZE_Y
	// total size := SIZE_X * SIZE_Y * 2 * 8
	// EXAMPLE:
	// meaning:			 ___x0___ ___y0___ ___x1___ ___y1___ ...
	// bincode snake_xy: 00000001 00000000 00000001 00000001 ...
	// (x0,y0) = (1,0)
	// (x1,y1) = (1,1)
	// ...
);

reg [1:0] prev_key;									// remember previous diraction key
reg [15:0]	len;						// remember previous snake's lengh
reg [SNAKE_SIZE - 1:0] coordinates;	// buffer for snake's coordinates
integer Gi;

assign true_key = prev_key;
assign snake_xy = coordinates;
assign lengh = len;

always @(posedge clk)
begin
	if (rst)
	begin
		len <= 16'd0;
		prev_key <= 2'd0;
		coordinates <= {SNAKE_SIZE{1'd0}};
		snake2field <= 1'd0;
	end

	snake2field <= step;
	if (start)
	begin
		// initial lengh = 4
		len <= 16'b100;
		prev_key <= 2'b11;
		coordinates[7:0]   <=	SIZE_X / 10;
		coordinates[15:8]  <=	SIZE_Y / 10;
		coordinates[23:16] <=	coordinates[7:0] - 1'b1;;
		coordinates[31:24] <=	coordinates[15:8];
		coordinates[39:32] <=	coordinates[23:16] - 1'b1;
		coordinates[47:40] <= coordinates[31:24];
		coordinates[55:48] <= coordinates[39:32] - 1'b1;
		coordinates[63:56] <= coordinates[47:40];
	end
	else
	begin
		if (step)
		begin
			for (Gi = (SIZE_X * SIZE_Y - 1); Gi > 0; Gi = Gi - 1)
			begin
				if (Gi < len)
				begin
					coordinates[Gi * 16] 		<= coordinates[(Gi - 1) * 16];
					coordinates[Gi * 16 + 8] 	<= coordinates[(Gi - 1) * 16 + 8];
				end
			end
			if (prev_key == 3'b00)
			begin
				coordinates[8] <= coordinates[8] + 1'b1;
			end
			if (prev_key == 3'b11)
			begin
				coordinates[8] <= coordinates[8] - 1; // wtf?
			end
			if (prev_key == 3'b10)
			begin
				coordinates[0] <= coordinates[0] + 1;
			end
			if (prev_key == 3'b01)
			begin
				coordinates[0] <= coordinates[0] - 1;
			end

			prev_key <= (((prev_key ^ key) == 2'b10) || ((prev_key ^ key) == 2'b01)) ? key : prev_key;
			if (grow) 
			begin
				len <= len + 1;
				coordinates[(len + 1) * 16] 		<= coordinates[len * 16]; 
				coordinates[(len + 1) * 16 + 8] 	<= coordinates[len * 16 + 8];
			end
		end
	end
end
endmodule