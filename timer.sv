// $Id: $
// File name:   timer.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Timer Block for I2c deivce

module timer
(
	input wire clk,
	input wire n_rst,
	input wire rising_edge_found,
	input wire falling_edge_found,
	input wire stop_found,
	input wire start_found,
	input wire start_byte_received,
	output wire byte_received,
	output wire ack_prep,
	output wire check_ack,
	output wire ack_done,
	output wire key_received
);

reg [4:0] count_out;
reg rollover_flag;
reg count_enable;

flex_counter #(.NUM_CNT_BITS(5)) counter1 (.clk(clk), .n_rst(n_rst), .clear(stop_found | start_found), .count_enable(count_enable), .rollover_val(5'd18), .count_out(count_out), .rollover_flag(rollover_flag));
flex_counter #(.NUM_CNT_BITS(5)) counter2 (.clk(clk), .n_rst(n_rst), .clear(stop_found | start_found | start_byte_received), .count_enable(byte_received), .rollover_val(5'd16), .rollover_flag(key_received));

reg reg_byte_received;
reg next_byte_received;

reg reg_ack_prep;
reg next_ack_prep;
	
reg reg_check_ack;
reg next_check_ack;

reg reg_ack_done;
reg next_ack_done;

assign byte_received = reg_byte_received;
assign ack_prep = reg_ack_prep;
assign check_ack = reg_check_ack;
assign ack_done = reg_ack_done;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		reg_byte_received 	<= 0;
		reg_ack_prep 		<= 0;
		reg_check_ack 		<= 0;
		reg_ack_done		<= 0;
	end else begin
		reg_byte_received 	<= next_byte_received;
		reg_ack_prep 		<= next_ack_prep;
		reg_check_ack 		<= next_check_ack;
		reg_ack_done		<= next_ack_done;
	end
end

always_comb begin
	if(count_out == 5'd0) begin
		count_enable = rising_edge_found;
	end else begin
		count_enable = (rising_edge_found | falling_edge_found);
	end

	next_byte_received = 0;
	next_ack_prep = 0;
	next_check_ack = 0;
	next_ack_done = 0;

	if(rising_edge_found == 1 | falling_edge_found == 1) begin
		if(count_out == 14) begin
			next_byte_received = 1;
		end else if (count_out == 15) begin
			next_ack_prep = 1;
		end else if (count_out == 16) begin
			next_check_ack = 1;
		end else if (count_out == 17) begin
			next_ack_done = 1;
		end
	end
end

endmodule