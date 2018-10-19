// $Id: $
// File name:   tb_tx_fifo.sv
// Created:     10/2/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for tx fifo block
`timescale 1ns/100ps

module tb_tx_fifo ();
	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 5; //200Mhz clk
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
	reg tb_read_enable;
	reg [127:0] tb_read_data;
	reg tb_fifo_empty;
	reg tb_fifo_full;
	reg tb_write_enable;
	reg [127:0] tb_write_data;

	integer i;

	tx_fifo DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst), 
			.read_enable(tb_read_enable),
			.read_data(tb_read_data),
			.fifo_empty(tb_fifo_empty),
			.fifo_full(tb_fifo_full),
			.write_enable(tb_write_enable),
			.write_data(tb_write_data)			
		);

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_read_enable = 0;
		tb_write_enable = 0;
		tb_write_data = 128'h00;	

		
		@(negedge tb_clk)
		tb_n_rst = 0; //RST to ensure freshness
		@(negedge tb_clk)
		tb_n_rst = 1; //RST off

		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Test 1: Find Number of Slots

		if(tb_fifo_empty == 1) begin
			$info("CORRECT");
		end else begin
			$info("Incorrect fifo not empty");
		end

		$info("Writing");
		for(tb_test_num = 1; tb_test_num < 18; tb_test_num = tb_test_num + 1) begin
			write_value(tb_test_num);
		end

		$info("Reading");
		for(tb_test_num = 1; tb_test_num < 18; tb_test_num = tb_test_num + 1) begin
			read_value(tb_test_num);
		end

		

	end

	task write_value;
		input int tb_test_num;
	begin
		@(negedge tb_clk)
		if(tb_fifo_full == 1) begin
			$info("Max Slots: %d", tb_test_num - 1);
			tb_test_num = 64;
			tb_write_enable = 0;
		end else begin	
			tb_write_enable = 1;
			tb_write_data = tb_test_num;
		end
	
		tb_write_data = tb_test_num;
				
		@(negedge tb_clk)

		tb_write_enable = 0;
	end
	endtask

	task read_value;
		input int tb_test_num;
	begin
		@(negedge tb_clk)
		if(tb_fifo_empty == 1) begin
			$info("fifo empty");
			tb_read_enable = 0;
		end else begin	
			tb_read_enable = 1;
		end
	
		if(tb_read_data == tb_test_num && tb_read_enable) begin
			$info("Expected Value");
		end else if(tb_read_enable) begin
			$info("Unexpected Value");
		end
				
		@(negedge tb_clk)

		tb_read_enable = 0;
	end
	endtask
	
endmodule
