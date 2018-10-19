// $Id: $
// File name:   sync_low.sv
// Created:     9/4/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Reset to Logic Low Synchronizer

`timescale 1ns / 10ps

module sync_low
(
	input wire clk,
	input wire n_rst,
	input wire async_in,
	output wire sync_out
);

	reg ff_q1;
	reg ff_q2;

	assign sync_out = ff_q2;

always_ff @ (posedge clk, negedge n_rst) begin
	if (1'b0 == n_rst) begin
		ff_q1 <= 0;
	end else begin
		ff_q1 <= async_in;
	end
end

always_ff @ (posedge clk, negedge n_rst) begin
	if (1'b0 == n_rst) begin
		ff_q2 <= 0;
	end else begin
		ff_q2 <= ff_q1;
	end
end
endmodule
