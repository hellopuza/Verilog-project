`include "keys.v"

module key_control (
    input          clk,
    input          rst,
    input          start,
    input  [7:0]   key,
    input          key_pressed,

    output reg [1:0] snake_dir
);

always @(posedge clk)
begin
    if (rst)
        snake_dir <= 2'b00;

    else if (start)
        snake_dir <= 2'b10;
    
    else if (key_pressed)
    begin
        if (key == `KEY_W)
            snake_dir <= 2'b00;
        if (key == `KEY_A)
            snake_dir <= 2'b01;
        if (key == `KEY_S)
            snake_dir <= 2'b11;
        if (key == `KEY_D)
            snake_dir <= 2'b10;
    end

end

endmodule