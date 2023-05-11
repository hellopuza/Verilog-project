module colors (
    input           grid_point_inside,
    input   [2:0]   grid_cell_type,

    output  [7:0]   red,
    output  [7:0]   green,
    output  [7:0]   blue
);

wire [23:0] snake_color_u = {8'h00, 8'h00, 8'hAA};
wire [23:0] snake_color_r = {8'hAA, 8'h00, 8'h00};
wire [23:0] snake_color_d = {8'h00, 8'hAA, 8'h00};
wire [23:0] snake_color_l = {8'hAA, 8'hAA, 8'hAA};
wire [23:0] apple_color = {8'h00, 8'hFF, 8'h00};
wire [23:0] field_color = {8'h00, 8'h00, 8'h00};
wire [23:0] back_color  = {8'h20, 8'h60, 8'h40};

assign {red, green, blue} = grid_point_inside & (grid_cell_type == 3'd1) ? snake_color_u :
                            grid_point_inside & (grid_cell_type == 3'd2) ? snake_color_r :
                            grid_point_inside & (grid_cell_type == 3'd3) ? snake_color_d :
                            grid_point_inside & (grid_cell_type == 3'd4) ? snake_color_l :
                            grid_point_inside & (grid_cell_type == 3'd5) ? apple_color :
                            grid_point_inside & (grid_cell_type == 3'd0) ? field_color :
                            back_color;

endmodule