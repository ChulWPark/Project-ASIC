// $Id: $
// File name:   tb_sr.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_sr.sv

`timescale 1ns / 100ps

module tb_sr
  ();

   reg tb_sr_enable;
   reg [127:0] tb_data;
   reg [127:0] tb_key;
   reg [127:0] tb_sr_out;
   reg [127:0] allzero;
   reg [127:0] allone;
   
   sr DUT
     (
      .sr_enable(tb_sr_enable),
      .data(tb_data),
      .key(tb_key),
      .sr_out(tb_sr_out)
      );

   initial
     begin
	allzero = '0;
	#1;
	allone = '1;
	#1;

	tb_sr_enable = 1'b1;
	#1;
	// TEST CASE 1 (all 0's)
        tb_data = allzero;
	#1;
	if(tb_sr_out == allzero)
	  $info("TEST CASE 1 (all 0's): PASSED");
	else
	  $error("TEST CASE 1 (all 0's): FAILED");

	// TEST CASE 2 (all 1's)
	tb_data = allone;
	#1;
	if(tb_sr_out == allone)
	  $info("TEST CASE 2 (all 1's): PASSED");
	else
	  $error("TEST CASE 2 (all 1's): FAILED");

	// TEST CASE 3 (customized)
	tb_data[127:96] = 32'b00000001000000100000010000001000;
	tb_data[95:64] = 32'b00000000100000001100000011100000; 
	tb_data[63:32] = 32'b11110000111110001111110011111110;
	tb_data[31:0] = 32'b10101010010101011100110000110011;
	#1;
	if((tb_sr_out[127:96] == tb_data[127:96]) && (tb_sr_out[95:64] == 32'b10000000110000001110000000000000) && (tb_sr_out[63:32] == 32'b11111100111111101111000011111000) && (tb_sr_out[31:0] == 32'b00110011101010100101010111001100))
	  $info("TEST CASE 3 (customized) : PASSED");
	else
	  $error("TEST CASE 3 (customized) : FAILED");

     end

endmodule // tb_sr
