module top_module(/*AUTOARG*/
   // Outputs
   random_button, display, alert, unlock,
   // Inputs
   button, star, hash, clk, open_button, close_sensor, reset
   );
   input [9:0] button;
   input       star; // * (reset)
   input       hash; // # (temp_reset)
   input       clk, open_button, close_sensor, reset;
   output [9:0]   random_button;
   output [15:0] display;
   output    alert, unlock;

   reg       close = 1'b0;
   reg       prev_close_sensor = 1'b0;
   reg       open = 1'b0;
   reg       prev_open_button = 1'b0;
   reg       always_open = 1'b0;
   reg [2:0]    always_open_ctrl = 0;
   reg [2:0]    prev_always_open_ctrl;
   
   wire [9:0]    w_button, o_button, temp_button;
   wire       w_correct, w_pw_temp_reset, w_alert, w_alert_off, o_star, o_hash;
   wire [15:0]    w_pw, w_pw_temp, w_display;

   always @ (posedge clk)
     begin
	if(prev_always_open_ctrl == always_open_ctrl)
	  always_open_ctrl <= 0;
	if(open_button == 1 && unlock == 1)
	  begin
      always_open_ctrl <= always_open_ctrl + 1;
        if(always_open_ctrl > 6)
          begin
		        always_open <= ~always_open;
		        always_open_ctrl <= 0;
          end
	  end // if (open_button == 1)
	prev_always_open_ctrl <= always_open_ctrl;
	
	prev_close_sensor <= close_sensor;
	prev_open_button <= open_button;
	if ((close_sensor == 1'b1) && (prev_close_sensor == 1'b0))
	  begin
             close <= ~close;
             if (open == 1)
               open <= ~open;
             else
               open <= open;
	  end
	else if ((open_button == 1'b1) && (prev_open_button == 1'b0))
	  begin
             open <= ~open;
             if(close == 1)
               close <= ~close;
             else
               close <= close;
	  end
	else if ((w_correct == 1'b1) && (close == 1'b1))
	  begin
             close <= ~close;
	  end
	else
	  begin
             open <= open;
             close <= close;
	  end
     end // always @ (posedge clk)

   assign temp_button[9:0] = button[9:0];
   assign display[15:0] = w_display[15:0];
   assign unlock = always_open||(~close && (w_correct || open));

   button i0(
        // Outputs
        .o_button         (o_button[9:0]),
        .o_star         (o_star),
        .o_hash         (o_hash),
        // Inputs
        .clk         (clk),
        .star         (star),
        .hash         (hash),
        .button         (temp_button[9:0]));
   
   display i1 (
          .button(o_button[9:0]),
          .star(o_star),
          .hash(o_hash),
          .clk(clk),
          .display(w_display[15:0])
          );

   random_numbers i2 (
            .i_num(o_button[9:0]),
            .star(o_star),
            .o_num(random_button[9:0])
            );

   compare i3 (
          .display(w_display[15:0]),
          .star(o_star),
          .clk(clk),
          .pw(w_pw[15:0]),
          .pw_temp(w_pw_temp[15:0]),
          .correct(w_correct),
          .pw_temp_reset(w_pw_temp_reset),
          .alert(w_alert),
          .alert_off(w_alert_off),
          .close_sensor(close_sensor)
          );

   pw_reset i4 (
      .display(w_display[15:0]),
      .hash(o_hash),
      .star(o_star),
      .reset(reset),
      .clk(clk),
      .correct(w_correct),
      .pw_temp_reset(w_pw_temp_reset),
      .pw(w_pw[15:0]),
      .pw_temp(w_pw_temp[15:0])
      );

   alert_counter i5 (
           .enable(w_alert),
           .alert(alert),
           .clk(clk),
           .alert_off(w_alert_off)
           );

endmodule // top_module
