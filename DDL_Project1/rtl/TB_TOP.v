`timescale 1ns/1ps

module TB_TOP;
   reg [9:0] BUTTON;
   reg        STAR, CLK, HASH, RESET, OPEN_BUTTON, CLOSE_SENSOR;
   wire [15:0] DISPLAY;
   wire [9:0]  RANDOM_BUTTON;
   wire          ALERT, UNLOCK;

   TOP DUT (
        .BUTTON(BUTTON[9:0]),
        .STAR(STAR),
        .HASH(HASH),
        .CLK(CLK),
        .OPEN_BUTTON(OPEN_BUTTON),
        .RESET(RESET),
        .RANDOM_BUTTON(RANDOM_BUTTON[9:0]),
        .DISPLAY(DISPLAY[15:0]),
        .ALERT(ALERT),
        .UNLOCK(UNLOCK),
        .CLOSE_SENSOR(CLOSE_SENSOR)
        );

   always
     #25
       CLK <= ~CLK;

   initial
     begin
   $dumpfile("result.vcd");
   $dumpvars(0, TB_TOP);
   RESET = 1;
   CLK = 1;
   HASH = 0;
   BUTTON = 0;
   STAR = 0;
   OPEN_BUTTON = 0;
   CLOSE_SENSOR = 0;

   #100
     RESET = 0;
   #100
     STAR = 1;
   #100
     STAR = 0;
   BUTTON[0] = 1;
   #100
     BUTTON[0] = 0;
   #50
     BUTTON[0] = 1;
   #100
     BUTTON[0] = 0;
   #50
     BUTTON[0] = 1;
   #100
     BUTTON[0] = 0;
   #50
     BUTTON[0] = 1;
   #100
     BUTTON[0] = 0;
   STAR = 1;
   #100
     STAR = 0;
   #300
     STAR = 1;
   #100
     STAR = 0;
   BUTTON[9] = 1;
   #100
     BUTTON[9] = 0;
   BUTTON[8] = 1;
   #100
     BUTTON[8] = 0;
   BUTTON[7] = 1;
   #100
     BUTTON[7] = 0;
   BUTTON[6] = 1;
   #100
     BUTTON[6] = 0;
   STAR = 1;
   #100
     STAR = 0;
   #300
     CLOSE_SENSOR = 1;
   #100
     CLOSE_SENSOR = 0;
   #300
     BUTTON[9] = 1;
   #100
     BUTTON[9] = 0;
   BUTTON[8] = 1;
   #100
     BUTTON[8] = 0;
   BUTTON[7] = 1;
   #100
     BUTTON[7] = 0;
   BUTTON[6] = 1;
   #100
     BUTTON[6] = 0;
   STAR = 1;
   #100
     STAR = 0;
   #300
     HASH = 1;
   #100
     HASH = 0;
   BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   HASH = 1;
   #100
     HASH = 0;
   #300
     CLOSE_SENSOR = 1;
   #100
     CLOSE_SENSOR = 0;
   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   STAR = 1;
   #100
     STAR = 0;
   #300
     CLOSE_SENSOR = 1;
   #100
     CLOSE_SENSOR = 0;
   
   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   STAR = 1;
   #100
     STAR = 0;
   
   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     STAR = 1;
   #100
     STAR = 0;
   
   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   STAR = 1;
   #100
     STAR = 0;

   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   STAR = 1;
   #100
     STAR = 0;

   #300
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     BUTTON[1] = 1;
   #100
     BUTTON[1] = 0;
   #50
     STAR = 1;
   #100
     STAR = 0;   #800
     BUTTON[9] = 1;
   #100
     BUTTON[9] = 0;
   BUTTON[8] = 1;
   #100
     BUTTON[8] = 0;
   BUTTON[7] = 1;
   #100
     BUTTON[7] = 0;
   BUTTON[6] = 1;
   #100
     BUTTON[6] = 0;
   STAR = 1;
   #100
     STAR = 0;
	#200
	  OPEN_BUTTON = 1;
	#400
	  OPEN_BUTTON = 0;
	#500
	  CLOSE_SENSOR = 1;
	#100
	  CLOSE_SENSOR = 0;
	#300
	  OPEN_BUTTON = 1;
	#400
	  OPEN_BUTTON = 0;
	#100
	  CLOSE_SENSOR = 1;
	#100
	  CLOSE_SENSOR = 0;
   #1000
     $finish;
     end // initial begin
endmodule // TB_TOP
