module compare(/*AUTOARG*/
   // Outputs
   correct, alert, pw_temp_reset,
   // Inputs
   star, clk, alert_off, close_sensor, pw, pw_temp, display
   );
   input       star, clk, alert_off,close_sensor;
   input [15:0]	pw, pw_temp, display;
   output	correct, alert, pw_temp_reset;
   integer	wrong = 0;
   
   reg			alert, correct, pw_temp_reset, unlock;

   always@ (posedge clk)
     begin
	if (star) // '*'button press
	  begin
	     if(display == pw)
	       begin
		  correct <= 1;
		  wrong <= 0;
	       end
	     else if(display == pw_temp)
	       begin
		  correct <= 1;
		  wrong <= 0;
		  pw_temp_reset <= 1; //temp password reset
	       end
	     else if(correct == 0)
	       begin
		  if ((display != pw) || (display != pw_temp))
		    begin
		       wrong = wrong + 1;
		       if(wrong == 5)
			 begin
			    alert <= 1;
			    wrong <= 0;
			 end
		    end
	       end // if (unlock == 0)
	  end // if (star)
	
	else
	  begin
	     if (alert_off == 1)
	       alert <= 0;
	     else if (close_sensor == 1)
	       begin
		  correct <= 0;
		  pw_temp_reset <= 0;
	       end
	  end // else: !if(star)
     end // always@ (posedge clk)
endmodule // compare
