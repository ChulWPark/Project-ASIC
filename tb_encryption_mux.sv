// $Id: $
// File name:   tb_encryption_mux.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_encryption_mux.sv

`timescale 1ns / 100ps

module tb_encryption_mux
  ();

   reg [1:0] tb_process_output;
   reg [127:0] tb_ark_out;
   reg [127:0] tb_sb_out;
   reg [127:0] tb_mc_out;
   reg [127:0] tb_sr_out;
   reg [127:0] tb_process_out_data;

   encryption_mux DUT
     (
      .process_output(tb_process_output),
      .ark_out(tb_ark_out),
      .sb_out(tb_sb_out),
      .mc_out(tb_mc_out),
      .sr_out(tb_sr_out),
      .process_out_data(tb_process_out_data)
      );
   
   initial
     begin
	tb_ark_out = 128'd11;
	tb_sb_out = 128'd22;
	tb_mc_out = 128'd33;
	tb_sr_out = 128'd44;

	// TEST CASE 2 (checking 00 mode)
	tb_process_output = 2'b00;
	#1;
	if(tb_process_out_data == 128'd11)
	  $info("TEST CASE 2 (checking 00 mode) : PASSED");
	else
	  $error("TEST CASE 2 (checking 00 mode) : FAILED");
	
	// TEST CASE 3 (checking 01 mode)
	tb_process_output = 2'b01;
	#1;
	if(tb_process_out_data == 128'd22)
	  $info("TEST CASE 3 (checking 01 mode) : PASSED");
	else
	  $error("TEST CASE 3 (checking 01 mode) : FAILED");
	
	// TEST CASE 4 (checking 10 mode)
	tb_process_output = 2'b10;
	#1;
	if(tb_process_out_data == 128'd33)
	  $info("TEST CASE 4 (checking 10 mode) : PASSED");
	else
	  $info("TEST CASE 4 (checking 10 mode) : FAILED");
	
	// TEST CASE 5 (checking 11 mode)
	tb_process_output = 2'b11;
	#1;
	if(tb_process_out_data == 128'd44)
	  $info("TEST CASE 5 (checking 11 mode) : PASSED");
	else
	  $info("TEST CASE 5 (checking 11 mode) : FAILED)");

     end // initial begin

endmodule // tb_encryption_mux
	
	
