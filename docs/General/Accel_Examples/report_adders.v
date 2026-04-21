module report_adders (
    input  [7:0] a,
    output [7:0] y1,
    output [7:0] y2,
    output [7:0] y3
);

    localparam A = 4'd6;
    localparam B = 4'd9;

    assign y1 = a + (A + B);
    assign y2 = a & ((1 << 3) - 1);
    assign y3 = a * 2;

endmodule






/*
module report_adders (
    input [7:0] x,
    input [7:0] y,
    output [7:0] z
);
    localparam MASK = 8'hF0;
    assign z = (x & MASK) | (y & ~MASK);
endmodule
*/
