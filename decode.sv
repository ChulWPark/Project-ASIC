// $Id: $
// File name:   decode.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Observes and Reports START and STOP Conditions

module decode
(
	input wire clk,
	input wire n_rst,
	input wire scl,
	input wire sda_in,
	input wire [127:0] starting_byte,
	output wire rw_mode,
	output wire address_match,
	output wire stop_found,
	output wire start_found
);

assign rw_mode = starting_byte[0];
assign address_match = (starting_byte[7:1] == 7'b1011001);

reg prev_scl;
reg prev_sda_in;
reg next_stop_found;
reg next_start_found;
reg reg_stop_found;
reg reg_start_found;

assign stop_found  = reg_stop_found;
assign start_found = reg_start_found;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		reg_start_found <= 0;
		reg_stop_found <= 0;
		prev_scl <= scl;
		prev_sda_in <= sda_in;
	end else begin
		reg_start_found <= next_start_found;
		reg_stop_found <= next_stop_found;
		prev_scl <= scl;
		prev_sda_in <= sda_in;
	end
end

always_comb begin
	next_start_found = 0;
	next_stop_found = 0;

	if(scl == 1 && prev_scl == 1 && prev_sda_in == 1 && sda_in == 0) begin
		next_start_found = 1;
	end
	
	if(scl == 1 && prev_scl == 1 && prev_sda_in == 0 && sda_in == 1) begin
		next_stop_found = 1;
	end
end

endmodule