// $Id: $
// File name:   scl_edge.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Edge detector for I2c device

module scl_edge
(
	input wire clk,
	input wire n_rst,
	input wire scl,
	output wire rising_edge_found,
	output wire falling_edge_found
);

reg  reg_rising_edge_found;
reg next_rising_edge_found;
reg  reg_falling_edge_found;
reg next_falling_edge_found;

reg prev_scl;

assign rising_edge_found = reg_rising_edge_found;
assign falling_edge_found = reg_falling_edge_found;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		reg_rising_edge_found <= 0;
		reg_falling_edge_found <= 0;
		prev_scl <= scl;
	end else begin
		reg_rising_edge_found <= next_rising_edge_found;
		reg_falling_edge_found <= next_falling_edge_found;
		prev_scl <= scl;
	end
end

always_comb begin
	next_rising_edge_found = 0;
	next_falling_edge_found = 0;
	
	if (prev_scl == 0 && scl == 1) begin
		next_rising_edge_found = 1;
	end else if (prev_scl == 1 && scl == 0) begin
		next_falling_edge_found = 1;
	end
end

endmodule