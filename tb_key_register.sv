// $Id: $
// File name:   tb_key_register.sv
// Created:     11/19/2017
// Author:      Sahil Bhalla
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_key_register.sv

`timescale 1ns / 100ps

module tb_key_register
  ();
   localparam CLK_PERIOD = 2.5;
   reg tb_clk;
   always
     begin
	tb_clk = 1'b0;
	#(CLK_PERIOD/2.0);
	tb_clk = 1'b1;
	#(CLK_PERIOD/2.0);
     end
   reg tb_n_rst;
   reg [3:0] tb_iter_in;
   reg [3:0] tb_iter_out;
   reg 	     tb_key_reg_load;
   reg [127:0] tb_key_out;
   reg [127:0] tb_process_key;
   
   key_register DUT
     (
      .clk(tb_clk),
      .n_rst(tb_n_rst),
      .iter_in(tb_iter_in),
      .iter_out(tb_iter_out),
      .key_reg_load(tb_key_reg_load),
      .key_out(tb_key_out),
      .process_key(tb_process_key)
      );

   initial
     begin
	//Test 0: Device Reset
	tb_key_out = 128'd0;
	tb_iter_in = 4'd0;
	tb_iter_out = 4'd0;
	tb_key_reg_load = 1'b0;
	tb_n_rst = 1'b0;
	@(negedge tb_clk)
	tb_n_rst = 1'b1;
	@(negedge tb_clk);
	
	//Test 1: Simple Storage
	$info("Test 1: Simple Storage");
	tb_key_out = 128'd69;
	tb_iter_in = 4'd0;
	tb_iter_out = 4'd0;
	tb_key_reg_load = 1'b1;
	@(negedge tb_clk);
	if(tb_process_key == 128'd69)
	  $info("TEST CASE 1: PASSED");
	else
	  $error("TEST CASE 1: FAILED");

	//Test 2: Simple Storage Diff Location
	$info("Test 2: Simple Storage Diff Location");
	tb_key_out = 128'd74;
	tb_iter_in = 4'd4;
	tb_iter_out = 4'd4;
	tb_key_reg_load = 1'b1;
	@(negedge tb_clk);
	if(tb_process_key == 128'd74)
	  $info("TEST CASE 2: PASSED");
	else
	  $error("TEST CASE 2: FAILED");

	//Test 3: Check Recall
	$info("Test 3: Check Recall");
	tb_key_out = 128'd0;
	tb_iter_in = 4'd0;
	tb_iter_out = 4'd0;
	tb_key_reg_load = 1'b0;
	#1;
	@(negedge tb_clk);
	if(tb_process_key == 128'd69)
	  $info("TEST CASE 3: PASSED");
	else
	  $error("TEST CASE 3: FAILED");

	//Test 4: Check Overwrite
	$info("Test 4: Check Overwrite");
	tb_key_out = 128'd74;
	tb_iter_in = 4'd0;
	tb_iter_out = 4'd0;
	tb_key_reg_load = 1'b1;
	#1;
	@(negedge tb_clk);
	if(tb_process_key == 128'd74)
	  $info("TEST CASE 4: PASSED");
	else
	  $error("TEST CASE 4: FAILED");
	
     end // initial begin
endmodule // tb_key_register
	
