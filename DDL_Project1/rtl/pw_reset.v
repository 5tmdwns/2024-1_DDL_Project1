module pw_reset(/*AUTOARG*/
   // Outputs
   pw, pw_temp,
   // Inputs
   clk, correct, pw_temp_reset, hash, star, reset, display
   );
   input			clk, correct, pw_temp_reset, hash, star, reset; //hash=#, star=*, reset
   input [15:0]			display;
   output [15:0]		pw, pw_temp;
   parameter			INIT = 0;
   parameter			PW = 1;
   parameter			PW_TEMP = 2;
   
   reg [2:0]			state;
   reg [15:0]		pw;
   reg [15:0]		pw_temp;
   
   always @(posedge clk) begin
      if(reset) begin
	 pw = 0;
	 pw_temp <= 16'bz;
	 state = 0;
      end
      else if (pw_temp_reset) pw_temp <= 16'bz;
      
      else begin
	 case(state)
	   INIT: begin
	      if(correct && star)
		begin
		   state = PW;
		end
	      else if (correct && hash)
		begin
		   state = PW_TEMP;
		end
	      else state = INIT;
	   end
	   
	   PW: begin
	      pw <= display;
	      if(star) begin
		 state = INIT;
	      end
	      else state = PW;
	   end // case: PW
	   
	   PW_TEMP: begin
	      pw_temp <= display;
	      if(hash) begin
		 state = INIT;
	      end
	      else state = PW_TEMP;
	   end // case: PW_temp
	   
	 endcase // case (state)
      end // else: !if(pw_temp_reset)
   end // always @ (posedge clk)
endmodule // pw_reset
