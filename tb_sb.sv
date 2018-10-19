// $Id: $
// File name:   tb_sb.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_sb.sv

`timescale 1ns / 100ps

module tb_sb
  ();

   reg tb_sb_enable;
   reg [127:0] tb_data;
   reg [127:0] tb_key;
   reg [127:0] tb_sb_out;

   sb DUT
     (
      .sb_enable(tb_sb_enable),
      .data(tb_data),
      .key(tb_key),
      .sb_out(tb_sb_out)
      );

   initial
     begin
	tb_sb_enable = 1'b1;
	#1;
	// TEST CASE 1
	tb_data = '1;
	#1;
	if(tb_sb_out[127:120] == 8'h16)
	  $info("TEST CASE 1: PASSED");
	else
	  $error("TEST CASE 1: FAILED");

	// TEST CASE 2
	tb_data = '0;
	#1;
	if(tb_sb_out[127:120] == 8'h63)
	  $info("TEST CASE 2: PASSED");
	else
	  $error("TEST CASE 2: FAILED");
	
     end
endmodule // tb_sb
