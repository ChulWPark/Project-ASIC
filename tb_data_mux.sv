// $Id: $
// File name:   tb_data_mux.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_data_mux.sv

`timescale 1ns / 100ps

module tb_data_mux
  ();

   reg tb_data_reg_input;
   reg [127:0] tb_ATD_parallel;
   reg [127:0] tb_process_out_data;
   reg [127:0] tb_data_reg_in;

   data_mux DUT
     (
      .data_reg_input(tb_data_reg_input),
      .ATD_parallel(tb_ATD_parallel),
      .process_out_data(tb_process_out_data),
      .data_reg_in(tb_data_reg_in)
      );

   initial
     begin
	tb_ATD_parallel = 128'd69;
	#1;
	tb_process_out_data = 128'd74;
	#1;

	// TEST CASE 1 (checking 0 mode)
	tb_data_reg_input = 1'b0;
	#1;
	if(tb_data_reg_in == 128'd69)
	  $info("TEST CASE 1 (checking 0 mode) : PASSED");
	else
	  $error("TEST CASE 1 (checking 0 mode) : FAILED");

	// TEST CASE 2 (checking 1 mode)
	tb_data_reg_input = 1'b1;
	#1;
	if(tb_data_reg_in == 128'd74)
	  $info("TEST CASE 2 (checking 1 mode) : PASSED");
	else
	  $error("TEST CASE 2 (checking 1 mode) : FAILED");

     end // initial begin

endmodule // tb_data_mux
	
