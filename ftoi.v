module ftoi(
    input wire [31:0] x,
    output wire [31:0] y);

    wire sx;
    wire [7:0] ex;
    wire [22:0] mx;
    assign sx = x[31:31];
    assign ex = x[30:23];
    assign mx = x[22:0];

    wire [30:0] mya;
    assign mya = {1'b1,mx,7'b0};

    wire [7:0] se;
    assign se = 8'd157 - ex;

    wire [30:0] myb;
    assign myb = mya >> se;

    wire sy;
    wire [30:0] my;
    assign sy = sx;
    assign my = (sy) ? (~myb) + 1: myb;

    assign y = (my == 0) ? 0: {sy,my};

endmodule
