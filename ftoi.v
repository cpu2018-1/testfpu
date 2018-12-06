`default_nettype none

module ftoi(
    input wire [31:0] x,
    output wire [31:0] y);

    wire sx;
    wire [7:0] ex;
    wire [22:0] mx;
    assign sx = x[31:31];
    assign ex = x[30:23];
    assign mx = x[22:0];

    wire [31:0] mya;
    assign mya = {1'b1,mx,8'b0};

    wire [7:0] se;
    assign se = (ex <= 8'd157) ? (8'd157 - ex): 8'd255;

    wire [31:0] myb;
    assign myb = (mya >> se) + 1;
  
    wire [30:0] myc;
    assign myc = myb[31:1];

    wire sy;
    wire [30:0] my;
    assign sy = sx;
    assign my = (sy) ? (~myc) + 1: myc;

    assign y = (my == 0) ? 0: {sy,my};

endmodule
