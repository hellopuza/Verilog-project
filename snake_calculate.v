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
reg [15:0]	counter = 16'b0;						// counter for operate loop 
reg [15:0]	previus_l = 16'b0;						// remember previous snake's lengh
reg [15:0]	current_l = 16'b0;						// current snake's lengh
reg [SNAKE_SIZE - 1:0] coordinates;	// buffer for snake's coordinates
integer Gi;

assign true_key = prev_key;
assign snake_xy = coordinates;
assign lengh = previus_l;

always @(posedge clk)
begin
	snake2field <= step;
	if (start)
	begin
		// initial lengh = 4
		previus_l <= 16'b100;
		current_l <= 16'b100;
		prev_key <= 2'b11;
		coordinates[0] <=	SIZE_X / 10;
		coordinates[8] <=	SIZE_Y / 10;
		coordinates[16] <=	coordinates[0] - 1;
		coordinates[24] <=	coordinates[8];
		coordinates[32] <=	coordinates[16] - 1;
		coordinates[40] <= coordinates[24];
		coordinates[48] <= coordinates[32] - 1;
		coordinates[56] <= coordinates[40];
	end
	else
	begin
		if (step)
		begin
			for (Gi = 0; Gi < (SIZE_X * SIZE_Y - 1); Gi = Gi + 1)
			begin
				counter = counter + 1;
				if (current_l >= counter)
				begin
					if (!Gi) 
					begin
						if (prev_key == 3'b00)
						begin
							coordinates[0] <= coordinates[0];
							coordinates[8] <= coordinates[8] + 1;
						end
						if (prev_key == 3'b11)
						begin
							coordinates[0] <= coordinates[0];
							coordinates[8] <= coordinates[8] - 1; // wtf?
						end
						if (prev_key == 3'b10)
						begin
							coordinates[0] <= coordinates[0] + 1;
							coordinates[8] <= coordinates[8];
						end
						if (prev_key == 3'b01)
						begin
							coordinates[0] <= coordinates[0] - 1;
							coordinates[8] <= coordinates[8];
						end
					end
					else
					begin
						coordinates[Gi * 16] 		= coordinates[(Gi - 1) * 16];
						coordinates[Gi * 16 + 8] 	= coordinates[(Gi - 1) * 16 + 8];
					end
					prev_key <= (((prev_key ^ key) == 2'b10) || ((prev_key ^ key) == 2'b01)) ? key : prev_key;
					if (grow) 
					begin
						previus_l <= previus_l + 1;
						coordinates[(previus_l + 1) * 16] 		<= coordinates[previus_l * 16]; 
						coordinates[(previus_l + 1) * 16 + 8] 	<= coordinates[previus_l * 16 + 8];
					end
				end
			end
		end
	end
end
endmodule