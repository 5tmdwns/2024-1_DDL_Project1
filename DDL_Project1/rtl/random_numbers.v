module random_numbers(/*AUTOARG*/
   // Outputs
   o_num,
   // Inputs
   i_num, star
   );
   input [9:0] i_num;
   input       star;
   output [9:0]	o_num;

   integer	a;
   wire [9:0]	mid_num;

   assign mid_num = {i_num[1],i_num[3],i_num[7],i_num[9],i_num[2],i_num[0],i_num[8],i_num[5],i_num[6],i_num[4]};
   assign o_num = (mid_num << a | mid_num >> (10-a));

   always @(posedge star) begin
         a <= $urandom_range(0, 9);
   end
endmodule // random_numbers
