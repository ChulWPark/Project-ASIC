// $Id: $
// File name:   atd_detector.sv
// Created:     11/1/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: code for the data detector

module atd_detector (

	input wire clk,
	input wire n_rst,
	input wire ATD_data,
	input wire ATD_clk,
	output reg ATD_shift_enable
);

reg ATD_clk_delay;
reg ATD_clk_delay2;


always_ff @(posedge clk, negedge n_rst)  //creating the register
 	begin	
		if (!n_rst) begin
			ATD_clk_delay <= 1;
			ATD_clk_delay2 <= 1;				  		      
		end 
		else  begin
			ATD_clk_delay <= ATD_clk;			
			ATD_clk_delay2 <= ATD_clk_delay;
		end
	end
always_comb begin
  ATD_shift_enable = ATD_clk_delay & ~ATD_clk_delay2;
  
end

endmodule

