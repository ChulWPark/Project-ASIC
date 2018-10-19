// $Id: $
// File name:   i2c_slave.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Top Level File for I2c Slave Device

module i2c
(
	input wire clk,
	input wire n_rst,
	input wire scl,
	input wire sda_in,
	output wire sda_out,
	input wire write_enable,
	input wire [127:0] write_data,
	output wire [127:0] key,
	output wire fifo_full,
	output wire key_received
);

reg synch_sda_in;
reg synch_scl;
reg rising_edge_found;
reg falling_edge_found;
reg tx_out;
reg [1:0] sda_mode;
reg [127:0] rx_data;
reg rw_mode;
reg address_match;
reg stop_found;
reg start_found;
reg rx_enable;
reg tx_enable;
reg [127:0] read_data;
reg load_data;
reg read_enable;
reg byte_received;
reg ack_prep;
reg check_ack;
reg ack_done;
reg reg_enable;
reg start_byte_received;
reg sixteen_bytes;

scl_edge edge_detector (	.clk(clk), 
				.n_rst(n_rst), 
				.scl(synch_scl), 
				.rising_edge_found(rising_edge_found), 
				.falling_edge_found(falling_edge_found));

sda_sel output_selector(	.tx_out(tx_out),
				.sda_mode(sda_mode),
				.sda_out(sda_out));

decode decoder(			.clk(clk),
				.n_rst(n_rst),
				.scl(synch_scl),
				.sda_in(synch_sda_in),
				.starting_byte(rx_data),
				.rw_mode(rw_mode),
				.address_match(address_match),
				.stop_found(stop_found),
				.start_found(start_found));

rx_sr recieve_shift(		.clk(clk),
				.n_rst(n_rst),
				.sda_in(synch_sda_in),
				.rising_edge_found(rising_edge_found),
				.rx_enable(rx_enable),
				.rx_data(rx_data));

tx_sr transmit_shift(		.clk(clk),
				.n_rst(n_rst),
				.tx_out(tx_out),
				.falling_edge_found(falling_edge_found),
				.tx_enable(tx_enable),
				.tx_data(read_data),
				.load_data(load_data));

tx_fifo fifo_memory(		.clk(clk),
				.n_rst(n_rst),
				.read_enable(read_enable),
				.read_data(read_data),
				.fifo_empty(fifo_empty),
				.fifo_full(fifo_full),
				.write_enable(write_enable),
				.write_data(write_data));

timer slave_timer(		.clk(clk),
				.n_rst(n_rst),
				.rising_edge_found(rising_edge_found),
				.falling_edge_found(falling_edge_found),
				.stop_found(stop_found),
				.start_found(start_found),
				.start_byte_received(start_byte_received),
				.byte_received(byte_received),
				.ack_prep(ack_prep),
				.check_ack(check_ack),
				.ack_done(ack_done),
				.key_received(sixteen_bytes));

controller slave_controller( 	.clk(clk),
				.n_rst(n_rst),
				.stop_found(stop_found),
				.start_found(start_found),
				.byte_received(byte_received),
				.ack_prep(ack_prep),
				.check_ack(check_ack),
				.ack_done(ack_done),
				.rw_mode(rw_mode),
				.address_match(address_match),
				.key_received(sixteen_bytes),
				.sda_in(sda_in),
				.fifo_empty(fifo_empty),
				.rx_enable(rx_enable),
				.tx_enable(tx_enable),
				.read_enable(read_enable),
				.sda_mode(sda_mode),
				.load_data(load_data),
				.reg_enable(reg_enable),
				.start_byte_received(start_byte_received),
				.key_loaded(key_received));

sync_high sda_synch(		.clk(clk),
				.n_rst(n_rst),
				.async_in(sda_in),
				.sync_out(synch_sda_in));

sync_high scl_synch(		.clk(clk),
				.n_rst(n_rst),
				.async_in(scl),
				.sync_out(synch_scl));

rx_reg key_register(		.clk(clk),
				.n_rst(n_rst),
				.rx_data(rx_data),
				.reg_enable(reg_enable),
				.key(key));


endmodule
