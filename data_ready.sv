// $Id: $
// File name:   atd_detector.sv
// Created:     11/1/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: code for data ready

module data_ready (
	input wire clk,
	input wire n_rst,
	input wire ATD_data,
	input wire ATD_shift_enable,
	input wire data_taken,
	input wire ATD_clk,
	output reg data_ready	
);
reg [7:0] count_val;
reg intermediate;

reg enough_bits;
reg next_enough_bits;

reg reg_data_ready;
reg next_data_ready;

assign data_ready = reg_data_ready;

flex_counter  #(8) ABC(.clk(clk), .n_rst(n_rst), .count_enable(ATD_shift_enable), .clear(data_taken), .rollover_val(8'd128), .rollover_flag(intermediate), .count_out(count_val));

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		enough_bits <= 0;
		reg_data_ready <= 0;
	end else begin
		enough_bits <= next_enough_bits;
		reg_data_ready <= next_data_ready;
	end
end

always_comb begin
	next_enough_bits = enough_bits;
	next_data_ready = 0;

	if(count_val % 16 == 0 && count_val != 0 && enough_bits || intermediate) begin
		next_data_ready = 1;
	end

	if (data_taken) begin
		next_enough_bits = 0;
	end else if(intermediate) begin
		next_enough_bits = 1;
	end 
	
end
endmodule
