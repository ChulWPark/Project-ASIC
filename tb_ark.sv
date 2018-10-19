// $Id: $
// File name:   tb_ark.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_ark.sv

`timescale 1ns / 100ps

module tb_ark
  ();

   reg tb_ark_enable;
   reg [127:0] tb_data;
   reg [127:0] tb_key;
   reg [127:0] tb_ark_out;
   reg [127:0] all_zero;
   reg [127:0] all_one;
   
   ark DUT
     (
      .ark_enable(tb_ark_enable),
      .data(tb_data),
      .key(tb_key),
      .ark_out(tb_ark_out)
      );

   initial
     begin
	all_zero = '0;
	#1;
	all_one = '1;
	#1;
	tb_ark_enable = 1'b1;
	#1;
	//TEST CASE 1: data all 0s, key all 0s
	tb_data = '0;
	#1;
	tb_key = '0;
	#1;
	if(tb_ark_out == all_zero)
	  $info("TEST CASE1 (data all 0s ^ key all 0s) : PASSED");
	else
	  $error("TEST CASE1 (data all 0s ^ key all 0s) : FAILED");
	//TEST CASE 2: data all 1s, key all 1s
	tb_data = '1;
	#1;
	tb_key = '1;
	#1;
	if(tb_ark_out == all_zero)
	  $info("TEST CASE2 (data all 1s ^ key all 1s): PASSED");
	else
	  $error("TEST CASE2 (data all 1s ^ key all 1s): FAILED");
	//TEST CASE 3: data all 0s, key all 1s
	tb_data = '0;
	#1;
	tb_key = '1;
	#1;
	if(tb_ark_out == all_one)
	  $info("TEST CASE3 (data all 0s ^ key all 1s): PASSED");
	else
	  $error("TEST CASE3 (data all 0s ^ key all 1s): FAILED");
	//TEST CASE 4: data all 1s, key all 0s
	tb_data = '1;
	#1;
	tb_key = '0;
	#1;
	if(tb_ark_out == all_one)
	  $info("TEST CASE4 (data all 1s ^ key all 0s): PASSED");
	else
	  $error("TEST CASE4 (data all 1s ^ key all 0s): FAILED");
     end
   
endmodule // tb_ark

   
