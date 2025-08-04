`timescale 10ms/10ms

module top_module_tb;
   reg [9:0] button;
   reg        star, clk, hash, reset, open_button, close_sensor;
   wire [15:0] display;
   wire [9:0]  random_button;
   wire          alert, unlock;

   top_module i0 (
        .button(button[9:0]),
        .star(star),
        .hash(hash),
        .clk(clk),
        .open_button(open_button),
        .reset(reset),
        .random_button(random_button[9:0]),
        .display(display[15:0]),
        .alert(alert),
        .unlock(unlock),
        .close_sensor(close_sensor)
        );

   always
     #25
       clk <= ~clk;

   initial
     begin
   $dumpfile("result.vcd");
   $dumpvars(0, top_module_tb);
   reset = 1;
   clk = 1;
   hash = 0;
   button = 0;
   star = 0;
   open_button = 0;
   close_sensor = 0;

   #100
     reset = 0;
   #100
     star = 1;
   #100
     star = 0;
   button[0] = 1;
   #100
     button[0] = 0;
   #50
     button[0] = 1;
   #100
     button[0] = 0;
   #50
     button[0] = 1;
   #100
     button[0] = 0;
   #50
     button[0] = 1;
   #100
     button[0] = 0;
   star = 1;
   #100
     star = 0;
   #300
     star = 1;
   #100
     star = 0;
   button[9] = 1;
   #100
     button[9] = 0;
   button[8] = 1;
   #100
     button[8] = 0;
   button[7] = 1;
   #100
     button[7] = 0;
   button[6] = 1;
   #100
     button[6] = 0;
   star = 1;
   #100
     star = 0;
   #300
     close_sensor = 1;
   #100
     close_sensor = 0;
   #300
     button[9] = 1;
   #100
     button[9] = 0;
   button[8] = 1;
   #100
     button[8] = 0;
   button[7] = 1;
   #100
     button[7] = 0;
   button[6] = 1;
   #100
     button[6] = 0;
   star = 1;
   #100
     star = 0;
   #300
     hash = 1;
   #100
     hash = 0;
   button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   hash = 1;
   #100
     hash = 0;
   #300
     close_sensor = 1;
   #100
     close_sensor = 0;
   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   star = 1;
   #100
     star = 0;
   #300
     close_sensor = 1;
   #100
     close_sensor = 0;
   
   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   star = 1;
   #100
     star = 0;
   
   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     star = 1;
   #100
     star = 0;
   
   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   star = 1;
   #100
     star = 0;

   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   star = 1;
   #100
     star = 0;

   #300
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     button[1] = 1;
   #100
     button[1] = 0;
   #50
     star = 1;
   #100
     star = 0;   #800
     button[9] = 1;
   #100
     button[9] = 0;
   button[8] = 1;
   #100
     button[8] = 0;
   button[7] = 1;
   #100
     button[7] = 0;
   button[6] = 1;
   #100
     button[6] = 0;
   star = 1;
   #100
     star = 0;
	#200
	  open_button = 1;
	#400
	  open_button = 0;
	#500
	  close_sensor = 1;
	#100
	  close_sensor = 0;
	#300
	  open_button = 1;
	#400
	  open_button = 0;
	#100
	  close_sensor = 1;
	#100
	  close_sensor = 0;
   #1000
     $finish;
     end // initial begin
endmodule // top_module_tb
