// $Id: $
// File name:   tb_rx_reg.sv
// Created:     11/16/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for rx_reg block

module tb_rx_reg ();
	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 5; //100Mhz clk
	localparam	CHECK_DELAY = 1; // Check 1ns after the rising edge to allow for propagation delay
	
	// Shared Test Variables
	reg tb_clk;

	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	integer tb_test_num = 0;
	string tb_test_description;

	reg tb_n_rst;
	reg [127:0] tb_rx_data;
	reg tb_reg_enable;
	reg [127:0] tb_key;

	rx_reg DUT (.clk(tb_clk), .n_rst(tb_n_rst), .rx_data(tb_rx_data), .reg_enable(tb_reg_enable), .key(tb_key));

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_rx_data = 128'd0;
		tb_reg_enable = 0;
		@(negedge tb_clk)
		tb_n_rst = 0;
		@(negedge tb_clk)
		tb_n_rst = 1;
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Test 1: General Tests I mean this block is really simple
		if (tb_key != 128'd0) begin
			$info("Bad value");
		end
		tb_rx_data = 128'd5000000;
		tb_reg_enable = 1;
		@(negedge tb_clk)
		if (tb_key != 128'd5000000) begin
			$info("Bad value");
		end	
		tb_reg_enable = 0;
		@(negedge tb_clk)
		if (tb_key != 128'd5000000) begin
			$info("Bad value");
		end	
		
		$info("Done");
	end
endmodule