`timescale 10ms/10ms
`include "alert_counter.v"

module alert_counter_tb;
   reg enable, clk;
   wire	alert, alert_off;

   alert_counter i0(
		    .enable(enable),
		    .clk(clk),
		    .alert(alert),
		    .alert_off(alert_off)
		    );

   always
     #25 clk = ~clk;

   initial
     begin
	$dumpfile("alert_counter_tb.vcd");
	$dumpvars(0, alert_counter_tb);
	enable = 0;
	clk = 0;

	#100
	  enable = 1;
	#600
	  enable = 0;
	  $finish;
     end
endmodule // alert_counter_tb
