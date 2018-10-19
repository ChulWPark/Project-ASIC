// $Id: $
// File name:   tb_encryption.sv
// Created:     12/3/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_encryption.sv

`timescale 1ns / 10ps

module tb_encryption();
   localparam CLK_PERIOD = 5;

   reg tb_clk;
   always
     begin
	tb_clk = 1'b0;
	#(CLK_PERIOD/2.0);
	tb_clk = 1'b1;
	#(CLK_PERIOD/2.0);
     end

   reg tb_n_rst;
   reg [127:0] tb_ATD_parallel;
   reg 	       tb_key_received;
   reg 	       tb_data_ready;
   reg [127:0] tb_key;
   reg 	       tb_data_out_load;
   reg 	       tb_data_taken;
   reg [127:0] tb_process_out_data;
	reg tb_fifo_full;

   integer i;
   integer j;
   integer k;
   integer m;

   encryption
     DUT (
	  .clk(tb_clk),
	  .n_rst(tb_n_rst),
	  .ATD_parallel(tb_ATD_parallel),
	  .key_received(tb_key_received),
	  .data_ready(tb_data_ready),
	  .key(tb_key),
	  .data_out_load(tb_data_out_load),
	  .data_taken(tb_data_taken),
	  .process_out_data(tb_process_out_data),
	  .fifo_full(tb_fifo_full)
	  );

   	parameter NUM_TESTS = 3;
	parameter NUM_DATA = 8;

	parameter [NUM_TESTS - 1:0] [10:0] [127:0] test_keys =	{{128'h0043de6459c9e24b5a4ebb8add080009,
						128'h6ca93273598a3c2f038759c18746bb83,
						128'h0f311e2c35230e5c5a0d65ee84c1e242,
						128'hc4268f313a1210706f2e6bb2decc87ac,
						128'h1ce8fdf9fe349f41553c7bc2b1e2ec1e,
						128'h21607b90e2dc62b8ab08e483e4de97dc,
						128'hc7efb414c3bc192849d4863b4fd6735f,
						128'hb809f77b0453ad3c8a689f130602f564,
						128'hbe0b021fbc5a5a478e3b322f8c6a6a77,
						128'h6d616868025158583261686802515858,
						128'h68656c6c6f3030303030303030303030},

						{128'h41dce20887d2dea92f284e8bbeeefb52,
						128'hc309d789c60e3ca1a8fa902291c6b5d9,
						128'h3336d89b0507eb286ef4ac83393c25fb,
						128'h5b9164c0363133b36bf347ab57c88978,
						128'hf91a022b6da057735dc274183c3bced3,
						128'h40ee1dc494ba55583062236b61f9bacb,
						128'h4400fd15d454489ca4d87633519b99a0,
						128'h56df21f39054b589708c3eaff543ef93,
						128'hd8e1ca64c68b947ae0d88b2685cfd13c,
						128'h2a5f68291e6a5e1e26531f5c65175a1a,
						128'h30313233343536373839414243444546},

						{128'h4fb4bd8386b3fa3fa420ed13105e2238,
						128'h8a3e4c0ec90747bc2293172cb47ecf2b,
						128'hc45f899e43390bb2eb94509096edd807,
						128'hf29b01618766822ca8ad5b227d798897,
						128'hfafdd46275fd834d2fcbd90ed5d4d3b5,
						128'h1a9a3e4f8f00572f5a365a43fa1f0abb,
						128'hafc97faf959a6960d5360d6ca02950f8,
						128'h67855d323a5316cf40ac640c751f5d94,
						128'h0e971ba45dd64bfd7aff72c335b33998,
						128'h25242220534150592729393e4f4c4b5b,
						128'h69646f65766572797468696768657265}};

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
 

   
   initial
     begin
	//Test 0: Reset Device
	tb_fifo_full = 0;
	tb_ATD_parallel = '0;
	tb_key_received = 0;
	tb_data_ready = 0;
	tb_key = '0;	
	tb_n_rst = 1'b1;
	reset_device;

	//Test 1: No Run on Data Ready Signal
	$info("Test 1: No Run on Data Ready Signal"); 
	tb_data_ready = 1;
	for(j = 0; j < 100; j = j + 1) begin
		clock_cycle(1);
		if (tb_data_out_load == 1 || tb_data_taken == 1) begin
			$info("Bad Value on data_taken or data_out_load");
		end
	end
	tb_data_ready = 0;
	for(j = 0; j < 100; j = j + 1) begin
		clock_cycle(1);
		if (tb_data_out_load == 1 || tb_data_taken == 1) begin
			$info("Bad Value on data_taken or data_out_load");
		end
	end

	//Test 2: Load Key, Test Key Gen (use wave inspection)
	$info("Test 2: Load Key, Test Key Gen (use wave inspection)");
	tb_key = test_keys[2][0];
	tb_key_received = 1;
	clock_cycle(1);
	if(tb_data_taken != 0) begin
		$info("Data taken");
	end
	for(j = 0; j < 100; j = j + 1) begin
		clock_cycle(1);
		if (tb_data_out_load == 1 || tb_data_taken == 1) begin
			$info("Bad Value on data_taken or data_out_load");
		end
	end
	for(j = 0; j < 11; j = j + 1) begin
		$info("Key Round: %d  Value: %h", j, test_keys[2][j]);
	end


	//Test3: Full Test
	$info("Test 3: Test for accepting data and verifying the result with AES encryption");
	for(j = 0; j < NUM_TESTS; j = j + 1) begin
		reset_device;
		$info("Test Occuring Data");
		
		tb_key = KEYS[j];
		tb_key_received = 1;
		clock_cycle(1);
		if(tb_data_taken != 0) begin
			$info("Data taken");
		end
		for(k = 0; k < 50; k = k + 1) begin
			clock_cycle(1);
			if (tb_data_out_load == 1 || tb_data_taken == 1) begin
				$info("Bad Value on data_taken or data_out_load");
			end
		end

		for(k = 0 ; k < NUM_DATA; k = k + 1) begin
			tb_ATD_parallel = IN_DATA[k];
			tb_data_ready = 1'b1;  
			clock_cycle(1);
			tb_data_ready = 1'b0; 
			if(tb_data_taken != 1) begin
				$info("Data not taken");
			end
			for(m = 0; m < 100; m = m + 1) begin
				clock_cycle(1);
				if (tb_data_out_load == 1) begin
					if(tb_process_out_data != OUT_DATA[j][k]) begin
						$info("Data doesn't match\nRESULT: %x", tb_process_out_data);
						m = 100;
					end
				end
			end
	
		end
	end
	$info("Done");

	
     end


task reset_device;
begin
	@(negedge tb_clk)
	tb_n_rst = 1'b0;
	tb_ATD_parallel = '0;
	tb_key_received = 0;
	tb_data_ready = 0;
	tb_key = '0;	
	@(negedge tb_clk)
	$info("Resetting device");
	tb_n_rst = 1'b1;
	@(negedge tb_clk)
	@(negedge tb_clk)
	@(negedge tb_clk)
	@(negedge tb_clk)
	tb_n_rst = 1'b1;
end
endtask

task clock_cycle;
	input [7:0] cycles;
begin
	for(i = 0; i < cycles; i = i) begin
		@(negedge tb_clk)
		i = i + 1;
	end
end
endtask

endmodule // tb_encryption 
   
