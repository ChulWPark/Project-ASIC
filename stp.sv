// $Id: $
// File name:   stp.sv
// Created:     11/19/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: serial to parallel shift register code.


module stp
(
	input wire clk, n_rst, ATD_shift_enable, ATD_data,
	output reg [127:0] ATD_parallel
	
);
	reg [127:0] p_output;
	
flex_stp_sr #(.NUM_BITS(128), .SHIFT_MSB(0))
FLEX_STP (.clk(clk), .n_rst(n_rst), .serial_in(ATD_data), .shift_enable(ATD_shift_enable), .parallel_out(p_output));

always_comb begin
  ATD_parallel = p_output;

end
 


endmodule 

