// $Id: $
// File name:   encryption.sv
// Created:     12/3/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: encryption.sv

module encryption
  (
   input wire 	      clk,
   input wire 	      n_rst,
   input wire [127:0] ATD_parallel,
   input wire 	      key_received,
   input wire 	      data_ready,
   input wire [127:0] key,
   input wire 	      fifo_full,
   output wire [127:0] process_out_data,
   output wire 	      data_out_load,
   output wire 	      data_taken
   );

   reg 	      ark_enable;
   reg 	      sb_enable;
   reg 	      mc_enable;
   reg 	      sr_enable;
   reg 	      key_gen_enable;
   reg [127:0] process_key;
   reg [127:0] ark_out;
   reg [127:0] sb_out;
   reg [127:0] mc_out;
   reg [127:0] sr_out;
   reg [127:0] data_reg_in;
   reg 	       data_reg_input;
   reg [1:0]   process_output;
   reg [3:0]   iter_in;
   reg [3:0]   iter_out;
   reg [127:0] key_out;
   reg 	       key_reg_load;
   reg 	       data_load;
   reg [127:0] data_out;
   
   //IMPORT ARK
   ark
     ARK (
	  .ark_enable(ark_enable),
	  .data(data_out),
	  .key(process_key),
	  .ark_out(ark_out)
	  );
   
   //IMPORT DATA_MUX
   data_mux
     DATA_MUX (
	       .data_reg_input(data_reg_input),
	       .ATD_parallel(ATD_parallel),
	       .process_out_data(process_out_data),
	       .data_reg_in(data_reg_in)
	       );
   
   //IMPORT ENCRYPTION_MUX
   encryption_mux
     ENCRYPTION_MUX (
		     .process_output(process_output),
		     .ark_out(ark_out),
		     .sb_out(sb_out),
		     .mc_out(mc_out),
		     .sr_out(sr_out),
		     .process_out_data(process_out_data)
		     );
   
   //IMPORT ENCRYPTOR_LCU
   encryptor_lcu
     ENCRYPTOR_LCU (
		    .clk(clk),
		    .n_rst(n_rst),
		    .key_received(key_received),
		    .data_ready(data_ready),
		    .fifo_full(fifo_full),
		    .data_load(data_load),
		    .data_taken(data_taken),
		    .data_out_load(data_out_load),
		    .data_reg_input(data_reg_input),
		    .process_output(process_output),
		    .ark_enable(ark_enable),
		    .sb_enable(sb_enable),
		    .mc_enable(mc_enable),
		    .sr_enable(sr_enable),
		    .key_gen_enable(key_gen_enable),
		    .iter_in(iter_in),
		    .iter_out(iter_out),
		    .key_reg_load(key_reg_load)
		    );
   
   //IMPORT KEYGEN
   keygen
     KEYGEN (
	     .key_gen_enable(key_gen_enable),
	     .key_in(key),
	     .prev_key(process_key),
	     .iteration_num(iter_in),
	     .key_out(key_out)
	     );
   
   //IMPORT KEY_REGISTER
   key_register
     KEY_REGISTER (
		   .clk(clk),
		   .n_rst(n_rst),
		   .iter_in(iter_in),
		   .iter_out(iter_out),
		   .key_reg_load(key_reg_load),
		   .key_out(key_out),
		   .process_key(process_key)
		   );
   
   //IMPORT MC
   mc
     MC (
	 .mc_enable(mc_enable),
	 .data(data_out),
	 .key(process_key),
	 .mc_out(mc_out)
	 );
   
   //IMPORT SB
   sb
     SB (
	 .sb_enable(sb_enable),
	 .data(data_out),
	 .key(process_key),
	 .sb_out(sb_out)
	 );
	 
   //IMPORT SR
   sr
     SR (
	 .sr_enable(sr_enable),
	 .data(data_out),
	 .key(process_key),
	 .sr_out(sr_out)
	 );

   //IMPORT DATA REGISTER
   data_register
     DATA_REGISTER (
		    .clk(clk),
		    .n_rst(n_rst),
		    .data_load(data_load),
		    .data_in(data_reg_in),
		    .data_out(data_out)
		    );
   
endmodule // encryption
