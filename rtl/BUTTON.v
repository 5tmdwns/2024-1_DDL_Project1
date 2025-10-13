module BUTTON(/*AUTOARG*/
   // Outputs
   O_BUTTON, O_STAR, O_HASH,
   // Inputs
   CLK, STAR, HASH, BUTTON
   );
   input CLK, STAR, HASH;
   input [9:0] BUTTON;
   output [9:0] O_BUTTON;
   output   O_STAR,O_HASH; 

   reg [9:0]   R1, R2;
   reg R3, R4, R5, R6;

   always@ (posedge CLK)
     begin
   R1 <= BUTTON;
   R2 <= R1;
   R3 <= STAR;
   R4 <= R3;
   R5 <= HASH;
   R6 <= R5;
     end

   assign O_BUTTON = ~R2 & R1;
   assign O_STAR = ~R4 & R3;
   assign O_HASH = ~R6 & R5;
endmodule // BUTTON
