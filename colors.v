module colors (
    input           grid_point_inside,
    input   [1:0]   grid_cell_type,

    output  [7:0]   red,
    output  [7:0]   green,
    output  [7:0]   blue
);

assign {red, green, blue} = grid_point_inside & (grid_cell_type == 2'b01) ? {8'hF0, 8'h50, 8'hA0} :
                            grid_point_inside & (grid_cell_type == 2'b10) ? {8'h00, 8'hFF, 8'h00} :
                            grid_point_inside ? {8'h00, 8'h00, 8'h00} :
                            {8'h20, 8'h60, 8'h40};

endmodule