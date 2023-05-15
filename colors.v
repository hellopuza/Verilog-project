module colors (
    input           grid_point_inside,
    input   [2:0]   grid_cell_type,
    input           snake_alive,
    input           is_running,

    output  [7:0]   red,
    output  [7:0]   green,
    output  [7:0]   blue
);

wire [23:0] snake_color = is_running ? {8'h6A, 8'hB6, 8'h26} : {8'h35, 8'h5B, 8'h13};
wire [23:0] apple_color = is_running ? {8'hF6, 8'h2A, 8'h6E} : {8'h7B, 8'h15, 8'h37};
wire [23:0] back_color  = is_running ? {8'h14, 8'hA4, 8'h8E} : {8'h0A, 8'h52, 8'h47};
wire [23:0] field_color = ~snake_alive ? {8'hFF, 8'h00, 8'h00} :
                          is_running ? {8'h44, 8'h44, 8'h44} : {8'h22, 8'h22, 8'h22};

assign {red, green, blue} = grid_point_inside & (grid_cell_type == 3'd1) ? snake_color :
                            grid_point_inside & (grid_cell_type == 3'd2) ? snake_color :
                            grid_point_inside & (grid_cell_type == 3'd3) ? snake_color :
                            grid_point_inside & (grid_cell_type == 3'd4) ? snake_color :
                            grid_point_inside & (grid_cell_type == 3'd5) ? apple_color :
                            grid_point_inside & (grid_cell_type == 3'd0) ? field_color :
                            back_color;

endmodule