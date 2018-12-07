module fpu(
    input wire [3:0] ctrl,
    input wire [31:0] ds_val,
    input wire [31:0] dt_val,
    input wire [5:0] dd,
    input wire [15:0] imm,
    output wire [5:0] reg_addr,
    output wire [31:0] dd_val);
    
    function [31:0] TABLE (
        input [6:0] IMMR
    );
    begin
        casex(IMMR)
        7'd0:TABLE = 32'b00000000000000000000000000000000;
        7'd1:TABLE = 32'b00111111000000000000000000000000;
        7'd2:TABLE = 32'b00111111100000000000000000000000;
        7'd3:TABLE = 32'b01000000000000000000000000000000;
        7'd4:TABLE = 32'b01000000010010010000111111011100;
        7'd5:TABLE = 32'b01000000110010010000111111011010;
        7'd6:TABLE = 32'b00111110001010101010101011000001;
        7'd7:TABLE = 32'b00111100000010001000011100100011;
        7'd8:TABLE = 32'b00111001010011011000010101011001;
        7'd9:TABLE = 32'b00111101001010101010011111011111;
        7'd10:TABLE = 32'b00111010101100111001000110010010;
        7'd11:TABLE = 32'b10111111100000000000000000000000;
        7'd12:TABLE = 32'b00111111110010010000111111011000;
        7'd13:TABLE = 32'b00111111010010010000111111011000;
        7'd14:TABLE = 32'b01000000010010010000111111101101;
        7'd15:TABLE = 32'b00111111110010010000111111101001;
        7'd16:TABLE = 32'b00111111010010010000111111101001;
        7'd17:TABLE = 32'b00111110101010101010101010011111;
        7'd18:TABLE = 32'b00111110010011001100110011001101;
        7'd19:TABLE = 32'b00111110000100100100100100011011;
        7'd20:TABLE = 32'b00111101111000111000111000101010;
        7'd21:TABLE = 32'b00111101101101111101011000110000;
        7'd22:TABLE = 32'b00111101011101011110011101000011;
        7'd23:TABLE = 32'b01000000100011000000000000000000;
        7'd24:TABLE = 32'b01000000000111000000000000000000;
        7'd25:TABLE = 32'b00111100100011101111100110011000;
        7'd26:TABLE = 32'b01000011010010000000000000000000;
        7'd27:TABLE = 32'b11000011010010000000000000000000;
        7'd28:TABLE = 32'b10111110010011001100110011001101;
        7'd29:TABLE = 32'b00111100001000111101011100001010;
        7'd30:TABLE = 32'b10111101110011001100110011001101;
        7'd31:TABLE = 32'b01001110011011100110101100101000;
        7'd32:TABLE = 32'b01001100101111101011110000100000;
        7'd33:TABLE = 32'b00111000110100011011011100010111;
        7'd34:TABLE = 32'b01000001011100000000000000000000;
        7'd35:TABLE = 32'b01000001111100000000000000000000;
        7'd36:TABLE = 32'b00111110000110011001100110011010;
        7'd37:TABLE = 32'b01000011011111110000000000000000;
        7'd38:TABLE = 32'b00111110100110011001100110011010;
        7'd39:TABLE = 32'b01000001001000000000000000000000;
        7'd40:TABLE = 32'b00111110100000000000000000000000;
        7'd41:TABLE = 32'b00111101010011001100110011001101;
        7'd42:TABLE = 32'b01000001101000000000000000000000;
        7'd43:TABLE = 32'b00111011011111111111101111001110;
        7'd44:TABLE = 32'b11000000000000000000000000000000;
        7'd45:TABLE = 32'b00111101110011001100110011001101;
        7'd46:TABLE = 32'b11000011000101100000000000000000;
        7'd47:TABLE = 32'b01000011000101100000000000000000;
        7'd48:TABLE = 32'b00111111011001100110011001100110;
        7'd49:TABLE = 32'b01000011000000000000000000000000;
        default:TABLE = 32'b0;
        endcase
    end
    endfunction

    wire [31:0] fadd_y,fmul_y,fdiv_y,fsqrt_y;
    wire [31:0] ftoi_y,itof_y;

    fadd u1 (ds_val,{dt_val[31] ^ ctrl[1],dt_val[30:0]},fadd_y);
    fmul u3 (ds_val,dt_val,fmul_y);
    fdiv u4 (ds_val,fdiv_y);
    fsqrt u5 (ds_val,fsqrt_y);
    ftoi u9 (ds_val,ftoi_y);
    itof u10 (ds_val,itof_y);

    // fle,flt
    wire s1,s2;
    wire [7:0] e1,e2;
    wire [22:0] m1,m2;
    assign s1 = ds_val[31:31];
    assign e1 = ds_val[30:23];
    assign m1 = ds_val[22:0];
    assign s2 = dt_val[31:31];
    assign e2 = dt_val[30:23];
    assign m2 = dt_val[22:0];


    wire s1a,s2a;
    wire [7:0] e1a,e2a;
    wire [22:0] m1a,m2a,m1b,m2b;
    assign s1a = (e1 == 0) ? 1: ~s1;
    assign e1a = (s1a) ? e1: ~e1;
    assign m1a = (e1 == 0) ? 0: m1;
    assign m1b = (s1a) ? m1a: ~m1a;
    assign s2a = (e2 == 0) ? 1: ~s2;
    assign e2a = (s2a) ? e2: ~e2;
    assign m2a = (e2 == 0) ? 0: m2;
    assign m2b = (s2a) ? m2a: ~m2a;

    wire feq_y,flt_y;
    assign flt_y = ({s1a,e1a,m1b} < {s2a,e2a,m2b});    
    assign feq_y = ({s1a,e1a,m1b} == {s2a,e2a,m2b});

    wire [31:0] flup_y;
    assign flup_y = TABLE(imm[6:0]);

    assign reg_addr = (4'd0 || 4'd15) ? 6'b0: dd;

    function [31:0] Y(
        input [3:0] CTRL,
        input [31:0] FADD_Y,
        input [31:0] FMUL_Y,
        input [31:0] FDIV_Y,
        input [31:0] FSQRT_Y,
        input FEQ_Y,
        input FLT_Y,
        input [31:0] FTOI_Y,
        input [31:0] ITOF_Y,
        input [31:0] DS_VAL,
        input [31:0] FLUP_Y
    );
    begin
        case(CTRL)
        4'd1: Y = FADD_Y;
        4'd2: Y = FADD_Y;
        4'd3: Y = FMUL_Y;
        4'd4: Y = FDIV_Y;
        4'd5: Y = FSQRT_Y;
        4'd6: Y = {31'b0,FEQ_Y};
        4'd7: Y = {31'b0,FLT_Y};
        4'd8: Y = {31'b0,FEQ_Y | FLT_Y};
        4'd9: Y = FTOI_Y;
        4'd10: Y = ITOF_Y;
        4'd11: Y = {~DS_VAL[31],DS_VAL[30:0]};
        4'd12: Y = DS_VAL;
        4'd13: Y = DS_VAL;
        4'd14: Y = FLUP_Y;
        default: Y = 32'b0;
        endcase
    end
    endfunction

    assign dd_val = Y(ctrl,fadd_y,fmul_y,fdiv_y,fsqrt_y,feq_y,flt_y,ftoi_y,itof_y,ds_val,flup_y);

endmodule
