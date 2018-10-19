// $Id: $
// File name:   tb_timer.sv
// Created:     10/4/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for I2c timer block

`timescale 1ns/100ps

module tb_timer ();
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
	reg tb_rising_edge_found;
	reg tb_falling_edge_found;
	reg tb_stop_found;
	reg tb_start_found;
	reg tb_start_byte_received;
	reg tb_byte_received;
	reg tb_ack_prep;
	reg tb_check_ack;
	reg tb_ack_done;
	reg tb_key_received;

	integer wait_cycles;

	integer i;
	integer j;
	integer k;
	integer start_bit_counter;
	
	integer count;
	integer bytes;

	reg [3:0] tb_expected_output;

	timer DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst),
			.rising_edge_found(tb_rising_edge_found),
			.falling_edge_found(tb_falling_edge_found), 
			.stop_found(tb_stop_found),
			.start_found(tb_start_found) ,
			.start_byte_received(tb_start_byte_received),
			.byte_received(tb_byte_received),
			.ack_prep(tb_ack_prep),
			.check_ack(tb_check_ack),
			.ack_done(tb_ack_done),
			.key_received(tb_key_received)	
		);

	initial begin
		//Test 0: Setup
		bytes = 0;
		tb_n_rst = 1; //RST off
		tb_rising_edge_found = 0;
		tb_falling_edge_found = 0;
		tb_stop_found = 0;
		tb_start_found = 0;
		tb_start_byte_received = 0;
		
		reset_device;
		
		//Test 1: Start Bit
		$info("Standard Run Started");
		start;
		cycles(9);
		$info("Start Bit Recieved");
		for(k = 0; k < 100; k = k + 1) begin
			cycles(9);
			if(k % 20 == 0) begin
				$info("Data Bit #%d Recieved", k);
			end
		end
		stop;
		check_output;
		$info("Test 1 Finished");
		
		//Test 2: Precycles
		cycles(4);
		$info("Precycled Run");
		start;
		cycles(9);
		$info("Start Bit Recieved");
		for(k = 0; k < 100; k = k + 1) begin
			cycles(9);
			if(k % 20 == 0) begin
				$info("Data Bit #%d Recieved", k);
			end
		end
		stop;
		check_output;
		$info("Test 2 Finished");

		//Test 3: Stopped Midway
		cycles(4);
		$info("Stopped Midway Though");
		start;
		cycles(9);
		$info("Start Bit Recieved");
		cycles(7);
		stop;
		cycles(2);
		check_output;
		stop;
		check_output;
		$info("Test 3 Finished");

		//Test 4: Ensure Starting Falling Edge Does Not Effect
		$info("Falling Edge First Run Started");
		start;
		tb_falling_edge_found = 1'b1;
		@(negedge tb_clk)
		tb_falling_edge_found = 1'b0;
		@(negedge tb_clk)
		
		cycles(9);
		$info("Start Bit Recieved");
		for(k = 0; k < 10; k = k + 1) begin
			cycles(9);
			if(k % 20 == 0) begin
				$info("Data Bit #%d Recieved", k);
			end
		end
		stop;
		check_output;
		$info("Test 4 Finished");

		//Test 5: Ensure Starting Falling Edge Does Not Effect
		$info("Falling Edge First Run Started");
		start;
		tb_falling_edge_found = 1'b1;
		@(negedge tb_clk)
		tb_falling_edge_found = 1'b0;
		@(negedge tb_clk)
		
		cycles(9);
		$info("Start Bit Recieved");
		for(k = 0; k < 10; k = k + 1) begin
			cycles(9);
			if(k % 20 == 0) begin
				$info("Data Bit #%d Recieved", k);
			end
		end
		stop;
		check_output;
		$info("Test 5 Finished");

		//Test 6: Check key_received signal
		$info("checking key_received signal");
		start;

		tb_falling_edge_found = 1'b1;
		@(negedge tb_clk)
		tb_falling_edge_found = 1'b0;
		@(negedge tb_clk)

		cycles(9);
		$info("Start Bit Recieved");
		@(negedge tb_clk)
		tb_start_byte_received = 1;
		@(negedge tb_clk)
		tb_start_byte_received = 0;
		@(negedge tb_clk)

		for(k = 0; k < 50; k = k + 1) begin
			cycles(9);
			if((k + 1) % 16 == 0) begin
				$info("Data Bit #%d Recieved", k+1);
				if (tb_key_received == 0) begin
					$info("Bad key_received");
				end
			end else begin
				if (tb_key_received == 1) begin
					$info("Bad key_received");
				end
			end
		end
		stop;
		check_output;
		$info("Test 6 Finished");

		
		
	end

	task start;
	begin
		tb_start_found = 1;
		inc_count;
		@(negedge tb_clk)
		tb_start_found = 0;
		bytes = 0;
	end
	endtask

	task stop;
	begin
		tb_stop_found = 1;
		inc_count;
		@(negedge tb_clk)
		tb_stop_found = 0;
	end
	endtask

	task cycles;
		input [8:0] NUM_BITS;
	begin
		wait_cycles = 5;
		for(start_bit_counter = 0; start_bit_counter < NUM_BITS; start_bit_counter = start_bit_counter + 1) begin
			@(posedge tb_clk)	
			tb_rising_edge_found = 1;
			inc_count;
			check_output;
			tb_rising_edge_found = 0;

			wait_time;
			
			@(posedge tb_clk)	
			tb_falling_edge_found = 1;
			inc_count;
			check_output;
			tb_falling_edge_found = 0;

			wait_time;
		end
	end
	endtask
		

	task wait_time;
	begin
		for(i = 0; i < wait_cycles; i = i + 1) begin
			@(posedge tb_clk)
			j = 0;
		end
	end
	endtask

	task reset_device;
	begin
		tb_n_rst = 1;
		@(negedge tb_clk)
		tb_n_rst = 0; //RST to ensure freshness
		@(negedge tb_clk)
		tb_n_rst = 1; //RST off

		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		count = 0;
	end
	endtask

	task inc_count;
	begin
		@(posedge tb_clk)
		if(tb_start_found | tb_stop_found) begin
			count = 0;
		end else if (count == 18) begin
			count = 1;
		end else begin
			count = count + 1;
		end
	end
	endtask

	task check_output;
	begin
		@(negedge tb_clk)
		tb_expected_output = 4'b0000;
		if(count == 15) begin
			tb_expected_output[0] = 1;
			
		end else if (count == 16) begin
			tb_expected_output[1] = 1;
		end else if (count == 17) begin
			tb_expected_output[2] = 1;
		end else if (count == 18) begin
			tb_expected_output[3] = 1;
		end

		if (tb_byte_received != tb_expected_output[0])begin
			$info("INCORRECT byte_recieved VALUE!!!");
		end
		if (tb_ack_prep != tb_expected_output[1])begin
			$info("INCORRECT ack_prep VALUE!!!");
		end
		if (tb_check_ack != tb_expected_output[2])begin
			$info("INCORRECT check_ack VALUE!!!");
		end
		if (tb_ack_done != tb_expected_output[3])begin
			$info("INCORRECT ack_done VALUE!!!");
		end
	end
	endtask
endmodule