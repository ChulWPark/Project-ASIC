// $Id: $
// File name:   tb_data_ready.sv
// Created:     12/3/2017
// Author:      Kartikeya Mishra
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: test bench for data ready


`timescale 1ns/100 ps

module tb_data_ready();
	
	localparam NUM_CNT_BITS = 8;
	localparam CLK_PERIOD = 5;

	reg tb_clk;
	reg tb_n_rst;
	reg tb_ATD_data;
	reg tb_ATD_clk;
	reg tb_ATD_shift_enable;
	reg tb_data_taken;
	reg tb_data_ready;
	//reg [7:0] tb_count_val;
	//reg tb_intermediate;

	integer i;
	integer j;
	integer n;

	parameter [7:0][127:0] IN_DATA = 	{128'h1234567890abcdef1234567890abcdef,
							128'habc123abc123123abcdef32148394203,
							128'h4729abe64f528ac67dbe8ac92db2631c,
							128'h1935dbe243a6219d8912631a7e29d321,
							128'h102100abd938ff9219310a2137524982,
							128'h12398adbedbe931812398398dab39102,
							128'habde93189f831321989813801fedefed,
							128'h1712419abed81821378dabce998af893};
	
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//DUT port map
	data_ready DUT(.clk(tb_clk), .n_rst(tb_n_rst), .ATD_data(tb_ATD_data), .ATD_shift_enable(tb_ATD_shift_enable), .data_taken(tb_data_taken), .ATD_clk(tb_ATD_clk), .data_ready(tb_data_ready));

	initial begin
		//Test 0: Device Reset
		tb_n_rst = 1'b0;
		tb_ATD_data = 1'b1;
		tb_ATD_clk = 1'b1;
		tb_ATD_shift_enable = 1'b0;
		tb_data_taken = 0;
		system_clock(1);
		tb_n_rst 	= 1'b1;

		//Test 1: Sending Data 
		for(j = 0; j < 8; j = j + 1) begin
			$info("Sending DATA[%d]", j);
			send_data_ATD(IN_DATA[j]);

			if(tb_data_ready != 1) begin
				$info("Incorrect Data Ready Signal");
			end
		
			tb_data_taken = 1;
			@(negedge tb_clk)
			@(negedge tb_clk)
			tb_data_taken = 0;
			if(tb_data_ready != 0) begin
				$info("Incorrect Data Ready Signal");
			end
		end

		//Test 2: Data Back-up
		$info("Sending First Data");
		send_data_ATD(IN_DATA[0]);

		$info("Sending More Bytes");
		send_byte_ATD(8'h3d);
		if(tb_data_ready != 0) begin
			$info("Incorrect Data Ready Signal");
		end
		send_byte_ATD(8'h48);
		if(tb_data_ready != 1) begin
			$info("Incorrect Data Ready Signal");
		end

		tb_data_taken = 1;
		@(negedge tb_clk)
		@(negedge tb_clk)
		tb_data_taken = 0;
		if(tb_data_ready != 0) begin
			$info("Incorrect Data Ready Signal");
		end

		//Test 3: Continued Success
		for(j = 0; j < 8; j = j + 1) begin
			$info("Sending DATA[%d]", j);
			send_data_ATD(IN_DATA[j]);

			if(tb_data_ready != 1) begin
				$info("Incorrect Data Ready Signal");
			end
		
			tb_data_taken = 1;
			@(negedge tb_clk)
			@(negedge tb_clk)
			tb_data_taken = 0;
			if(tb_data_ready != 0) begin
				$info("Incorrect Data Ready Signal");
			end
		end
		
end

task system_clock; //Clocks system clock number of inputted times
	input [7:0] num_cycles;
begin
	for(i = 0; i < 2 * num_cycles; i = i) begin
		@(negedge tb_clk)
		i = i + 1;
	end
end
endtask

task send_data_ATD;
	input [127:0] data;
begin
	send_byte_ATD(data[127:120]);
	send_byte_ATD(data[119:112]);
	send_byte_ATD(data[111:104]);
	send_byte_ATD(data[103:96]);
	send_byte_ATD(data[95:88]);
	send_byte_ATD(data[87:80]);
	send_byte_ATD(data[79:72]);
	send_byte_ATD(data[71:64]);
	send_byte_ATD(data[63:56]);
	send_byte_ATD(data[55:48]);
	send_byte_ATD(data[47:40]);
	send_byte_ATD(data[39:32]);
	send_byte_ATD(data[31:24]);
	send_byte_ATD(data[23:16]);
	send_byte_ATD(data[15:8]);
	send_byte_ATD(data[7:0]);
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
	system_clock(1);
	tb_ATD_clk = 1;
	tb_ATD_shift_enable = 1;
	@(negedge tb_clk)
	tb_ATD_shift_enable = 0;
	@(negedge tb_clk)
	tb_ATD_shift_enable = 0;
end
endtask

endmodule

		
