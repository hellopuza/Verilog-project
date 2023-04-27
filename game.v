module game
(
    input   wire    clk,
    input   wire    rst,
    input   wire    key_w,
    input   wire    key_a,
    input   wire    key_s,
    input   wire    key_d,
    input   wire    key_esc,
    input   wire    key_enter,

    output  [7:0]   vga_r,
    output  [7:0]   vga_g,
    output  [7:0]   vga_b,
    output          vga_clk,
    output          vga_blank_n,
    output          vga_sync_n,
    output          vga_hs,
    output          vga_vs	
);



endmodule