module TOP(/*AUTOARG*/
   // Outputs
   RANDOM_BUTTON, DISPLAY, ALERT, UNLOCK,
   // Inputs
   BUTTON, STAR, HASH, CLK, OPEN_BUTTON, CLOSE_SENSOR, RESET
   );
   input [9:0] BUTTON;
   input       STAR; // * (RESET)
   input       HASH; // # (temp_RESET)
   input       CLK, OPEN_BUTTON, CLOSE_SENSOR, RESET;
   output [9:0]   RANDOM_BUTTON;
   output [15:0] DISPLAY;
   output    ALERT, UNLOCK;

   reg       CLOSE = 1'b0;
   reg       PREV_CLOSE_SENSOR = 1'b0;
   reg       OPEN = 1'b0;
   reg       PREV_OPEN_BUTTON = 1'b0;
   reg       ALWAYS_OPEN = 1'b0;
   reg [2:0]    ALWAYS_OPEN_CTRL = 0;
   reg [2:0]    PREV_ALWAYS_OPEN_CTRL;
   
   wire [9:0]    W_BUTTON, O_BUTTON, TEMP_BUTTON;
   wire       W_CORRECT, W_PW_TEMP_RESET, W_ALERT, W_ALERT_OFF, O_STAR, O_HASH;
   wire [15:0]    W_PW, W_PW_TEMP, W_DISPLAY;

   always @ (posedge CLK)
     begin
	if(PREV_ALWAYS_OPEN_CTRL == ALWAYS_OPEN_CTRL)
	  ALWAYS_OPEN_CTRL <= 0;
	if(OPEN_BUTTON == 1 && UNLOCK == 1)
	  begin
      ALWAYS_OPEN_CTRL <= ALWAYS_OPEN_CTRL + 1;
        if(ALWAYS_OPEN_CTRL > 6)
          begin
		        ALWAYS_OPEN <= ~ALWAYS_OPEN;
		        ALWAYS_OPEN_CTRL <= 0;
          end
	  end // if (OPEN_BUTTON == 1)
	PREV_ALWAYS_OPEN_CTRL <= ALWAYS_OPEN_CTRL;
	
	PREV_CLOSE_SENSOR <= CLOSE_SENSOR;
	PREV_OPEN_BUTTON <= OPEN_BUTTON;
	if ((CLOSE_SENSOR == 1'b1) && (PREV_CLOSE_SENSOR == 1'b0))
	  begin
             CLOSE <= ~CLOSE;
             if (OPEN == 1)
               OPEN <= ~OPEN;
             else
               OPEN <= OPEN;
	  end
	else if ((OPEN_BUTTON == 1'b1) && (PREV_OPEN_BUTTON == 1'b0))
	  begin
             OPEN <= ~OPEN;
             if(CLOSE == 1)
               CLOSE <= ~CLOSE;
             else
               CLOSE <= CLOSE;
	  end
	else if ((W_CORRECT == 1'b1) && (CLOSE == 1'b1))
	  begin
             CLOSE <= ~CLOSE;
	  end
	else
	  begin
             OPEN <= OPEN;
             CLOSE <= CLOSE;
	  end
     end // always @ (posedge CLK)

   assign TEMP_BUTTON[9:0] = BUTTON[9:0];
   assign DISPLAY[15:0] = W_DISPLAY[15:0];
   assign UNLOCK = ALWAYS_OPEN||(~CLOSE && (W_CORRECT || OPEN));

   BUTTON 
	BUTTON_INST(
        // Outputs
        .O_BUTTON         (O_BUTTON[9:0]),
        .O_STAR         (O_STAR),
        .O_HASH         (O_HASH),
        // Inputs
        .CLK         (CLK),
        .STAR         (STAR),
        .HASH         (HASH),
        .BUTTON         (TEMP_BUTTON[9:0]));
   
   DISPLAY 
	DISPLAY_INST (
          .BUTTON(O_BUTTON[9:0]),
          .STAR(O_STAR),
          .HASH(O_HASH),
          .CLK(CLK),
          .DISPLAY(W_DISPLAY[15:0])
          );

   RANDOM_NUMBERS 
	RANDOM_NUMBERS_INST (
            .I_NUM(O_BUTTON[9:0]),
            .STAR(O_STAR),
            .O_NUM(RANDOM_BUTTON[9:0])
            );

   COMPARE 
	COMPARE_INST (
          .DISPLAY(W_DISPLAY[15:0]),
          .STAR(O_STAR),
          .CLK(CLK),
          .PW(W_PW[15:0]),
          .PW_TEMP(W_PW_TEMP[15:0]),
          .CORRECT(W_CORRECT),
          .PW_TEMP_RESET(W_PW_TEMP_RESET),
          .ALERT(W_ALERT),
          .ALERT_OFF(W_ALERT_OFF),
          .CLOSE_SENSOR(CLOSE_SENSOR)
          );

   PW_RESET 
	PW_RESET_INST (
      .DISPLAY(W_DISPLAY[15:0]),
      .HASH(O_HASH),
      .STAR(O_STAR),
      .RESET(RESET),
      .CLK(CLK),
      .CORRECT(W_CORRECT),
      .PW_TEMP_RESET(W_PW_TEMP_RESET),
      .PW(W_PW[15:0]),
      .PW_TEMP(W_PW_TEMP[15:0])
      );

   ALERT_COUNTER 
	ALERT_COUNTER_INST (
           .ENABLE(W_ALERT),
           .ALERT(ALERT),
           .CLK(CLK),
           .ALERT_OFF(W_ALERT_OFF)
           );

endmodule // TOP
