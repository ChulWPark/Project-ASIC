// $Id: $
// File name:   ATD_block.sv
// Created:     12/4/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: wrapper function to call all the functions.


module ATD_block (
	input wire clk,
	input wire n_rst,
	input wire ATD_data,
	input wire ATD_clk,
	input wire data_taken,
	output reg data_ready,
	output reg [127:0] ATD_parallel
);
reg ATD_shift_enable;
reg synced_data;
reg synced_clk;

//assign ATD_shift_enable = '0;

atd_detector DATA_DETEC (.clk(clk), .n_rst(n_rst), .ATD_data(synced_data) ,.ATD_clk(synced_clk), .ATD_shift_enable(ATD_shift_enable));

data_ready DATA_READY(.clk(clk), .n_rst(n_rst),  .ATD_data(synced_data) ,.ATD_clk(synced_clk), .ATD_shift_enable(ATD_shift_enable), .data_ready(data_ready), .data_taken(data_taken));

stp SHIFT_REG(.clk(clk), .n_rst(n_rst),  .ATD_data(synced_data) , .ATD_shift_enable(ATD_shift_enable), .ATD_parallel(ATD_parallel));

sync_high data_sync (.clk(clk), .n_rst(n_rst), .async_in(ATD_data), .sync_out(synced_data));

sync_high clk_sync (.clk(clk), .n_rst(n_rst), .async_in(ATD_clk), .sync_out(synced_clk));

endmodule
