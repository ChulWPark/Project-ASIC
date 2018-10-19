// $Id: $
// File name:   tb_atd_detector.sv
// Created:     12/2/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for the ATD detector block

`timescale 1ns/100 ps

module tb_atd_detector();
	
	localparam NUM_CNT_BITS = 8;
	localparam CLK_PERIOD = 2.5;

	reg tb_clk;
	reg tb_n_rst;
	reg tb_ATD_data;
	reg tb_ATD_clk;
	reg tb_ATD_shift_enable;

	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//DUT port map

	atd_detector DUT(.clk(tb_clk), .n_rst(tb_n_rst), .ATD_data(tb_ATD_data), .ATD_clk(tb_ATD_clk), .ATD_shift_enable(tb_ATD_shift_enable));
	
	initial begin
	// Initialize all of the test inputs
		tb_n_rst	= 1'b1;		// Initialize to be inactive
		tb_ATD_data     = 1'b1;
		tb_ATD_clk      = 1'b0;
		
		#(0.1);
		
		//test case 1: checking for reset
		tb_n_rst 	= 1'b1;
		#(1);
		if(tb_ATD_shift_enable == 1'b0) begin
			$info("Reset works proeprly!!");
		end
		else
		begin
			$error("Reset not working");
		end
		
		//TEST CASE 2
		@(negedge tb_clk); 
		tb_ATD_clk = 1'b1;
		@(posedge tb_clk); 
		@(posedge tb_clk);
		#(1);
		if(tb_ATD_shift_enable == 1'b1) begin
			$info("0 -1 detecting properly!!");
		end
		else
		begin
			$error("0 -1 not detecting properly");
		end	
		
		
		//TEST CASE 3
		@(negedge tb_clk); 
		tb_ATD_clk = 1'b0;
		@(posedge tb_clk); 
		@(posedge tb_clk);
		#(1);
		if(tb_ATD_shift_enable == 1'b0) begin
			$info("0 -1 detecting properly!! part 2");
		end
		else
		begin
			$error("0 -1 not detecting properly part 2");
		end	
		
		
		//TEST CASE 4
		tb_ATD_data = 'z;
		#(1);
		@(negedge tb_clk); 
		tb_ATD_clk = 1'b1;
		
		@(posedge tb_clk); 
		@(posedge tb_clk);
		#(1);
		if(tb_ATD_shift_enable == 1'b0) begin
			$info("0 -1 detecting properly!! part 2");
		end
		else
		begin
			$error("0 -1 not detecting properly part 2");
		end	
end
endmodule
		
		
