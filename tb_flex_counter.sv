// $Id: $
// File name:   tb_flex_counter.sv
// Created:     9/7/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for flexible counter

`timescale 1ns / 10ps

module tb_flex_counter ();
	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 2.5;
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

	localparam SIZE = 4;
	localparam MAX_BIT = (SIZE - 1);
	
	integer tb_test_num;
	reg tb_n_rst;
	reg [MAX_BIT:0] tb_count_out;
	reg tb_count_enable;
	reg tb_clear;
	reg [MAX_BIT:0] tb_rollover_val;
	reg tb_rollover_flag;
	reg [MAX_BIT:0] tb_expected_out;

	flex_counter DUT (	.clk(tb_clk), 
						.n_rst(tb_n_rst), 
						.clear(tb_clear), 
						.count_enable(tb_count_enable), 
						.rollover_val(tb_rollover_val),
						.count_out(tb_count_out),
						.rollover_flag(tb_rollover_flag)
						);

	/*clocking cb @(posedge tb_clk);
 		// 1step means 1 time precision unit, 10ps for this module. We assume the hold time is less than 200ps.
		default input #1step output #10ps; // Setup time (01CLK -> 10D) is 94 ps
		output #800ps n_rst = tb_n_rst; // FIXME: Removal time (01CLK -> 01R) is 281.25ps, but this needs to be 800 to prevent metastable value warnings
		output clear = tb_clear,
			count_enable = tb_count_enable,
			rollover_val = tb_rollover_val;
		input count_out = tb_count_out,
			rollover_flag = tb_rollover_flag;
	endclocking*/

	// Default Configuration Test bench main process
	initial
	begin
		tb_n_rst	= 1'b1;		// Initialize to be inactive

		tb_rollover_val	= 4'b1111;	// Initialize to be idle
		tb_count_enable	= 1'b0;		// Initialize to be inactive
		tb_clear	= 1'b0;
		
		tb_test_num 	= 0;
		
		@(negedge tb_clk);
		tb_n_rst	<= 1'b0; 	// Need to actually toggle this in order for it to actually run dependent always blocks
		@(posedge tb_clk);
		tb_n_rst	<= 1'b1; 	// Deactivate the chip reset
		
		// Wait for a while to see normal operation
		@(posedge tb_clk);
		@(posedge tb_clk);

		// Test 1: Check for Proper Reset w/ Idle (serial_in=1) input during reset signal
		tb_test_num = tb_test_num + 1;
		tb_n_rst <= 1'b0;
		
		tb_expected_out = '0;
		@(posedge tb_clk);// Measure slightly before the second clock edge
		@(posedge tb_clk);
		if (tb_expected_out == tb_count_out)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED", tb_test_num);
		// De-assert reset for a cycle
		tb_n_rst <= 1'b1;
		@(posedge tb_clk);

		// Test 2: Normal Counting
		@(negedge tb_clk);
		tb_test_num = tb_test_num + 1;
		tb_count_enable	= 1'b1;		// Initialize to be inactive
		@(posedge tb_clk);
		@(posedge tb_clk);


		tb_expected_out = 2;
		@(negedge tb_clk);
		if (tb_expected_out == tb_count_out)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED\nCount Out: %d\nExpected: %d", tb_test_num, tb_count_out, tb_expected_out);

		// Test 3: Rollover
		tb_test_num = tb_test_num + 1;
		tb_rollover_val	= 4'b0100;
		@(posedge tb_clk);

		@(negedge tb_clk);
		if (0 == tb_rollover_flag)
			$info("Rollover CORRECT");
		else // Test case failed
			$error("Rollover INCORRECT");
		@(posedge tb_clk);
		@(negedge tb_clk);
		if (1 == tb_rollover_flag)
			$info("Rollover CORRECT");
		else // Test case failed
			$error("Rollover INCORRECT");
		@(posedge tb_clk);

		tb_expected_out = 1;
		@(negedge tb_clk);
		if (tb_expected_out == tb_count_out)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED\nCount Out: %d\nExpected: %d", tb_test_num, tb_count_out, tb_expected_out);
		if (0 == tb_rollover_flag)
			$info("Rollover CORRECT");
		else // Test case failed
			$error("Rollover INCORRECT");

		// Test 4: clear
		tb_test_num = tb_test_num + 1;
		tb_clear = 1;
		@(posedge tb_clk);

		tb_expected_out = 0;
		@(negedge tb_clk);
		if (tb_expected_out == tb_count_out)
			$info("Case %0d:: PASSED", tb_test_num);
		else // Test case failed
			$error("Case %0d:: FAILED\nCount Out: %d\nExpected: %d", tb_test_num, tb_count_out, tb_expected_out);
		tb_clear = 0;



	end
endmodule
