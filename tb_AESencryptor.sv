// $Id: $
// File name:   tb_AESencryptor.sv
// Created:     12/4/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_AESencryptor.sv

`timescale 1ns / 10ps

module tb_AESencryptor
  ();
   localparam CLK_PERIOD = 5; //200MHz Clock
   reg tb_clk;
   always
     begin
	tb_clk = 1'b0;
	#(CLK_PERIOD/2.0);
	tb_clk = 1'b1;
	#(CLK_PERIOD/2.0);
     end
   	
	reg tb_n_rst;
   	reg tb_ATD_data;
   	reg tb_ATD_clk;

	integer i;
	integer j;
	integer k;
	integer n;
	integer m;

	parameter NUM_TESTS = 3;
	parameter NUM_DATA = 8;

	parameter [NUM_TESTS - 1:0][127:0] KEYS = 	{128'h746869736973616b6579666561726d65,
							128'h303132746865736b666164666a383132,
							128'h68656c6c6f3030303030303030303030};

	parameter [NUM_DATA - 1:0][127:0] IN_DATA = 	{128'h1234567890abcdef1234567890abcdef,
							128'habc123abc123123abcdef32148394203,
							128'h4729abe64f528ac67dbe8ac92db2631c,
							128'h1935dbe243a6219d8912631a7e29d321,
							128'h102100abd938ff9219310a2137524982,
							128'h12398adbedbe931812398398dab39102,
							128'habde93189f831321989813801fedefed,
							128'h1712419abed81821378dabce998af893};

	parameter [NUM_TESTS - 1:0][NUM_DATA - 1:0][127:0] OUT_DATA = 	{{128'h2ce2c3408ce0aca66e86b19ce60c0abc,
							128'he4e4e3b80e35e7c610c6f006293848bd,
							128'haeecc2954fbf2245c43775635628bff7,
							128'hf9133895e2a6e534649be82f3c08b9a4,
							128'hdff39131a397727bdedcc5a4bf26d781,
							128'hc47ce8c0c5206eb8b3fd3d047e3f315c,
							128'h450c8814665b06add930c9f3f5e69df8,
							128'h9504ab2754ea076b987ca8e6435440e8},
							
							{128'h3d5d5173d153be7ec0cf1b66b250b646,
							128'h7e0d2a826809f107d7fba212c4ad6bcc,
							128'h1b597ed7a32ee07a1536c7f7d1dbf383,
							128'hee3e975814d8fdb7ece18abc2a3863ad,
							128'h462a54eea9033847505286afe8f74bde,
							128'h8c2eccb0ec68d74e950c6de25e6a80a2,
							128'hc44c5233bc7aa80ca63b3d5c01949808,
							128'h20dc8031666f0896e3128f0a1024f95c},

							{128'h4d8c92fbb7e27e97d799eac0df8553c7,
							128'hd5fbe6ea1aef44409162dd9bfd1c4b1f,
							128'h6cc8671fcf024e0b939944c7207c990a,
							128'h77bfadadb93c4df1c012eda6674f4d37,
							128'h8c60364d3e1677490fc80e2ce4c34085,
							128'h21f07130aa523de25d0d7bd372992612,
							128'h274499d2205e8de819e58783a68d0053,
							128'h99547e4e6a082a1400ed190e258b041d}};

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
   
AESencryptor DUT (	.clk(tb_clk),
	  		.n_rst(tb_n_rst),
	  		.ATD_data(tb_ATD_data),
	  		.ATD_clk(tb_ATD_clk),
	  		.scl(tb_slave_scl_in),
			.sda_in(tb_slave_sda_in),
			.sda_out(tb_slave_sda_out));

i2c_bus BUS(	.scl_read(tb_scl_read),
		.scl_write(tb_scl_write),
		.sda_read(tb_sda_read),
		.sda_write(tb_sda_write));

   initial
     begin
	//Test 0: Resetting Device
	reset_device;
	$info("Device Reset");

	//Test 1: Receive Key Upon Reset
	$info("Test 1: Receive Key Through I2C");

	send_start;
	send_byte(8'b10110010,1); //Send correct start byte
	send_key(KEYS[0]);
	send_stop;

	$info("Key Sent to Device\n\nExpected Value on Key Line: %x\n", KEYS[0]);

	//Test 2: Receive Data From ATD
	$info("Test 2: Send Data From ATD to be Encrypted");
	send_data_ATD(IN_DATA[0]);
	$info("Data Sent to ATD\n\nExpected Value on ATD_parallel: %x\n", IN_DATA[0]);
	$info("Data Sent to tx_fifo\n\nExpected Value on ATD_parallel: %x\n", OUT_DATA[0][0]);

	//Test 3: Receive Encryption Result on I2C line
	$info("Reading Encrypted Data From I2C");
	send_start;
	send_byte(8'b10110011,1);
	receive_data(OUT_DATA[0][0], 0);
	send_stop;
	$info("Encrypted Data Read");

	//Test 4: Fill tx_fifo
	$info("Filling tx_fifo");
	for(m = 0; m < 8; m = m + 1) begin
		send_data_ATD(IN_DATA[m]);
	end
	for(m = 0; m < 8; m = m + 1) begin
		send_data_ATD(IN_DATA[m]);
	end
	$info("Filled tx_fifo");

	$info("Sending 1 more data piece");
	send_data_ATD(IN_DATA[0]);
	$info("Data Ready Should Trigger Every 16 bits Since Data is not taken (fifo_full = 1)");
	send_byte_ATD(8'h34);
	send_byte_ATD(8'h4a);

	//Test 5: Receiving Data From Full Fifo
	$info("Receiving data from the full fifo");
	send_start;
	send_byte(8'b10110011,1);
	$info("Data Should start processing in encryption block");
	receive_data(OUT_DATA[0][0], 1);
	receive_data(OUT_DATA[0][1], 1);
	receive_data(OUT_DATA[0][2], 0);
	send_stop;
	
	// EDGE CASES // ERROR CASES //
	reset_device;
	$info("Device Reset");
	$info("Edge Cases and Errors Prevention");

	//Test 6: Sending Key <128 bits
	$info("Receive Key 80 bits long");
	send_start;
	send_byte(8'b10110010,1); //Send correct start byte
	for (j = 0; j < 10; j = j + 1) begin
		send_byte(8'b11001100,1);
	end
	send_stop;	
	$info("Key is rejected and not loaded into key reg");

	//Test 7: Read Request without Key Loaded in
	$info("Testing Read Request");
	send_start;
	send_byte(8'b10110011,0);
	send_stop;
	$info("Device NACKs read request because fifo is empty");

	//Test 8: Loading in Data which won't be taken due to no key
	$info("Loading Data into ATD");	
	send_data_ATD(IN_DATA[0]);
	$info("Data loaded in but is not taken due to no key");

	//Test 9: Loading In New Key
	$info("Loading in New key to Start Data Processing");
	send_start;
	send_byte(8'b10110010,1); //Send correct start byte
	send_key(KEYS[1]);
	send_stop;
	$info("New Key Loaded, Data Processed");

	//Test 10: Receive Data from I2C
	$info("Receiving data through I2c");
	send_start;
	send_byte(8'b10110011,1);
	receive_data(OUT_DATA[1][0], 0);
	send_stop;
	$info("Data Received");

	//Test 11: FIFO Empty NACK
	$info("Testing Read Request");
	send_start;
	send_byte(8'b10110011,0);
	send_stop;
	$info("Read request NACKed due to empty fifo");
	
     end

task send_data_ATD;
	input [127:0] data;
begin
	send_byte_ATD(data[7:0]);
	send_byte_ATD(data[15:8]);
	send_byte_ATD(data[23:16]);
	send_byte_ATD(data[31:24]);
	send_byte_ATD(data[39:32]);
	send_byte_ATD(data[47:40]);
	send_byte_ATD(data[55:48]);
	send_byte_ATD(data[63:56]);
	send_byte_ATD(data[71:64]);
	send_byte_ATD(data[79:72]);
	send_byte_ATD(data[87:80]);
	send_byte_ATD(data[95:88]);
	send_byte_ATD(data[103:96]);
	send_byte_ATD(data[111:104]);
	send_byte_ATD(data[119:112]);
	send_byte_ATD(data[127:120]);
end
endtask

task send_byte_ATD;
	input [7:0] send_byte;
begin
	for(n = 0; n < 8; n = n + 1) begin
		send_bit_ATD(send_byte[n]);
	end
end
endtask

task send_bit_ATD;
	input send_bit;
begin
	if(tb_ATD_clk == 0) begin
		$info("ERROR: Bad ATD_clk value!!!!");
	end
	
	tb_ATD_clk = 0;
	tb_ATD_data = send_bit;
	system_clock(4);
	tb_ATD_clk = 1;
	system_clock(4);
end
endtask
	

task send_key;
	input [127:0] key;
begin
	send_byte(key[127:120],1);
	send_byte(key[119:112],1);
	send_byte(key[111:104],1);
	send_byte(key[103:96],1);
	send_byte(key[95:88],1);
	send_byte(key[87:80],1);
	send_byte(key[79:72],1);
	send_byte(key[71:64],1);
	send_byte(key[63:56],1);
	send_byte(key[55:48],1);
	send_byte(key[47:40],1);
	send_byte(key[39:32],1);
	send_byte(key[31:24],1);
	send_byte(key[23:16],1);
	send_byte(key[15:8],1);
	send_byte(key[7:0],0);
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
	tb_master_sda_out = 1'b1;
	//$info("Stop Sent");
end
endtask

task send_byte; //Master sends inputed byte to slave
	input [7:0] byte_to_send;
	input ack;
begin
	//$info("Sending Starting Byte: %b", byte_to_send);		
	for( k = 0;  k < 8; k = k + 1) begin
		send_bit(byte_to_send[7-k]);
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

task receive_data;
	input [127:0] expected_data;
	input ack_end;
begin
	$info("Receiving Data: %x", expected_data);
	receive_byte(expected_data[127:120],1);
	receive_byte(expected_data[119:112],1);
	receive_byte(expected_data[111:104],1);
	receive_byte(expected_data[103:96],1);
	receive_byte(expected_data[95:88],1);
	receive_byte(expected_data[87:80],1);
	receive_byte(expected_data[79:72],1);
	receive_byte(expected_data[71:64],1);
	receive_byte(expected_data[63:56],1);
	receive_byte(expected_data[55:48],1);
	receive_byte(expected_data[47:40],1);
	receive_byte(expected_data[39:32],1);
	receive_byte(expected_data[31:24],1);
	receive_byte(expected_data[23:16],1);
	receive_byte(expected_data[15:8],1);
	receive_byte(expected_data[7:0],ack_end);
end
endtask

task receive_byte;
	input [7:0] expected_byte;
	input ack;
begin
	//$info("Receiving Byte: %b", expected_byte);		
	for( j = 0;  j < 8; j = j + 1) begin
		receive_bit(expected_byte[7-j]);
	end

	//$info("Sending Ack");
	send_ack(ack);
	//$info("Byte Recieved");

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

task system_clock; //Clocks system clock number of inputted times
	input [7:0] num_cycles;
begin
	for(i = 0; i < 2 * num_cycles; i = i) begin
		@(negedge tb_clk)
		i = i + 1;
	end
end
endtask

task reset_device;
begin
	//Reset inputs to default
	tb_master_scl_out = 1'b1;
	tb_master_sda_out = 1'b1;
	tb_ATD_data = 1;
	tb_ATD_clk = 1;
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
endmodule // tb_AESencryptor
   
   
