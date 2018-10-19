// $Id: $
// File name:   data_register.sv
// Created:     12/3/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: data_register.sv

module data_register
  (
   input wire clk,
   input wire n_rst,
   input wire data_load,
   input wire [127:0] data_in,
   output reg [127:0] data_out
   );

   reg [127:0] 	       data_next;
   
   always_ff @ (posedge clk, negedge n_rst)
     begin
	if(n_rst == 1'b0)
	  begin
	     data_out <= '0;
	  end
	else
	  begin
	     data_out <= data_next;
	  end
     end // always_ff @

   always_comb
     begin
	data_next = data_out;
	if(data_load == 1'b1)
	  begin
	     data_next = data_in;
	  end
     end
endmodule // data_regsiter
