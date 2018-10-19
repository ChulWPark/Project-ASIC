// $Id: $
// File name:   tb_keygen.sv
// Created:     11/17/2017
// Author:      Sahil Bhalla
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: tb_keygen.sv

`timescale 1ns / 100ps

module tb_keygen
  ();

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

   reg tb_key_gen_enable;
   reg [127:0] tb_key_in;
   reg [127:0] tb_prev_key;
   reg [3:0]   tb_iteration_num;
   reg [127:0] tb_key_out;

	integer i;
	integer j;

   keygen DUT
     (
      .key_gen_enable(tb_key_gen_enable),
      .key_in(tb_key_in),
      .prev_key(tb_prev_key),
      .iteration_num(tb_iteration_num),
      .key_out(tb_key_out)
      );
	parameter NUM_TESTS = 3;

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

   initial
     begin
	for(j = 0; j < NUM_TESTS; j = j + 1) begin
	//Test 0: Default Values
	tb_key_gen_enable = 0;
	tb_key_in = '0;
	tb_prev_key = '0;
	tb_iteration_num = 0;
	@(negedge tb_clk)

	
	$info("Test %d", j + 1);
	//Test 1: Enable Off
	tb_key_in = test_keys[j][0];
	@(negedge tb_clk);
	if(tb_key_out != test_keys[j][0]) begin
		$info("Bad Key_out value");
	end
	
	//Enable On
	tb_key_gen_enable = 1; 
	for(i = 1; i < 11; i = i + 1) begin
		tb_prev_key = test_keys[j][i - 1];
		tb_iteration_num = i;
		@(negedge tb_clk)
		if(tb_key_out != test_keys[j][i]) begin
			$info("Bad Key_out value\nExpected: %h\nActual: %h", test_keys[j][i], tb_key_out);
		end
	end
	
	end
     
     end // initial begin
endmodule // tb_keygen
