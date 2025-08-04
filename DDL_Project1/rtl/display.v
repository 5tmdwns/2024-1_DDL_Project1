module display(/*AUTOARG*/
   // Outputs
   display,
   // Inputs
   button, star, hash, clk
   );
   input [9:0] button;
   input       star, hash;
   input       clk;
   output reg [15:0] display;
   
   always@ (posedge clk)
     begin
	
   if (star | hash) // *(reset), #
     begin
	display <= 16'd0;
     end
	
   else
     begin
	if (button[0])
	  begin
	     display <= display * 10 + 0;
	  end
	else if (button[1])
	  begin
	     display <= display * 10 + 1;
	  end
	else if (button[2])
	  begin
	     display <= display * 10 + 2;
	  end
	else if (button[3])
	  begin
	     display <= display * 10 + 3;
	  end
	else if (button[4])
	  begin
	     display <= display * 10 + 4;
	  end
	else if (button[5])
	  begin
	     display <= display * 10 + 5;
	  end
	else if (button[6])
	  begin
	     display <= display * 10 + 6;
	  end
	else if (button[7])
	  begin
	     display <= display * 10 + 7;
	  end
	else if (button[8])
	  begin
	     display <= display * 10 + 8;
	  end
	else if (button[9])
	  begin
	     display <= display * 10 + 9;
	  end
	else
	  begin
	     display <= display;
	  end
     end // else: !if(star)
     end // always@ (posedge clk)
endmodule // display

	
