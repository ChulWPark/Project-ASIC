// $Id: $
// File name:   tb_sda_sel.sv
// Created:     10/2/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for SDA_sel block
`timescale 1ns/100ps

module tb_sda_sel ();
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

	reg tb_tx_out;
	reg [1:0] tb_sda_mode;
	reg tb_sda_out;

	reg [2:0] tb_inputs;
	reg tb_expected_output;
	
	integer i;

	sda_sel DUT(	.tx_out(tb_tx_out),
			.sda_mode(tb_sda_mode),
			.sda_out(tb_sda_out)
		);

	assign tb_sda_mode = tb_inputs[1:0];
	assign tb_tx_out = tb_inputs[2];

	initial begin
	
		for(tb_test_num = 0; tb_test_num < 8; tb_test_num = tb_test_num + 1) begin
			tb_inputs = tb_test_num;
			@(negedge tb_clk)
			
			if (tb_sda_mode == 2'b00 || tb_sda_mode == 2'b10) begin
				tb_expected_output = 1'b1;
			end else if (tb_sda_mode == 2'b01) begin
				tb_expected_output = 1'b0;
			end else begin
				tb_expected_output = tb_tx_out;
			end
		
			if (tb_expected_output == tb_sda_out) begin
				$info("CORRECT");
			end else begin
				$info("INCORRECT VALUE!!");
			end
		end
	end
endmodule
