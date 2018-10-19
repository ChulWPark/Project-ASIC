// $Id: $
// File name:   AESencryptor.sv
// Created:     12/4/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: AESencryptor.sv

`timescale 1ns / 10ps

module AESencryptor
(
   	input wire clk,
   	input wire n_rst,
   	input wire ATD_data,
   	input wire ATD_clk,
	input wire scl,
   	input wire sda_in,
	output wire sda_out
);

   reg [127:0] ATD_parallel;
   reg 	       key_received;
   reg 	       data_ready;
   reg [127:0] key;
   reg 	       data_out_load;
   reg 	       data_taken;
   reg [127:0] process_out_data;
   reg 	       fifo_full;
   
   encryption
     ENCRYPTION (
		 .clk(clk),
		 .n_rst(n_rst),
		 .ATD_parallel(ATD_parallel),
		 .fifo_full(fifo_full),
		 .key_received(key_received),
		 .data_ready(data_ready),
		 .key(key),
		 .process_out_data(process_out_data),
		 .data_out_load(data_out_load),
		 .data_taken(data_taken)
		 );

   i2c
     I2C (
	  .clk(clk),
	  .n_rst(n_rst),
	  .scl(scl),
	  .sda_in(sda_in),
	  .sda_out(sda_out),
	  .write_enable(data_out_load),
	  .write_data(process_out_data),
	  .key(key),
	  .fifo_full(fifo_full),
	  .key_received(key_received)
	  );

   ATD_block
     ATD (
	  .clk(clk),
	  .n_rst(n_rst),
	  .ATD_data(ATD_data),
	  .ATD_clk(ATD_clk),
	  .data_taken(data_taken),
	  .data_ready(data_ready),
	  .ATD_parallel(ATD_parallel)
	  );
	  
endmodule // AESencryptor

   
