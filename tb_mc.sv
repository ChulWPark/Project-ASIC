// $Id: $
// File name:   tb_mc.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_mc.sv

`timescale 1ns / 100ps

module tb_mc
  ();

   reg tb_mc_enable;
   reg [127:0] tb_data;
   reg [127:0] tb_key;
   reg [127:0] tb_mc_out;

   mc DUT
     (
      .mc_enable(tb_mc_enable),
      .data(tb_data),
      .key(tb_key),
      .mc_out(tb_mc_out)
      );

   initial
     begin
	tb_mc_enable = 1'b1;
	#1;
	tb_data[127:120] = 8'hD4;
	#1;
      	tb_data[95:88] = 8'hBF;
	#1;
	tb_data[63:56] = 8'h5D;
	#1;
	tb_data[31:24] = 8'h30;
	#1;
	tb_data[119:112] = 8'hDB;
	#1;
      	tb_data[87:80] = 8'h13;
	#1;
	tb_data[55:48] = 8'h53;
	#1;
	tb_data[23:16] = 8'h45;
	#1;
	tb_data[111:104] = 8'hF2;
	#1;
      	tb_data[79:72] = 8'h0A;
	#1;
	tb_data[47:40] = 8'h22;
	#1;
	tb_data[15:8] = 8'h5C;
	#1;
	tb_data[103:96] = 8'h2D;
	#1;
      	tb_data[71:64] = 8'h26;
	#1;
	tb_data[39:32] = 8'h31;
	#1;
	tb_data[7:0] = 8'h4C;
	#1;
	
	// TEST CASE 1 (D4)
	if(tb_mc_out[127:120] == 8'h04)
	  $info("TEST CASE 1 (D4): PASSED");
	else
	  $error("TEST CASE 1 (D4): FAILED");
	
	// TEST CASE 2 (BF)
	if(tb_mc_out[95:88] == 8'h66)
	  $info("TEST CASE 2 (BF): PASSED");
	else
	  $error("TEST CASE 2 (BF): FAILED");
	
	// TEST CASE 3 (5D)
	if(tb_mc_out[63:56] == 8'h81)
	  $info("TEST CASE 3 (5D): PASSED");
	else
	  $error("TEST CASE 3 (5D): FAILED");
	
	// TEST CASE 4 (30)
	if(tb_mc_out[31:24] == 8'hE5)
	  $info("TEST CASE 4 (30): PASSED");
	else
	  $error("TEST CASE 4 (30): FAILED");
	
	// TEST CASE 5 (DB)
	if(tb_mc_out[119:112] == 8'h8E)
	  $info("TEST CASE 5 (DB): PASSED");
	else
	  $error("TEST CASE 5 (DB): FAILED");
	
	// TEST CASE 6 (13)
	if(tb_mc_out[87:80] == 8'h4D)
	  $info("TEST CASE 6 (13): PASSED");
	else
	  $error("TEST CASE 6 (13): FAILED");
	
	// TEST CASE 7 (53)
	if(tb_mc_out[55:48] == 8'hA1)
	  $info("TEST CASE 7 (53): PASSED");
	else
	  $error("TEST CASE 7 (53): FAILED");
	
	// TEST CASE 8 (45)
	if(tb_mc_out[23:16] == 8'hBC)
	  $info("TEST CASE 8 (45): PASSED");
	else
	  $error("TEST CASE 8 (45): FAILED");
	
	// TEST CASE 9 (F2)
	if(tb_mc_out[111:104] == 8'h9F)
	  $info("TEST CASE 9 (F2): PASSED");
	else
	  $error("TEST CASE 9 (F2): FAILED");
	
	// TEST CASE 10 (0A)
	if(tb_mc_out[79:72] == 8'hDC)
	  $info("TEST CASE 10 (0A): PASSED");
	else
	  $error("TEST CASE 10 (0A): FAILED");
	
	// TEST CASE 11 (22)
	if(tb_mc_out[47:40] == 8'h58)
	  $info("TEST CASE 11 (22): PASSED");
	else
	  $error("TEST CASE 11 (22): FAILED");
	
	// TEST CASE 12 (5C)
	if(tb_mc_out[15:8] == 8'h9D)
	  $info("TEST CASE 12 (5C): PASSED");
	else
	  $error("TEST CASE 12 (5C): FAILED");
	
	// TEST CASE 13 (2D)
	if(tb_mc_out[103:96] == 8'h4D)
	  $info("TEST CASE 13 (2D): PASSED");
	else
	  $error("TEST CASE 13 (2D): FAILED");
	
	// TEST CASE 14 (26)
	if(tb_mc_out[71:64] == 8'h7E)
	  $info("TEST CASE 14 (26): PASSED");
	else
	  $error("TEST CASE 14 (26): FAILED");
	
	// TEST CASE 15 (31)
	if(tb_mc_out[39:32] == 8'hBD)
	  $info("TEST CASE 15 (31): PASSED");
	else
	  $error("TEST CASE 15 (31): FAILED");
	
	// TEST CASE 16 (4C)
	if(tb_mc_out[7:0] == 8'hF8)
	  $info("TEST CASE 16 (4C): PASSED");
	else
	  $error("TEST CASE 16 (4C): FAILED");

     end // initial begin

endmodule // tb_mc
