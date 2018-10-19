// $Id: $
// File name:   data_mux.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: data_mux.sv

module data_mux
  (
   input wire data_reg_input,
   input wire [127:0] ATD_parallel,
   input wire [127:0] process_out_data,
   output reg [127:0] data_reg_in
   );

   always_comb
     begin
	if(data_reg_input == 1'b0)
	  begin
	     data_reg_in = ATD_parallel;
	  end
	else // if(data_reg_input == 1'b1)
	  begin
	     data_reg_in = process_out_data;
	  end
     end // always_comb

endmodule // data_mux
	     
   
