// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/6/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: N-bit Serial to Parallel Shift Register Design

`timescale 1ns / 10ps

module flex_stp_sr 
#(
	NUM_BITS = 4,
	SHIFT_MSB = 1
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output wire [NUM_BITS-1:0] parallel_out 
);
	reg [NUM_BITS-1:0] p_out;
	
	assign parallel_out = p_out;

always_ff @ ( posedge clk, negedge n_rst ) begin
	if (n_rst == 0) begin
		p_out = '1;
	end else begin
		if (shift_enable) begin
			if(SHIFT_MSB) begin
				for(integer i = NUM_BITS - 1; i > 0; i = i - 1) begin
					p_out[i] = p_out[i-1];
				end
				p_out[0] = serial_in;
			end else begin
				for(integer i = 0; i < NUM_BITS - 1; i = i + 1) begin
					p_out[i] = p_out[i+1];
				end
				p_out[NUM_BITS-1] = serial_in;	
			end
		end
	end
end

endmodule
