// $Id: $
// File name:   rx_reg.sv
// Created:     11/16/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: The receive register for the AES Encryptor I2c port

module rx_reg
(
	input  wire clk,
	input  wire n_rst,
	input  wire [127:0] rx_data,
	input  wire reg_enable,
	output wire [127:0] key
);

reg [127:0] reg_key;

reg [127:0] next_key;

assign key = reg_key;

always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		reg_key <= 128'd0;
	end else begin
		reg_key <= next_key;
	end
end

always_comb begin
	next_key = reg_key;
	if (reg_enable == 1) begin
		next_key = rx_data;
	end
end
endmodule
