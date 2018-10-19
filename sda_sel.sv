// $Id: $
// File name:   sda_sel.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Ouptut Slected for I2c device

module sda_sel
(
	input  wire       tx_out,
	input  wire [1:0] sda_mode,
	output wire       sda_out
);

reg reg_sda_out;

assign sda_out = reg_sda_out; 

always_comb begin
	case (sda_mode)
		2'b00: begin
			reg_sda_out = 1'b1;
		end
		2'b01: begin
			reg_sda_out = 1'b0;
		end
		2'b10: begin
			reg_sda_out = 1'b1;
		end
		2'b11: begin
			reg_sda_out = tx_out;
		end

	endcase
end

endmodule