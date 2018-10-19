// $Id: $
// File name:   tb_i2c_slave.sv
// Created:     10/11/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for top level I2C slave file

`timescale 1ns/100ps

module tb_i2c ();
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

	reg [1:0] tb_scl_write;
	reg [1:0] tb_scl_read;
	reg [1:0] tb_sda_read;
	reg [1:0] tb_sda_write;

	reg tb_master_scl_out;
	reg tb_master_scl_in;
	reg tb_master_sda_in;
	reg tb_master_sda_out;

	reg tb_slave_scl_out = 'z;
	reg tb_slave_scl_in;
	reg tb_slave_sda_in;
	reg tb_slave_sda_out;

	assign tb_scl_write = {tb_slave_scl_out, tb_master_scl_out};
	assign tb_sda_write = {tb_slave_sda_out, tb_master_sda_out};
	assign tb_master_scl_in = tb_scl_read[0];
	assign tb_master_sda_in = tb_sda_read[0];
	assign tb_slave_scl_in  = tb_scl_read[1];
	assign tb_slave_sda_in  = tb_sda_read[1];
	

	reg tb_write_enable;
	reg [127:0] tb_write_data;
	reg tb_fifo_full;
	reg [127:0] tb_key;
	reg tb_key_received;

	parameter [15:0][127:0] BITS = {128'h00112233445566778899AABBCCDDEEFF,
					128'h112233445566778899AABBCCDDEEFF00,
					128'h2233445566778899AABBCCDDEEFF0011,
					128'h33445566778899AABBCCDDEEFF001122,
					128'h445566778899AABBCCDDEEFF00112233,
					128'h5566778899AABBCCDDEEFF0011223344,
					128'h66778899AABBCCDDEEFF001122334455,
					128'h778899AABBCCDDEEFF00112233445566,
					128'h8899AABBCCDDEEFF0011223344556677,
					128'h99AABBCCDDEEFF001122334455667788,
					128'hAABBCCDDEEFF00112233445566778899,
					128'hBBCCDDEEFF00112233445566778899AA,
					128'hCCDDEEFF00112233445566778899AABB,
					128'hDDEEFF00112233445566778899AABBCC,
					128'hEEFF00112233445566778899AABBCCDD,
					128'hFF00112233445566778899AABBCCDDEE};

	integer i;
	integer k;
	integer j;

	i2c DUT(	.clk(tb_clk), 
			.n_rst(tb_n_rst), 
			.scl(tb_slave_scl_in),
			.sda_in(tb_slave_sda_in),
			.sda_out(tb_slave_sda_out),
			.write_enable(tb_write_enable),
			.write_data(tb_write_data),
			.fifo_full(tb_fifo_full),
			.key(tb_key),
			.key_received(tb_key_received)
		);
	
	i2c_bus BUS(	.scl_read(tb_scl_read),
			.scl_write(tb_scl_write),
			.sda_read(tb_sda_read),
			.sda_write(tb_sda_write)
		);

	initial begin
		reset_device;
		
		//Test 1: Load FIFO
		$info("Loading FIFO");
		for(j = 0; j < 16; j = j + 1) begin
			check_fifo_full(0);
			load_fifo_data(BITS[15-j]);
		end
		check_fifo_full(1);
		$info("FIFO LOADED");

		//Test 2: Bad Address
		$info("Testing Bad Address");
		send_start;
		send_byte(8'b10101010,0);
		send_stop;
		$info("Tested Bad Address");

		//Test 3: Read Request
		$info("Testing Read Request");
		send_start;
		send_byte(8'b10110011,0);
		send_stop;
		$info("Tested Read Request");

		//Test 4: Receive Short Key
		$info("Receive Key 80 bits long");
		send_start;
		send_byte(8'b10110010,1); //Send correct start byte
		for (j = 0; j < 10; j = j + 1) begin
			send_byte(8'b11001100,1);
		end
		send_stop;		
		
		$info("Short Key Received");

		//Test 5: Receive 128 bit Key, Nack at end
		$info("Receive Key 128 bits long");
		send_start;
		send_byte(8'b10110010,1); //Send correct start byte
		for (j = 0; j < 15; j = j + 1) begin
			send_byte(8'b11001100,1);
		end
		send_byte(8'b11001100,0);
		send_stop;
		$info("Key Received");

		//Test 6: Write Request NACK
		$info("Testing Receive Request");
		send_start;
		send_byte(8'b10110010,0);
		send_stop;
		$info("Tested Receive Request");

		//Test 7: Write BITS[0]
		$info("Receiving First Bit Loaded");
		send_start;
		send_byte(8'b10110011,1);
	
		receive_process_output(0, 0);
		check_fifo_full(0);
		send_stop;
		$info("Done Writing Data0");

		//Test 8: Write Rest of the BITS
		$info("Writing remaining data");
		send_start;
		send_byte(8'b10110011,1);
		for(j = 1; j < 16; j = j + 1) begin
			receive_process_output(j,j != 15);
			check_fifo_full(0);
		end
		send_stop;
		$info("Done writing remaining data");

		//Test 9: NACK further requests
		$info("Further Transmit Request");
		send_start;
		send_byte(8'b10110011,0);
		check_fifo_full(0);
		send_stop;
		$info("Further Transmit Request Denied");	

		//Test 10: Reset, transmit request
		reset_device;
		$info("Further Transmit Request 2 This time with reset");
		send_start;
		send_byte(8'b10110011,0);
		check_fifo_full(0);
		send_stop;
		$info("Further Transmit Request Denied 2");
		

		
	end

	task receive_process_output;
		input [3:0] start_loc;
		input cont;
	begin
		if(start_loc == 0) begin
			receive_byte(8'h00, 1);
		end
		if (start_loc <= 1) begin
			receive_byte(8'h11, 1);
		end
		if (start_loc <= 2) begin
			receive_byte(8'h22, 1);
		end
		if (start_loc <= 3) begin
			receive_byte(8'h33, 1);
		end
		if (start_loc <= 4) begin
			receive_byte(8'h44, 1);
		end
		if (start_loc <= 5) begin
			receive_byte(8'h55, 1);
		end
		if (start_loc <= 6) begin
			receive_byte(8'h66, 1);
		end
		if (start_loc <= 7) begin
			receive_byte(8'h77, 1);
		end
		if (start_loc <= 8) begin
			receive_byte(8'h88, 1);
		end
		if (start_loc <= 9) begin
			receive_byte(8'h99, 1);
		end
		if (start_loc <= 10) begin
			receive_byte(8'hAA, 1);
		end
		if (start_loc <= 11) begin
			receive_byte(8'hBB, 1);
		end
		if (start_loc <= 12) begin
			receive_byte(8'hCC, 1);
		end
		if (start_loc <= 13) begin
			receive_byte(8'hDD, 1);
		end
		if (start_loc <= 14) begin
			receive_byte(8'hEE, 1);
		end

		receive_byte(8'hFF, (start_loc != 0) || cont);

		if(start_loc > 0) begin
			receive_byte(8'h00, (start_loc != 1) || cont);
		end
		if (start_loc > 1) begin
			receive_byte(8'h11, (start_loc != 2) || cont);
		end
		if (start_loc > 2) begin
			receive_byte(8'h22, (start_loc != 3) || cont);
		end
		if (start_loc > 3) begin
			receive_byte(8'h33, (start_loc != 4) || cont);
		end
		if (start_loc > 4) begin
			receive_byte(8'h44, (start_loc != 5) || cont);
		end
		if (start_loc > 5) begin
			receive_byte(8'h55, (start_loc != 6) || cont);
		end
		if (start_loc > 6) begin
			receive_byte(8'h66, (start_loc != 7) || cont);
		end
		if (start_loc > 7) begin
			receive_byte(8'h77, (start_loc != 8) || cont);
		end
		if (start_loc > 8) begin
			receive_byte(8'h88, (start_loc != 9) || cont);
		end
		if (start_loc > 9) begin
			receive_byte(8'h99, (start_loc != 10) || cont);
		end
		if (start_loc > 10) begin
			receive_byte(8'hAA, (start_loc != 11) || cont);
		end
		if (start_loc > 11) begin
			receive_byte(8'hBB, (start_loc != 12) || cont);
		end
		if (start_loc > 12) begin
			receive_byte(8'hCC, (start_loc != 13) || cont);
		end
		if (start_loc > 13) begin
			receive_byte(8'hDD, (start_loc != 14) || cont);
		end
		if (start_loc > 14) begin
			receive_byte(8'hEE, cont);
		end
	end
	endtask

	task reset_device;
	begin
		//Reset inputs to default
		tb_master_scl_out = 1'b1;
		tb_master_sda_out = 1'b1;
		tb_write_enable = 1'b0;
		tb_write_data = 8'h00;

		tb_n_rst = 1; //RST off
		@(negedge tb_clk)
		tb_n_rst = 0; //RST to ensure freshness
		@(negedge tb_clk)
		tb_n_rst = 1; //RST off

		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		tb_n_rst = 1; //Because task
	end
	endtask

	task send_start;
	begin
		tb_master_sda_out = 1'b1;
		system_clock(5);
		tb_master_scl_out = 1'b1;
		system_clock(3);
		
		@(posedge tb_clk)
		#1; //Advance 1 ns to avoid hold time issues
		
		tb_master_sda_out = 1'b0;
		@(posedge tb_clk)
		system_clock(5);
		tb_master_scl_out = 1'b0;
		system_clock(5);

	end
	endtask
		

	task send_byte; //Master sends inputed byte to slave
		input [7:0] byte_to_send;
		input ack;
	begin
		//$info("Sending Starting Byte: %b", byte_to_send);		
		for( i = 0;  i < 8; i = i + 1) begin
			send_bit(byte_to_send[7-i]);
		end

		//$info("Starting Byte Sent");

		check_ack(ack);

		//$info("Ack Recieved");
		

	end
	endtask

	task send_bit; //sends single bit, starts in middle of sda low
		input bit_to_send;
	begin
		if(tb_master_scl_out != 0) begin
			$info("INCORRECT TEST BENCH CONDITIONS: send_bit");
		end
		
		system_clock(8);
		tb_master_sda_out = bit_to_send;
		system_clock(2);
		tb_master_scl_out = 1'b1;
		system_clock(10);
		tb_master_scl_out = 1'b0;
		system_clock(2);
		tb_master_sda_out = 1'b1;
		system_clock(8);
	end
	endtask

	task system_clock; //Clocks system clock number of inputted times
		input [7:0] num_cycles;
	begin
		for(k = 0; k < 2 * num_cycles; k = k + 1) begin
			@(negedge tb_clk)
			tb_n_rst = 1'b1;
		end
	end
	endtask

	task send_stop; //Sends stop
	begin
		if(tb_master_scl_out != 1'b0) begin
			$info("INCORRECT TEST BENCH CONDITIONS: send_stop");
		end

		tb_master_sda_out = 1'b0;
		system_clock(5);
		tb_master_scl_out = 1'b1;
		system_clock(3);
	
		@(posedge tb_clk)
		#1; //Advance 1 ns to avoid hold time issues
		
		tb_master_sda_out = 1'b1;
		@(posedge tb_clk)
		@(negedge tb_clk)
		$info("Stop Sent");
	end
	endtask

	task check_ack;
		input ack_expected;
	begin
		if(tb_master_scl_out != 0) begin
			$info("INCORRECT TEST BENCH CONDITIONS: check_ack");
		end
		
		system_clock(10);
		tb_master_scl_out = 1'b1;
		system_clock(5);
	
		if(tb_master_sda_in == ack_expected) begin
			$info("INCORRECT ACK VALUE!");
		end

		system_clock(5);
		tb_master_scl_out = 1'b0;
		system_clock(10);
	end
	endtask

	task load_fifo_data;
		input [127:0] load_byte;
	begin
		tb_write_data = load_byte;
		system_clock(1);
		tb_write_enable = 1'b1;
		system_clock(1);
		tb_write_enable = 1'b0;
		system_clock(5);
	end
	endtask

	task check_fifo_full;
		input expected;
	begin
		if (expected != tb_fifo_full) begin
			$info("INCORRECT fifo_full value");
		end
	end
	endtask

	task receive_byte;
		input [7:0] expected_byte;
		input ack;
	begin
		$info("Receiving Byte: %b", expected_byte);		
		for( i = 0;  i < 8; i = i + 1) begin
			receive_bit(expected_byte[7-i]);
		end

		$info("Sending Ack");
		send_ack(ack);
		$info("Byte Recieved");

	end
	endtask

	task receive_bit;
		input expected_bit;
	begin
		if(tb_master_scl_out != 0) begin
			$info("INCORRECT TEST BENCH CONDITIONS: send_bit");
		end
		
		system_clock(8);
		system_clock(2);
		tb_master_scl_out = 1'b1;
		system_clock(10);
		tb_master_scl_out = 1'b0;

		if(tb_master_sda_in != expected_bit) begin
			$info("INCORRECT BIT RECIEVED");		
		end
		system_clock(10);
	end
	endtask

	task send_ack;
		input ack;
	begin
		if(tb_master_scl_out != 0) begin
			$info("INCORRECT TEST BENCH CONDITIONS: check_ack");
		end
		
		system_clock(8);
		tb_master_sda_out = !ack;
		system_clock(2);
		tb_master_scl_out = 1'b1;
		system_clock(5);
	
		if(tb_master_sda_in == ack) begin
			$info("INCORRECT ACK VALUE!");
		end

		system_clock(5);
		tb_master_scl_out = 1'b0;
		system_clock(2);
		tb_master_sda_out = 1'b1;
		system_clock(8);
	end
	endtask
endmodule