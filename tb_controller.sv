// $Id: $
// File name:   tb_controller.sv
// Created:     10/4/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for I2c controller block

`timescale 1ns/100ps

module tb_controller ();
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
	reg tb_stop_found;
	reg tb_start_found;
	reg tb_byte_received;
	reg tb_ack_prep;
	reg tb_check_ack;
	reg tb_ack_done;
	reg tb_rw_mode;
	reg tb_address_match;
	reg tb_sda_in;
	reg tb_key_received;
	reg tb_fifo_empty;

	reg tb_rx_enable;
	reg tb_tx_enable;
	reg tb_read_enable;
	reg [1:0] tb_sda_mode;
	reg tb_load_data;
	reg tb_reg_enable;
	reg tb_start_byte_received;
	reg tb_key_loaded;

	reg tb_key_triggered;

	reg [3:0] tb_expected_state;
	reg [8:0] tb_expected_output;

	integer wait_cycles;
	reg val_address_match;
	reg val_rw_mode;
	integer end_option;

	parameter [3:0]	IDLE 		= 4'b0000,
		WAIT_FOR_BYTE 	= 4'b0001,
		PREP_ACK 	= 4'b0010,
		ACK_TX 		= 4'b0011,
		LOAD_BYTE 	= 4'b0100,
		SEND_BYTE 	= 4'b0101,
		MAKE_BUS_IDLE 	= 4'b0110,
		MASTER_ACK 	= 4'b0111,
		RX_WAIT		= 4'b1000,
		ACK_RX		= 4'b1001,
		RX_BYTE		= 4'b1010,
		RX_ACK_PREP	= 4'b1011,
		RX_REG_LOAD	= 4'b1100,
		RX_KEY_SIGNAL	= 4'b1101;

	integer i;
	integer j;
	integer k;

	controller DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst), 
			.stop_found(tb_stop_found),
			.start_found(tb_start_found) ,
			.byte_received(tb_byte_received),
			.ack_prep(tb_ack_prep),
			.check_ack(tb_check_ack),
			.ack_done(tb_ack_done),
			.rw_mode(tb_rw_mode),
			.address_match(tb_address_match),
			.key_received(tb_key_received),
			.sda_in(tb_sda_in),
			.fifo_empty(tb_fifo_empty),

			.rx_enable(tb_rx_enable),
			.tx_enable(tb_tx_enable),
			.read_enable(tb_read_enable),
			.sda_mode(tb_sda_mode),
			.load_data(tb_load_data),
			.reg_enable(tb_reg_enable),
			.start_byte_received(tb_start_byte_received),
			.key_loaded(tb_key_loaded)		
		);

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_stop_found = 0;
		tb_start_found = 0;
		tb_byte_received = 0;
		tb_ack_prep = 0;
		tb_check_ack = 0;
		tb_ack_done = 0;
		tb_rw_mode = 0;
		tb_address_match = 0;
		tb_sda_in = 1;
		tb_key_received = 0;
		tb_fifo_empty = 1;

		tb_key_triggered = 0;
		
		reset_device;

		$info("Device Reset, Tests Beginning");

		wait_cycles = 5;
		wait_time;

		tb_expected_state = IDLE;
		check_results;

		//Test 1: Nack Bad Address, Receive Request
		$info("TEST: Nack Bad Address, Receive Request");

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		tb_rw_mode = 0;
		tb_address_match = 0;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = IDLE;
		check_results;

		wait_time;

		//Test 2: Nack Transmit Request
		$info("TEST: Nack Transmit Request");	

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		tb_rw_mode = 1;
		tb_address_match = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = IDLE;
		check_results;

		wait_time;

		//Test 3: Accept Receive Request
		$info("TEST: Accept Receive Request");	

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		for(k = 0; k < 16; k = k + 1) begin

		tb_ack_prep = 1;
		tb_rw_mode = 0;
		tb_address_match = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = ACK_RX;
		check_results;

		wait_time;

		tb_ack_done = 1;
		@(negedge tb_clk)
		tb_ack_done = 0;

		tb_expected_state = RX_BYTE;
		check_results;

		wait_time;
	
		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = RX_ACK_PREP;
		check_results;

		wait_time;

		end

		tb_key_received = 1;
		@(negedge tb_clk)
		tb_key_received = 0;

		tb_expected_state = RX_REG_LOAD;
		check_results;

		@(negedge tb_clk)
		tb_expected_state = RX_KEY_SIGNAL;
		check_results;

		@(negedge tb_clk)
		tb_expected_state = IDLE;
		check_results;
		
		wait_time;

		//Test 4: Nack Transmit Request Empty Fifo
		$info("TEST: Nack Transmit Request Empty Fifo");	

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		tb_rw_mode = 0;
		tb_address_match = 1;
		tb_fifo_empty = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = IDLE;
		check_results;

		wait_time;

		//Test 5: Accept Transmit Request
		$info("TEST: Accept Transmit Request");	

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		tb_rw_mode = 1;
		tb_address_match = 1;
		tb_fifo_empty = 0;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = ACK_TX;
		check_results;

		tb_ack_done = 1;
		@(negedge tb_clk)
		tb_ack_done = 0;

		tb_expected_state = LOAD_BYTE;
		check_results;

		for(k = 0; k < 16; k = k + 1) begin

		tb_ack_done = 1;
		@(negedge tb_clk)
		tb_ack_done = 0;

		tb_expected_state = SEND_BYTE;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = MAKE_BUS_IDLE;
		check_results;

		wait_time;

		tb_check_ack = 1;
		@(negedge tb_clk)
		tb_check_ack = 0;

		tb_expected_state = MASTER_ACK;
		check_results;

		wait_time;

		tb_sda_in = 0;
		@(negedge tb_clk)
		tb_sda_in = 1;

		tb_expected_state = RX_WAIT;
		check_results;

		wait_time;

		end

		tb_key_received = 1;
		tb_ack_done = 1;
		@(negedge tb_clk)
		tb_key_received = 0;
		tb_ack_done = 0;

		tb_expected_state = LOAD_BYTE;
		check_results;

		@(negedge tb_clk)

		tb_expected_state = SEND_BYTE;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = MAKE_BUS_IDLE;
		check_results;

		wait_time;

		tb_check_ack = 1;
		@(negedge tb_clk)
		tb_check_ack = 0;

		tb_expected_state = MASTER_ACK;
		check_results;

		tb_stop_found = 1;
		@(negedge tb_clk)
		tb_stop_found = 0;

		tb_expected_state = IDLE;
		check_results;
		

		//Test 6: Nack Receive Request
		$info("TEST: Nack Receive Request");	

		tb_start_found = 1;
		@(negedge tb_clk)
		tb_start_found = 0;

		tb_expected_state = WAIT_FOR_BYTE;
		check_results;

		wait_time;

		tb_byte_received = 1;
		@(negedge tb_clk)
		tb_byte_received = 0;

		tb_expected_state = PREP_ACK;
		check_results;

		wait_time;

		tb_ack_prep = 1;
		tb_rw_mode = 0;
		tb_address_match = 1;
		@(negedge tb_clk)
		tb_ack_prep = 0;

		tb_expected_state = IDLE;
		check_results;

		wait_time;
	
		tb_expected_state = IDLE;
		check_results;

		//Test 7: Reset Key Received
		$info("TEST: Reset Key Received");	
		reset_device;

		wait_cycles = 5;
		wait_time;

		tb_expected_state = IDLE;
		check_results;

		$info("TESTS DONE");


	end

	task wait_time;
	begin
		for(i = 0; i < wait_cycles; i = i + 1) begin
			@(negedge tb_clk)
			j = 0;
		end
	end
	endtask

	task check_results;
	begin
		case(tb_expected_state)
			IDLE, MAKE_BUS_IDLE, MASTER_ACK, RX_ACK_PREP, RX_WAIT: begin
				tb_expected_output = 9'b000000000;
			end
			PREP_ACK: begin
				tb_expected_output = 9'b010000000;
			end
			WAIT_FOR_BYTE, RX_BYTE: begin
				tb_expected_output = 9'b000100000;
			end
			ACK_TX, ACK_RX: begin
				tb_expected_output = 9'b000000010;
			end
			LOAD_BYTE: begin
				tb_expected_output = 9'b000001001;
			end		
			SEND_BYTE: begin
				tb_expected_output = 9'b000010110;
			end
			RX_REG_LOAD: begin
				tb_expected_output = 9'b001000000;
			end
			RX_KEY_SIGNAL: begin
				tb_expected_output = 9'b100000000;
			end
		endcase

		if (tb_expected_output[8] == 1 || tb_key_triggered == 1) begin
			tb_expected_output[8] = 1;
			tb_key_triggered = 1;
		end

		if (tb_key_loaded != tb_expected_output[8]) begin
			$info("INCORRECT KEY_LOADED VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_start_byte_received != tb_expected_output[7]) begin
			$info("INCORRECT start_byte_received VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_reg_enable != tb_expected_output[6]) begin
			$info("INCORRECT reg_enable VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_rx_enable != tb_expected_output[5]) begin
			$info("INCORRECT RX_ENABLE VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_tx_enable != tb_expected_output[4])begin
			$info("INCORRECT TX_ENABLE VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_read_enable != tb_expected_output[3])begin
			$info("INCORRECT READ_ENABLE VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_sda_mode != tb_expected_output[2:1])begin
			$info("INCORRECT SDA_MODE VALUE!!!, State: %d", tb_expected_state);
		end
		if (tb_load_data != tb_expected_output[0])begin
			$info("INCORRECT LOAD_DATA VALUE!!!, State: %d", tb_expected_state);
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
		tb_key_triggered = 0;
	end
	endtask
			

endmodule