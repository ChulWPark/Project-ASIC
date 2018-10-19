// $Id: $
// File name:   ark.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: ark.sv

module ark
  (
   input wire ark_enable,
   input wire [127:0]  data,
   input wire [127:0]  key,
   output reg [127:0] ark_out
   );

   always_comb
     begin
	ark_out = '0;
	if(ark_enable == 1'b1)
	  begin
	     ark_out = data ^ key;
	  end
     end
   
endmodule // ark
