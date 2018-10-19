// $Id: $
// File name:   key_register.sv
// Created:     11/19/2017
// Author:      Sahil Bhalla
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: key_register.sv

`timescale 1ns / 10ps

module key_register
  (
   input wire 	      clk,
   input wire 	      n_rst,
   input wire [3:0]   iter_in,
   input wire [3:0]   iter_out, 
   input wire 	      key_reg_load,
   input wire [127:0] key_out,
   output reg [127:0] process_key
   );

   reg [127:0] 	      key_new;
   reg [10:0] [127:0] key;

   assign process_key = key[iter_out];
   
   //REGISTER
   always_ff@(posedge clk, negedge n_rst)
	begin
	   if(n_rst == 1'b0)
	     key <= '0;
	   else
	     key[iter_in] <= key_new;
	end

   //COMBINATIONAL LOGIC
   always_comb
     begin
	key_new = key[iter_in];
	if(key_reg_load == 1'b1)
	  begin
	     key_new = key_out;
	  end
     end

endmodule
  
