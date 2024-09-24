`timescale 1ns/1ps

module tb;
    reg [2:0] key;
    reg [4:0] btn;
    wire [7:0] led;

    reg clk;
    wire [7:0] sseg_ca;
    wire [3:0] sseg_an;
    always #10 clk = ~clk;

    always begin
        #1 btn[0] = ~btn[0];#1 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#3 btn[3] = ~btn[3];
        #1 btn[0] = ~btn[0];#3 btn[1] = ~btn[1];#8 btn[2] = ~btn[2];#2 btn[3] = ~btn[3];
        #2 btn[0] = ~btn[0];#3 btn[1] = ~btn[1];#2 btn[2] = ~btn[2];#2 btn[3] = ~btn[3];
        #1 btn[0] = ~btn[0];#1 btn[1] = ~btn[1];#8 btn[2] = ~btn[2];#2 btn[3] = ~btn[3];
        #3 btn[0] = ~btn[0];#4 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#3 btn[3] = ~btn[3];
        #3 btn[0] = ~btn[0];#3 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#1 btn[3] = ~btn[3];
        #3 btn[0] = ~btn[0];#2 btn[1] = ~btn[1];#6 btn[2] = ~btn[2];#7 btn[3] = ~btn[3];
        #3 btn[0] = ~btn[0];#5 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#6 btn[3] = ~btn[3];
        #4 btn[0] = ~btn[0];#1 btn[1] = ~btn[1];#5 btn[2] = ~btn[2];#2 btn[3] = ~btn[3];
        #1 btn[0] = ~btn[0];#8 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#3 btn[3] = ~btn[3];
        #2 btn[0] = ~btn[0];#9 btn[1] = ~btn[1];#2 btn[2] = ~btn[2];#2 btn[3] = ~btn[3];
        #3 btn[0] = ~btn[0];#1 btn[1] = ~btn[1];#1 btn[2] = ~btn[2];#1 btn[3] = ~btn[3];
        #5 btn[0] = ~btn[0];#2 btn[1] = ~btn[1];#2 btn[2] = ~btn[2];#4 btn[3] = ~btn[3];
        #1 btn[0] = ~btn[0];#3 btn[1] = ~btn[1];#3 btn[2] = ~btn[2];#1 btn[3] = ~btn[3];
    end

    main #(.CLK_HZ(1_000_000), .LCD_FPS(1200), .BUTTON_CHK_HZ(4096)) dut  (.key(key), .btn(btn), .led(led), .clk(clk), .seg_an(sseg_an), .seg(sseg_ca));

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb);
        clk = 0;
        key=3'd0;
        #10000000 $finish();
    end
endmodule  
