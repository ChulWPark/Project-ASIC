// $Id: $
// File name:   rx_sr.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Recieveing Shift Register

module rx_sr
(
	input  wire clk,
	input  wire n_rst,
	input  wire sda_in,
	input  wire rising_edge_found,
	input  wire rx_enable,
	output wire [127:0] rx_data
);

flex_stp_sr #(.NUM_BITS(128)) shift1 (.clk(clk), .n_rst(n_rst), .shift_enable(rising_edge_found && rx_enable), .serial_in(sda_in), .parallel_out(rx_data));

endmodule 