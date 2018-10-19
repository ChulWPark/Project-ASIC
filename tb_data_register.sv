// $Id: $
// File name:   tb_data_register.sv
// Created:     12/3/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_data_register.sv

`timescale 1ns / 10ps

module tb_data_register
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
   reg tb_data_load;
   reg [127:0] tb_data_in;
   reg [127:0] tb_data_out;

   data_register DUT
     (
      .clk(tb_clk),
      .n_rst(tb_n_rst),
      .data_load(tb_data_load),
      .data_in(tb_data_in),
      .data_out(tb_data_out)
      );
   
   initial
     begin
	//RESET
	tb_data_load = 1'b0;
	tb_data_in = 128'd0;
	tb_n_rst = 1'b0;
	#1;
	tb_n_rst = 1'b1;
	#1;
	@(posedge tb_clk);
	
	// TEST CASE 1
	tb_data_load = 1'b1;
	tb_data_in = 128'd69;
	@(posedge tb_clk);
	#1;
	if(tb_data_out == 128'd69)
	  $info("TEST CASE 1: PASSED");
	else
	  $error("TEST CASE 1: FAILED");

	// TEST CASE 2
	tb_data_load = 1'b0;
	tb_data_in = 128'd74;
	@(posedge tb_clk);
	#1;
	if(tb_data_out == 128'd69)
	  $info("TEST CASE 2: PASSED");
	else
	  $error("TEST CASE 2: FAILED");

	// TEST CASE 2
	tb_data_load = 1'b1;
	@(posedge tb_clk);
	#1;
	if(tb_data_out == 128'd74)
	  $info("TEST CASE 3: PASSED");
	else
	  $error("TEST CASE 3: FAILED");
     
     end // initial begin

endmodule // tb_data_register
