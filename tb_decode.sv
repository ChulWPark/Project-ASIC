// $Id: $
// File name:   tb_decode.sv
// Created:     10/2/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for decode block

`timescale 1ns/100ps

module tb_decode ();
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
	reg tb_sda_in;
	reg [7:0] tb_starting_byte;
	reg tb_rw_mode;
	reg tb_address_match;
	reg tb_stop_found;
	reg tb_start_found;

	reg tb_expected_start;
	reg tb_expected_stop;
	reg [3:0] tb_start_stop_tests;

	integer i;

	decode DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst), 
			.scl(tb_scl),
			.sda_in(tb_sda_in),
			.starting_byte(tb_starting_byte),
			.rw_mode(tb_rw_mode),
			.address_match(tb_address_match),
			.stop_found(tb_stop_found),
			.start_found(tb_start_found) 
		);

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_scl = 0;
		tb_sda_in = 0;
		tb_starting_byte = 8'h00;
		
		@(negedge tb_clk)
		tb_n_rst = 0; //RST to ensure freshness
		@(negedge tb_clk)
		tb_n_rst = 1; //RST off

		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Test 1: A: 0->0  B: 0->0
		for(tb_test_num = 0; tb_test_num < 16; tb_test_num = tb_test_num + 1) begin
			tb_start_stop_tests = tb_test_num;
			
			test_start_stop(tb_start_stop_tests[3],tb_start_stop_tests[2],tb_start_stop_tests[1],tb_start_stop_tests[0]);
		end

		for(tb_test_num = 0; tb_test_num < 2 ** 8; tb_test_num = tb_test_num + 1) begin
			tb_starting_byte = tb_test_num;

			@(negedge tb_clk)
			
			if(tb_rw_mode == tb_starting_byte[0]) begin
				$info("CORRECT");
			end else begin
				$info("Incorrect RW value\nExpected: %d, Actual: %d", tb_starting_byte[0], tb_rw_mode);
			end
			
			if(tb_starting_byte[7:1] == 7'b1111000 && tb_address_match || tb_starting_byte[7:1] != 7'b1111000 && tb_address_match == 0) begin
				$info("CORRECT");
			end else begin
				$info("Incorrect Address Match value\nExpected: %d Actual: %d", tb_address_match, !tb_address_match);
			end
			
		end
		

	end

	task test_start_stop;
		input prev_sda_in;
		input curr_sda_in;
		input prev_scl;
		input curr_scl;
	begin
		tb_sda_in = prev_sda_in;
		tb_scl = prev_scl;

		@(negedge tb_clk)

		tb_sda_in = curr_sda_in;
		tb_scl = curr_scl;

		@(negedge tb_clk)

		if(prev_sda_in == 1 && curr_sda_in == 0 && prev_scl == 1 && curr_scl == 1) begin
			tb_expected_start = 1;
		end else begin
			tb_expected_start = 0;
		end
	
		if(prev_sda_in == 0 && curr_sda_in == 1 && prev_scl == 1 && curr_scl == 1) begin
			tb_expected_stop = 1;
		end else begin
			tb_expected_stop = 0;
		end

		if(tb_expected_start == tb_start_found) begin
			$info("CORRECT");
		end else begin
			$info("Incorrect start value!!!!\nExpected: %d\nActual: %d\nsda: %d->%d scl: %d->%d", tb_expected_start, tb_start_found, prev_sda_in, curr_sda_in, prev_scl, curr_scl);
		end

		if(tb_expected_stop == tb_stop_found) begin
			$info("CORRECT");
		end else begin
			$info("Incorrect start value!!!!\nExpected: %d\nActual: %d\nsda: %d->%d scl: %d->%d", tb_expected_stop, tb_stop_found, prev_sda_in, curr_sda_in, prev_scl, curr_scl);
		end
	end
	endtask
endmodule
		