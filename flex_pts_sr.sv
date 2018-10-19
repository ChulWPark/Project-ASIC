// $Id: $
// File name:   flex_pts_sr.sv
// Created:     9/6/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: N-bit Parallel-to-serial Shift Register

`timescale 1ns / 10ps

module flex_pts_sr 
#(
	NUM_BITS = 4,
	SHIFT_MSB = 1
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire load_enable,
	input wire [NUM_BITS-1:0] parallel_in,
	output wire serial_out
);
	reg s_out;
	reg [NUM_BITS-1:0] p_in;

	assign serial_out = p_in[NUM_BITS-1];

always_ff @ ( posedge clk, negedge n_rst ) begin
	if (n_rst == 0) begin
		s_out = 1'b1;
		p_in = '1;
	end else if (load_enable) begin
		if(SHIFT_MSB) begin
			for(integer i = 0; i < NUM_BITS; i = i + 1) begin
				p_in[i] = parallel_in[i];	
			end	
		end else begin
			for(integer i = 0; i < NUM_BITS; i = i + 1) begin
				p_in[i] = parallel_in[NUM_BITS - 1 - i];	
			end
		end
	end else begin
		if (shift_enable) begin
			for(integer i = NUM_BITS - 1; i > 0 ; i = i - 1) begin
				p_in[i] = p_in[i-1];
			end
			p_in[0] = 1'b1;
		end
	end
end

endmodule
