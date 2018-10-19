// $Id: $
// File name:   flex_counter.sv
// Created:     9/6/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scalable Counter with Controlled Rollover

module flex_counter
#(
	NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS-1:0] rollover_val,
	output wire [NUM_CNT_BITS-1:0] count_out,
	output wire rollover_flag
);

	reg rollover;
	reg [NUM_CNT_BITS-1:0] count;
	reg next_rollover;
	reg [NUM_CNT_BITS-1:0] next_count;
	
	assign rollover_flag = rollover;
	assign count_out = count[NUM_CNT_BITS-1:0];

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		rollover <= 0;
		count <= '0;
	end else begin
		rollover <= next_rollover;
		count <= next_count;
	end
end

always_comb begin
	next_count = count;
	if (clear) begin
		next_count = '0;
	end else if (count_enable && rollover) begin
		next_count = 1;
	end else if (count_enable) begin
		next_count = count + 1;
	end

	next_rollover = 0;
	if(next_count == rollover_val) begin
		next_rollover = 1;
	end
end

endmodule