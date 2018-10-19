// $Id: $
// File name:   tb_scl_edge.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for Edge detector

`timescale 1ns/100ps

module tb_scl_edge ();
	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 10; //100Mhz clk
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
	reg tb_scl;
	reg tb_rising_edge_found;
	reg tb_falling_edge_found;
	reg [1:0] tb_expected_output;

	reg ex_rising_edge;
	reg ex_falling_edge;


	scl_edge DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst), 
			.scl(tb_scl),
			.rising_edge_found(tb_rising_edge_found),
			.falling_edge_found(tb_falling_edge_found) 
		);

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_scl = 0;
		
		@(negedge tb_clk)
		tb_n_rst = 0; //RST to ensure freshness
		@(negedge tb_clk)
		tb_n_rst = 1; //RST off

		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		for(tb_test_num = 0; tb_test_num < 8; tb_test_num = tb_test_num + 1) begin
			 test_edge_detector(tb_test_num[2], tb_test_num[1], tb_test_num[0]);
		end
	end

	task test_edge_detector;
		input first_scl;
		input second_scl;
		input third_scl;
		
	begin
		tb_scl = first_scl;
		@(negedge tb_clk)
		tb_scl = second_scl;
		@(negedge tb_clk)
		tb_scl = third_scl;
		@(negedge tb_clk)

		if(second_scl == 0 && third_scl == 1) begin
			ex_rising_edge = 1;
			ex_falling_edge = 0;
		end else if(second_scl == 1 && third_scl == 0) begin
			ex_falling_edge = 1;
			ex_rising_edge = 0;
		end else  begin
			ex_rising_edge = 0;
			ex_falling_edge = 0;
		end

		if(tb_rising_edge_found == ex_rising_edge && tb_falling_edge_found == ex_falling_edge) begin
			$info("CORRECT!");
		end else begin
			$info("Test: %d\nRising: %d Expected: %d\nFalling: %d Expected: %d", tb_test_num , tb_rising_edge_found, ex_rising_edge, tb_falling_edge_found, ex_falling_edge);
		end
	end
	endtask
endmodule