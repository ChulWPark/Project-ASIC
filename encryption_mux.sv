// $Id: $
// File name:   encryption_mux.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: encryption_mux.sv

module encryption_mux
  (
   input wire [1:0] process_output,
   input wire [127:0] ark_out,
   input wire [127:0] sb_out,
   input wire [127:0] mc_out,
   input wire [127:0] sr_out,
   output reg [127:0] process_out_data
   );

   always_comb
     begin
	if(process_output == 2'b00)
	  begin
	     process_out_data = ark_out;
	  end
	else if(process_output == 2'b01)
	  begin
	     process_out_data = sb_out;
	  end
	else if(process_output == 2'b10)
	  begin
	     process_out_data = mc_out;
	  end
	else // if(process_output == 2'b11)
	  begin
	     process_out_data = sr_out;
	  end
     end // always_comb

endmodule // encryption_mux
