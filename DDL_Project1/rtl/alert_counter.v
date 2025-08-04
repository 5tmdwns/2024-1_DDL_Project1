module alert_counter(/*AUTOARG*/
   // Outputs
   alert, alert_off,
   // Inputs
   enable, clk
   );
   input enable, clk;
   output reg alert, alert_off;

   reg [2:0]  cnt;

   always @ (posedge clk)
     begin
	if(enable == 1)
	  begin
	     if(cnt == 5)
	       begin
		  cnt <= 0;
		  alert <= 0;
		  alert_off <= 1;
	       end

	     else if((enable == 1) && (alert_off == 1))
	       begin
		  cnt <= 0;
		  alert <= 0;
		  alert_off <= 1;
	       end
	     
	     else
	       begin
		  cnt <= cnt + 1;
		  alert <= 1;
	       end // else: !if(cnt == 5)
	  end // if (enable == 1)
	     
	else
	  begin
	     cnt <= 0;
	     alert <= 0;
	     alert_off <= 0;
	  end // else: !if(enable)
     end // always @ (posedge clk)
endmodule // alert_counter
