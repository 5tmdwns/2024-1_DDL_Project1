module COMPARE(/*AUTOARG*/
   // Outputs
   CORRECT, ALERT, PW_TEMP_RESET,
   // Inputs
   STAR, CLK, ALERT_OFF, CLOSE_SENSOR, PW, PW_TEMP, DISPLAY
   );
   input       STAR, CLK, ALERT_OFF,CLOSE_SENSOR;
   input [15:0]	PW, PW_TEMP, DISPLAY;
   output	CORRECT, ALERT, PW_TEMP_RESET;
   integer	WRONG = 0;
   
   reg			ALERT, CORRECT, PW_TEMP_RESET, UNLOCK;

   always@ (posedge CLK)
     begin
	if (STAR) // '*'button press
	  begin
	     if(DISPLAY == PW)
	       begin
		  CORRECT <= 1;
		  WRONG <= 0;
	       end
	     else if(DISPLAY == PW_TEMP)
	       begin
		  CORRECT <= 1;
		  WRONG <= 0;
		  PW_TEMP_RESET <= 1; //temp password reset
	       end
	     else if(CORRECT == 0)
	       begin
		  if ((DISPLAY != PW) || (DISPLAY != PW_TEMP))
		    begin
		       WRONG = WRONG + 1;
		       if(WRONG == 5)
			 begin
			    ALERT <= 1;
			    WRONG <= 0;
			 end
		    end
	       end // if (UNLOCK == 0)
	  end // if (STAR)
	
	else
	  begin
	     if (ALERT_OFF == 1)
	       ALERT <= 0;
	     else if (CLOSE_SENSOR == 1)
	       begin
		  CORRECT <= 0;
		  PW_TEMP_RESET <= 0;
	       end
	  end // else: !if(STAR)
     end // always@ (posedge CLK)
endmodule // COMPARE
