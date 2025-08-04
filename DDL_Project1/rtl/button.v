module button(/*AUTOARG*/
   // Outputs
   o_button, o_star, o_hash,
   // Inputs
   clk, star, hash, button
   );
   input clk, star, hash;
   input [9:0] button;
   output [9:0] o_button;
   output   o_star,o_hash; 

   reg [9:0]   r1, r2;
   reg r3, r4, r5, r6;

   always@ (posedge clk)
     begin
   r1 <= button;
   r2 <= r1;
   r3 <= star;
   r4 <= r3;
   r5 <= hash;
   r6 <= r5;
     end

   assign o_button = ~r2 & r1;
   assign o_star = ~r4 & r3;
   assign o_hash = ~r6 & r5;
endmodule // button
