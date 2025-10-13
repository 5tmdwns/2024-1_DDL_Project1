module PW_RESET(/*AUTOARG*/
   // Outputs
   PW, PW_TEMP,
   // Inputs
   CLK, CORRECT, PW_TEMP_RESET, HASH, STAR, RESET, DISPLAY
   );
   input			CLK, CORRECT, PW_TEMP_RESET, HASH, STAR, RESET; //HASH=#, STAR=*, RESET
   input [15:0]			DISPLAY;
   output reg [15:0]		PW, PW_TEMP;
   parameter			INIT = 0;
   parameter			PAR_PW = 1;
   parameter			PAR_PW_TEMP = 2;
   
   reg [2:0]			STATE;
   
   always @(posedge CLK) begin
      if(RESET) begin
	 PW = 0;
	 PW_TEMP <= 16'bz;
	 STATE = 0;
      end
      else if (PW_TEMP_RESET) PW_TEMP <= 16'bz;
      
      else begin
	 case(STATE)
	   INIT: begin
	      if(CORRECT && STAR)
		begin
		   STATE = PW;
		end
	      else if (CORRECT && HASH)
		begin
		   STATE = PAR_PW_TEMP;
		end
	      else STATE = INIT;
	   end
	   
	   PW: begin
	      PW <= DISPLAY;
	      if(STAR) begin
		 STATE = INIT;
	      end
	      else STATE = PAR_PW;
	   end // case: PW
	   
	   PW_TEMP: begin
	      PW_TEMP <= DISPLAY;
	      if(HASH) begin
		 STATE = INIT;
	      end
	      else STATE = PAR_PW_TEMP;
	   end // case: PW_TEMP
	   
	 endcase // case (STATE)
      end // else: !if(PW_TEMP_RESET)
   end // always @ (posedge CLK)
endmodule // PW_RESET
