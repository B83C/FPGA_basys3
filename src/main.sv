`timescale 1ns/1ps

module bin2bcd #(
    parameter W = 18
) (
    input [W - 1:0] bin,
    output reg [W + (W-4)/3:0] bcd
);

    integer i, j;

    always @(bin) begin
        for(i = 0; i <= W+(W-4)/3; i = i + 1) bcd[i] = 0;
        bcd[W-1:0] = bin;
        for(i = 0; i <= W-4; i = i + 1)
            for(j = 0; j <= i/3; j = j+1)
                if (bcd[W-i+4*j -: 4] > 4)
                    bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
    end
endmodule

module pdl #(
    parameter BIT_LEN = 1,
    parameter MODE = 0
) (
    input CLK,
    input [BIT_LEN - 1: 0] D, 
    output reg [BIT_LEN - 1: 0] Q
);
    always @(CLK) begin
    	Q <= MODE ^ D; 
    end
endmodule

module main #(
    CLK_HZ = 1_000_000,
    LCD_FPS = 240,
    BUTTON_CHK_HZ = 0.4
)
(
    input clk,
    input [2:0] key,
    input [4:0] btn,
    output reg [7:0] led,
    output reg [7:0] seg,
    output reg [3:0] seg_an 
);

    localparam LCD_CLK_DIV = $clog2(CLK_HZ / LCD_FPS);
    localparam SEC_TICK = $clog2(CLK_HZ / 1);
    localparam LATCH_TICK = $clog2($rtoi(CLK_HZ / BUTTON_CHK_HZ));

    reg [32:0] div_clk;

    wire latch_tick;
    assign latch_tick = div_clk[LATCH_TICK];

    typedef reg [13:0] counter_int;
    counter_int counter;
    wire [17:0] bcd;
    wire [3:0] digits[3:0];
    reg [1:0] cursor_pos = 0;

    assign led[1:0] = cursor_pos;

    bin2bcd #(.W(14)) eou (.bin(counter), .bcd(bcd));
    localparam INPUT_LEN = 5;
    wire [INPUT_LEN -1: 0] latch1_output;
    wire [INPUT_LEN -1: 0] latch2_output;
    wire [INPUT_LEN -1: 0] latched_btn;
    pdl #(.BIT_LEN(INPUT_LEN), .MODE(0)) d1 (.CLK(latch_tick), .D(btn), .Q(latch1_output));
    pdl #(.BIT_LEN(INPUT_LEN), .MODE(1)) dn1 (.CLK(latch_tick), .D(latch1_output), .Q(latch2_output));
    assign latched_btn = latch1_output & latch2_output;

    function [7:0] encode(input [3:0] in, input dot);
        case (in)
            0: encode = 8'b11000000;
            1: encode = 8'b11111001;
            2: encode = 8'b10100100;
            3: encode = 8'b10110000;
            4: encode = 8'b10011001;
            5: encode = 8'b10010010;
            6: encode = 8'b10000010;
            7: encode = 8'b11111000;
            8: encode = 8'b10000000;
            9: encode = 8'b10010000;
            default: encode = 8'b11111111;
        endcase
        encode = encode ^ {dot, 7'b0};
    endfunction

    always @(posedge clk) begin
        div_clk <= div_clk + 1;
    end

    wire [1:0] bit_shift;
    assign bit_shift = div_clk[LCD_CLK_DIV : LCD_CLK_DIV - 1];

    // always @(div_clk[SEC_TICK]) begin
    //     counter <= counter + 1;
    // end

    always @(bit_shift) begin
        seg_an <= ~(4'b1111 & (1 << bit_shift)); 
        seg <= encode(bcd[4*(bit_shift+1) - 1 -: 4], bit_shift == cursor_pos);
    end

    parameter up = 5'b00001;
    parameter left = 5'b0001?;
    parameter right = 5'b001??;
    parameter down = 5'b01???;
    parameter centre = 5'b1????;
    counter_int adder = 0;
    always @(*) begin
        case(cursor_pos) 
            2'd0: adder = 1;
            2'd1: adder = 10;
            2'd2: adder = 100;
            2'd3: adder = 1000;
        endcase
    end
    always @(posedge latch_tick) begin
        led[7:3] = latched_btn;
        casez (latched_btn)
            centre: counter <= ;
            down: counter <= counter - adder;
            right: cursor_pos <= cursor_pos - 1;
            left : cursor_pos <= cursor_pos + 1;
            up: counter <= counter + adder;
            default: ;
        endcase
    end

    // always @(posedge |latched_btn) begin
    //     led[7:3] <= latched_btn;
    //     casez (latched_btn)
    //         right: cursor_pos <= cursor_pos + 1;
    //         left: counter <= counter - addendum;
    //         up: counter <= counter + addendum;
    //         default: ;
    //     endcase
    	
    // end

    always @(btn) begin
        // case (btn) 
        // 	up: counter <= counter + 1; 
        // 	down: counter <= counter - 1; 
        //   default: ;
        // endcase
    end

    initial begin
        seg_an = 4'b1111;
        seg = 8'b11111111;
        counter = 2;
    end

endmodule
