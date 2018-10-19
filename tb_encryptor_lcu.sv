// $Id: $
// File name:   tb_encryptor_lcu.sv
// Created:     11/7/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test bench for encryptor logic control unit

`timescale 1ns/10ps

module tb_encryptor_lcu ();
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
	reg tb_key_received;
	reg tb_data_ready;
	reg tb_fifo_full;
	reg tb_data_load;
	reg tb_data_taken;
	reg tb_data_out_load;
	reg tb_data_reg_input;
	reg [1:0] tb_process_output;
	reg tb_ark_enable;
	reg tb_sb_enable;
	reg tb_mc_enable;
	reg tb_sr_enable;
	reg tb_key_gen_enable;
	reg [3:0] tb_iter_in;
	reg [3:0] tb_iter_out;
	reg tb_key_reg_load;

	reg [11:0] tb_expected_outputs;

	integer i;
	
	parameter [3:0]	KEY_WAIT	= 4'd0,

		LOAD_FIRST_KEY	= 4'd1,

		ENABLE_KEY_GEN	= 4'd2,
		LOAD_KEY	= 4'd3,

		LAST_ENABLE	= 4'd4,
		LOAD_LAST_KEY	= 4'd5,

		IDLE		= 4'd6,
	
		LOAD_DATA	= 4'd7,
		ARK_1		= 4'd8,

		SB_2		= 4'd9,
		SR_2		= 4'd10,
		MC_2		= 4'd11,
		ARK_2		= 4'd12,

		SB_3		= 4'd13,
		SR_3		= 4'd14,
		ARK_3		= 4'd15;

	encryptor_lcu DUT (	.clk(tb_clk),
				.n_rst(tb_n_rst),
				.key_received(tb_key_received),
				.data_ready(tb_data_ready),
				.fifo_full(tb_fifo_full),
				.data_load(tb_data_load),
				.data_taken(tb_data_taken),
				.data_out_load(tb_data_out_load),
				.data_reg_input(tb_data_reg_input),
				.process_output(tb_process_output),
				.ark_enable(tb_ark_enable),
				.sb_enable(tb_sb_enable),
				.mc_enable(tb_mc_enable),
				.sr_enable(tb_sr_enable),
				.key_gen_enable(tb_key_gen_enable),
				.iter_in(tb_iter_in),
				.iter_out(tb_iter_out),
				.key_reg_load(tb_key_reg_load)
			);

	initial begin
		//Test 0: Setup
		tb_n_rst = 1; //RST off
		tb_key_received = 0;
		tb_data_ready = 0;
		tb_fifo_full = 0;
		@(negedge tb_clk)
		tb_n_rst = 0;
		@(negedge tb_clk)
		tb_n_rst = 1;
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Test 1: Load Key
		$info("Load Key");
		check_outputs(KEY_WAIT, 0, 0);
		
		tb_key_received = 1;
		@(negedge tb_clk)

		check_outputs(LOAD_FIRST_KEY, 0, 0);
		tb_key_received = 0;


		for (i = 1; i < 10; i = i + 1) begin
			@(negedge tb_clk)
			check_outputs(ENABLE_KEY_GEN, i, i-1);
			@(negedge tb_clk)
			check_outputs(LOAD_KEY, i, i-1);
		end
		@(negedge tb_clk)
		check_outputs(LAST_ENABLE, 10, 9);
		@(negedge tb_clk)
		check_outputs(LOAD_LAST_KEY, 10, 9);
		@(negedge tb_clk)
		check_outputs(IDLE, 0, 0);
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Loop 1
		$info("Loop 1");
		tb_data_ready = 1;
		@(negedge tb_clk)
		check_outputs(LOAD_DATA, 0, 0);
		tb_data_ready = 0;
		@(negedge tb_clk)
		check_outputs(ARK_1, 0, 0);
		for (i = 0; i < 9; i = i + 1) begin
			@(negedge tb_clk)
			check_outputs(SB_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(SR_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(MC_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(ARK_2, 0, i + 1);
		end
		@(negedge tb_clk)
		check_outputs(SB_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(SR_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(ARK_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(IDLE, 0, 0);
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)

		//Loop 2
		$info("Loop 2");
		tb_data_ready = 1;
		@(negedge tb_clk)
		check_outputs(LOAD_DATA, 0, 0);
		tb_data_ready = 0;
		@(negedge tb_clk)
		check_outputs(ARK_1, 0, 0);
		for (i = 0; i < 9; i = i + 1) begin
			@(negedge tb_clk)
			check_outputs(SB_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(SR_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(MC_2, 0, i + 1);
			@(negedge tb_clk)
			check_outputs(ARK_2, 0, i + 1);
		end
		@(negedge tb_clk)
		check_outputs(SB_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(SR_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(ARK_3, 0, 10);
		@(negedge tb_clk)
		check_outputs(IDLE, 0, 0);


	end

	task check_outputs;
		input [3:0] state;
		input [3:0] iter_in;
		input [3:0] iter_out;
	begin
		$info("Start Check -> State: %d", state);
		case(state)
			KEY_WAIT: begin
				tb_expected_outputs = 12'b000000000000;
			end
			LOAD_FIRST_KEY: begin
				tb_expected_outputs = 12'b100000000000;
			end
			ENABLE_KEY_GEN: begin
				tb_expected_outputs = 12'b010000000000;
			end
			LOAD_KEY: begin
				tb_expected_outputs = 12'b110000000000;
			end
			LAST_ENABLE: begin
				tb_expected_outputs = 12'b010000000000;
			end
			LOAD_LAST_KEY: begin
				tb_expected_outputs = 12'b110000000000;
			end
			IDLE: begin
				tb_expected_outputs = 12'b000000000000;
			end
			LOAD_DATA: begin
				tb_expected_outputs = 12'b000000000011;
			end
			ARK_1: begin
				tb_expected_outputs = 12'b000001001001;
			end
			SB_2: begin
				tb_expected_outputs = 12'b000010011001;
			end
			SR_2: begin
				tb_expected_outputs = 12'b001000111001;
			end
			MC_2: begin
				tb_expected_outputs = 12'b000100101001;
			end
			ARK_2: begin
				tb_expected_outputs = 12'b000001001001;
			end
			SB_3: begin
				tb_expected_outputs = 12'b000010011001;
			end
			SR_3: begin
				tb_expected_outputs = 12'b001000111001;
			end
			ARK_3: begin
				tb_expected_outputs = 12'b000001001100;
			end
		endcase
		
		if(tb_expected_outputs[0] != tb_data_load) begin
			$info("INCORRECT data_load value!!!");
		end
		if(tb_expected_outputs[1] != tb_data_taken) begin
			$info("INCORRECT data_taken value!!!");
		end
		if(tb_expected_outputs[2] != tb_data_out_load) begin
			$info("INCORRECT data_out_load value!!!");
		end
		if(tb_expected_outputs[3] != tb_data_reg_input) begin
			$info("INCORRECT data_reg_input value!!!");
		end
		if(tb_expected_outputs[5:4] != tb_process_output) begin
			$info("INCORRECT process_output value!!!");
		end
		if(tb_expected_outputs[6] != tb_ark_enable) begin
			$info("INCORRECT ark_enable value!!!");
		end
		if(tb_expected_outputs[7] != tb_sb_enable) begin
			$info("INCORRECT sb_enable value!!!");
		end
		if(tb_expected_outputs[8] != tb_mc_enable) begin
			$info("INCORRECT mc_enable value!!!");
		end
		if(tb_expected_outputs[9] != tb_sr_enable) begin
			$info("INCORRECT sr_enable value!!!");
		end
		if(tb_expected_outputs[10] != tb_key_gen_enable) begin
			$info("INCORRECT key_gen_enable value!!!");
		end
		if(tb_expected_outputs[11] != tb_key_reg_load) begin
			$info("INCORRECT key_reg_load value!!!");
		end

		if(iter_in != tb_iter_in) begin
			$info("INCORRECT iter_in value!!!");
		end
		if(iter_out != tb_iter_out) begin
			$info("INCORRECT iter_out value!!!");
		end
	end
	endtask

endmodule
