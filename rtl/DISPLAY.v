module DISPLAY(/*AUTOARG*/
   // Outputs
   DISPLAY,
   // Inputs
   BUTTON, STAR, HASH, CLK
   );
   input [9:0] BUTTON;
   input       STAR, HASH;
   input       CLK;
   output reg [15:0] DISPLAY;
   
   always@ (posedge CLK)
     begin
	
   if (STAR | HASH) // *(reset), #
     begin
	DISPLAY <= 16'd0;
     end
	
   else
     begin
	if (BUTTON[0])
	  begin
	     DISPLAY <= DISPLAY * 10 + 0;
	  end
	else if (BUTTON[1])
	  begin
	     DISPLAY <= DISPLAY * 10 + 1;
	  end
	else if (BUTTON[2])
	  begin
	     DISPLAY <= DISPLAY * 10 + 2;
	  end
	else if (BUTTON[3])
	  begin
	     DISPLAY <= DISPLAY * 10 + 3;
	  end
	else if (BUTTON[4])
	  begin
	     DISPLAY <= DISPLAY * 10 + 4;
	  end
	else if (BUTTON[5])
	  begin
	     DISPLAY <= DISPLAY * 10 + 5;
	  end
	else if (BUTTON[6])
	  begin
	     DISPLAY <= DISPLAY * 10 + 6;
	  end
	else if (BUTTON[7])
	  begin
	     DISPLAY <= DISPLAY * 10 + 7;
	  end
	else if (BUTTON[8])
	  begin
	     DISPLAY <= DISPLAY * 10 + 8;
	  end
	else if (BUTTON[9])
	  begin
	     DISPLAY <= DISPLAY * 10 + 9;
	  end
	else
	  begin
	     DISPLAY <= DISPLAY;
	  end
     end // else: !if(STAR)
     end // always@ (posedge CLK)
endmodule // DISPLAY

	
