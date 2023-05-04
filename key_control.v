`include "keys.v"

module key_control (
    input          clk,
    input          rst,
    input  [7:0]   key,
    input          key_pressed,

    output  reg     [1:0]   snake_dir,
    output  wire            start,
    output  wire            pause
);

assign start = key_pressed & (key == `KEY_ENTER);
assign pause = key_pressed & (key == `KEY_SPACE);

always @(posedge clk)
begin
    if (rst)
        snake_dir <= 2'd0;

    else if (start)
        snake_dir <= 2'd1;
    
    else if (key_pressed)
    begin
        if (key == `KEY_W)
            snake_dir <= 2'd0;
        else if (key == `KEY_D)
            snake_dir <= 2'd1;
        else if (key == `KEY_S)
            snake_dir <= 2'd2;
        else if (key == `KEY_A)
            snake_dir <= 2'd3;
    end

end

endmodule