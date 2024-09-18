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
        #1 btn[0] = ~btn[0];
        #1 btn[0] = ~btn[0];
        #2 btn[0] = ~btn[0];
        #1 btn[0] = ~btn[0];
        #3 btn[0] = ~btn[0];
        #3 btn[0] = ~btn[0];
        #3 btn[0] = ~btn[0];
        #3 btn[0] = ~btn[0];
        #4 btn[0] = ~btn[0];
        #1 btn[0] = ~btn[0];
        #2 btn[0] = ~btn[0];
        #3 btn[0] = ~btn[0];
        #5 btn[0] = ~btn[0];
        #1 btn[0] = ~btn[0];
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
