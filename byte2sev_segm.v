module byte2sev_segm
#(
	parameter   NOTATION = 16
)
(
    input   [7:0]   byte,
    output  [6:0]   segm0,
    output  [6:0]   segm1
);

wire [6:0] sev_segments [15:0];
assign sev_segments[0]  = 7'b1000000;
assign sev_segments[1]  = 7'b1111001;
assign sev_segments[2]  = 7'b0100100;
assign sev_segments[3]  = 7'b0110000;
assign sev_segments[4]  = 7'b0011001;
assign sev_segments[5]  = 7'b0010010;
assign sev_segments[6]  = 7'b0000010;
assign sev_segments[7]  = 7'b1111000;
assign sev_segments[8]  = 7'b0000000;
assign sev_segments[9]  = 7'b0010000;
assign sev_segments[10] = 7'b0001000;
assign sev_segments[11] = 7'b0000011;
assign sev_segments[12] = 7'b1000110;
assign sev_segments[13] = 7'b0100001;
assign sev_segments[14] = 7'b0000110;
assign sev_segments[15] = 7'b0001110;

wire [6:0] segm0_wires [255:0];
wire [6:0] segm1_wires [255:0];

assign segm0_wires[0] = (byte == 8'h0) ? sev_segments[0] : 7'b1111111;
assign segm1_wires[0] = (byte == 8'h0) ? sev_segments[0] : 7'b1111111;

genvar Gi;
generate for (Gi = 1; Gi < 256; Gi = Gi + 1)
begin: loop
    assign segm0_wires[Gi] = (Gi == byte) ? sev_segments[Gi % NOTATION]              : segm0_wires[Gi - 1];
    assign segm1_wires[Gi] = (Gi == byte) ? sev_segments[(Gi / NOTATION) % NOTATION] : segm1_wires[Gi - 1];
end
endgenerate

assign segm0 = segm0_wires[255];
assign segm1 = segm1_wires[255];

endmodule