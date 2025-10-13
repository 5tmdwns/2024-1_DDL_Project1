module ALERT_COUNTER(/*AUTOARG*/
   // Outputs
   ALERT, ALERT_OFF,
   // Inputs
   ENABLE, CLK
   );
   input ENABLE, CLK;
   output reg ALERT, ALERT_OFF;

   reg [2:0]  CNT;

   always @ (posedge CLK)
     begin
	if(ENABLE == 1)
	  begin
	     if(CNT == 5)
	       begin
		  CNT <= 0;
		  ALERT <= 0;
		  ALERT_OFF <= 1;
	       end

	     else if((ENABLE == 1) && (ALERT_OFF == 1))
	       begin
		  CNT <= 0;
		  ALERT <= 0;
		  ALERT_OFF <= 1;
	       end
	     
	     else
	       begin
		  CNT <= CNT + 1;
		  ALERT <= 1;
	       end // else: !if(CNT == 5)
	  end // if (ENABLE == 1)
	     
	else
	  begin
	     CNT <= 0;
	     ALERT <= 0;
	     ALERT_OFF <= 0;
	  end // else: !if(ENABLE)
     end // always @ (posedge CLK)
endmodule // ALERT_COUNTER
