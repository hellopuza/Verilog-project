`include "keys.v"

module key_control (
    input          clk,
    input          rst,
    input  [7:0]   key,
    input          key_pressed,

    output  reg     [1:0]   snake_dir,
    output  reg             is_running,
    output  wire            start
);

assign start = key_pressed & (key == `KEY_ENTER);
wire   pause = key_pressed & (key == `KEY_SPACE);

always @(posedge clk)
begin
    if (rst)
    begin
        snake_dir <= 2'd0;
        is_running <= 1'd0;
    end

    else if (start)
    begin
        snake_dir <= 2'd1;
        is_running <= 1'd1;
    end

    else if (pause)
    begin
        is_running <= ~is_running;
    end

    else if (key_pressed & is_running)
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