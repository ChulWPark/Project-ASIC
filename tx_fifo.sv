// $Id: $
// File name:   tx_fifo.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Wrapper file for FIFO

module tx_fifo
#(
	ADDR_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire read_enable,
	input wire write_enable,
	input wire [127:0] write_data,
	output wire [127:0] read_data,
	output wire fifo_empty,
	output wire fifo_full
);

parameter MEM_UNITS = 2 ** ADDR_BITS;

reg [MEM_UNITS - 1: 0][127:0] memory;
reg [ADDR_BITS - 1: 0] start;
reg [ADDR_BITS - 1: 0] stop;

reg full;
reg next_full;

assign fifo_empty = (start == stop) && (full == 0);
assign fifo_full  = (start == stop) && (full == 1);
assign read_data  = memory[start];

reg [127:0] next_memory;
reg [ADDR_BITS - 1: 0] next_start;
reg [ADDR_BITS - 1: 0] next_stop;

reg prev_write_enable;
reg prev_read_enable;

always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		start <= '0;
		stop  <= '0;
		full  <= 1'b0;
		prev_read_enable <= read_enable;
		prev_write_enable <= write_enable;
	end else begin
		memory[stop] <= next_memory;
		start <= next_start;
		stop  <= next_stop;
		full <= next_full;
		prev_read_enable <= read_enable;
		prev_write_enable <= write_enable;
	end
end

always_comb begin
	next_memory = memory[stop];
	next_start = start;
	next_stop  = stop;
	next_full = full;

	if (read_enable == 1 && prev_read_enable == 0) begin
		if (fifo_empty == 0) begin
			next_start = (start + 1) % MEM_UNITS;
		end
	end

	if (write_enable == 1 && prev_write_enable == 0) begin
		if (fifo_full == 0) begin
			next_memory = write_data;
			next_stop = (stop + 1) % MEM_UNITS;
		end
	end

	if ((stop + MEM_UNITS - start) % MEM_UNITS == 4) begin
		next_full = 0;
	end else if ((stop + MEM_UNITS - start) % MEM_UNITS == 8) begin
		next_full = 1;
	end
end

endmodule