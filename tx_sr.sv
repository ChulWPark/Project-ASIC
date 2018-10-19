// $Id: $
// File name:   tx_sr.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Parallel to Serial Shift Register

module tx_sr
(
	input wire clk,
	input wire n_rst,
	input wire falling_edge_found,
	input wire tx_enable,
	input wire [127:0] tx_data,
	input wire load_data,
	output wire tx_out
);

flex_pts_sr #(.NUM_BITS(128)) shift1 (.clk(clk), .n_rst(n_rst), .shift_enable(falling_edge_found && tx_enable), .load_enable(load_data), .parallel_in(tx_data), .serial_out(tx_out));

endmodule
