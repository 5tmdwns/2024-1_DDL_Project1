module RANDOM_NUMBERS(/*AUTOARG*/
   // Outputs
   O_NUM,
   // Inputs
   I_NUM, STAR
   );
   input [9:0] I_NUM;
   input       STAR;
   output [9:0]	O_NUM;

   integer	a;
   wire [9:0]	MID_NUM;

   assign MID_NUM = {I_NUM[1],I_NUM[3],I_NUM[7],I_NUM[9],I_NUM[2],I_NUM[0],I_NUM[8],I_NUM[5],I_NUM[6],I_NUM[4]};
   assign O_NUM = (MID_NUM << a | MID_NUM >> (10-a));

   always @(posedge STAR) begin
         a <= $urandom_range(0, 9);
   end
endmodule // RANDOM_NUMBERS
