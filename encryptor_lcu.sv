// $Id: $
// File name:   encryptor_lcu.sv
// Created:     10/31/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: The logic control unit for the device, controls encryption process

module encryptor_lcu
(
	input  wire clk,
	input  wire n_rst,
	input  wire key_received,
	input  wire data_ready,
	input  wire fifo_full,
	output wire data_load,
	output wire data_taken,
	output wire data_out_load,
	output wire data_reg_input,
	output wire [1:0] process_output,
	output wire ark_enable,
	output wire sb_enable,
	output wire mc_enable,
	output wire sr_enable,
	output wire key_gen_enable,
	output wire [3:0] iter_in,
	output wire [3:0] iter_out,
	output wire key_reg_load
);

reg next_data_load;
reg next_data_taken;
reg next_data_out_load;
reg next_data_reg_input;
reg [1:0] next_process_output;
reg next_ark_enable;
reg next_sb_enable;
reg next_mc_enable;
reg next_sr_enable;
reg next_key_gen_enable;
reg [3:0] next_iter_in;
reg [3:0] next_iter_out;
reg next_key_reg_load;

reg reg_data_load;
reg reg_data_taken;
reg reg_data_out_load;
reg reg_data_reg_input;
reg [1:0] reg_process_output;
reg reg_ark_enable;
reg reg_sb_enable;
reg reg_mc_enable;
reg reg_sr_enable;
reg reg_key_gen_enable;
reg [3:0] reg_iter_in;
reg [3:0] reg_iter_out;
reg reg_key_reg_load;

assign data_load 	= reg_data_load;
assign data_taken 	= reg_data_taken;
assign data_out_load 	= reg_data_out_load;
assign data_reg_input 	= reg_data_reg_input;
assign process_output 	= reg_process_output;
assign ark_enable 	= reg_ark_enable;
assign sb_enable 	= reg_sb_enable;
assign mc_enable 	= reg_mc_enable;
assign sr_enable 	= reg_sr_enable;
assign key_gen_enable	= reg_key_gen_enable;
assign iter_in		= reg_iter_in;
assign iter_out		= reg_iter_out;
assign key_reg_load	= reg_key_reg_load;

reg [3:0] state, next_state;
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

reg count_clear;
reg next_count_clear;
reg count_enable;
reg next_count_enable;
reg stage_done;
reg [3:0] count_out;

flex_counter stage_count (.clk(clk), .n_rst(n_rst), .clear(count_clear), .count_enable(count_enable), .rollover_val(4'd9), .rollover_flag(stage_done), .count_out(count_out) );
		

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		reg_data_load 		<= 0;
		reg_data_taken	 	<= 0;
		reg_data_out_load	<= 0;
		reg_data_reg_input 	<= 0;
		reg_process_output 	<= 0;
		reg_ark_enable		<= 0;
		reg_sb_enable		<= 0;
		reg_mc_enable		<= 0;
		reg_sr_enable		<= 0;
		state			<= KEY_WAIT;
		count_clear		<= 0;
		count_enable		<= 0;
		reg_key_gen_enable	<= 0;
		reg_iter_in		<= 0;
		reg_iter_out		<= 0;
		reg_key_reg_load	<= 0;
	end else begin
		reg_data_load 		<= next_data_load;
		reg_data_taken	 	<= next_data_taken;
		reg_data_out_load	<= next_data_out_load;
		reg_data_reg_input 	<= next_data_reg_input;
		reg_process_output 	<= next_process_output;
		reg_ark_enable		<= next_ark_enable;
		reg_sb_enable		<= next_sb_enable;
		reg_mc_enable		<= next_mc_enable;
		reg_sr_enable		<= next_sr_enable;
		state			<= next_state;
		count_clear		<= next_count_clear;
		count_enable		<= next_count_enable;
		reg_key_gen_enable	<= next_key_gen_enable;
		reg_iter_in		<= next_iter_in;
		reg_iter_out		<= next_iter_out;
		reg_key_reg_load	<= next_key_reg_load;
	end
end

always_comb begin
	next_state 		= state;

	case(state)
		KEY_WAIT: begin
			if(key_received == 1) begin			
				next_state = LOAD_FIRST_KEY;
			end 
		end		
		LOAD_FIRST_KEY: begin
			next_state = ENABLE_KEY_GEN;
		end
		ENABLE_KEY_GEN: begin
			next_state = LOAD_KEY;
		end
		LOAD_KEY: begin
			if (stage_done == 1) begin
				next_state = LAST_ENABLE;
			end else begin
				next_state = ENABLE_KEY_GEN;
			end	
		end
		LAST_ENABLE: begin
			next_state = LOAD_LAST_KEY;
		end
		LOAD_LAST_KEY: begin
			next_state = IDLE;
		end
		IDLE: begin
			if (data_ready == 1 && fifo_full == 0) begin			
				next_state = LOAD_DATA;
			end
		end
		LOAD_DATA: begin
			next_state = ARK_1;
		end
		ARK_1: begin
			next_state = SB_2;	
		end
		SB_2: begin
			next_state = SR_2;	
		end
		SR_2: begin
			next_state = MC_2;	
		end
		MC_2: begin
			next_state = ARK_2;	
		end
		ARK_2: begin
			if (stage_done == 1) begin
				next_state = SB_3;
			end else begin
				next_state = SB_2;
			end	
		end
		SB_3: begin
			next_state = SR_3;
		end
		SR_3: begin
			next_state = ARK_3;	
		end
		ARK_3: begin
			next_state = IDLE;
		end
	endcase

	next_data_load			= 0;
	next_data_taken			= 0;
	next_data_out_load		= 0;
	next_data_reg_input		= 0;
	next_process_output		= 2'd0;
	next_ark_enable			= 0;
	next_sb_enable			= 0;
	next_mc_enable			= 0;
	next_sr_enable			= 0;
	next_count_enable		= 0;
	next_count_clear		= 0;
	next_key_gen_enable		= 0;
	next_iter_in			= '0;
	next_iter_out			= '0;
	next_key_reg_load		= 0;

	case(next_state)
		KEY_WAIT: begin
			next_count_clear = 1;
		end		
		LOAD_FIRST_KEY: begin
			next_key_gen_enable = 0;
			next_key_reg_load = 1;
		end
		ENABLE_KEY_GEN: begin
			next_iter_in = count_out + 1;
			next_iter_out = count_out;
			next_count_enable = 1;
			next_key_gen_enable = 1;
		end
		LOAD_KEY: begin
			next_iter_in = count_out + 1;
			next_iter_out = count_out;
			next_key_gen_enable = 1;
			next_key_reg_load = 1;
		end
		LAST_ENABLE: begin
			next_iter_in = 10;
			next_iter_out = 9;
			next_key_gen_enable = 1;
		end
		LOAD_LAST_KEY: begin
			next_iter_in = 10;
			next_iter_out = 9;
			next_key_gen_enable = 1;
			next_key_reg_load = 1;
		end
		IDLE: begin
			next_count_clear = 1;
		end
		LOAD_DATA: begin
			next_data_load = 1;
			next_data_taken = 1;
		end
		ARK_1: begin
			next_process_output = 2'd0;
			next_data_reg_input = 1;	
			next_data_load = 1;
			next_ark_enable = 1;
			next_iter_out = 0;
		end
		SB_2: begin
			next_process_output = 2'd1;	
			next_data_reg_input = 1;
			next_data_load = 1;
			next_sb_enable = 1;
			next_iter_out = count_out + 1;
		end
		SR_2: begin
			next_process_output = 2'd3;	
			next_data_reg_input = 1;
			next_data_load = 1;
			next_sr_enable = 1;
			next_iter_out = count_out + 1;
		end
		MC_2: begin
			next_process_output = 2'd2;
			next_data_reg_input = 1;
			next_data_load = 1;
			next_mc_enable = 1;
			next_count_enable = 1;
			next_iter_out = count_out + 1;
		end
		ARK_2: begin
			next_process_output = 2'd0;
			next_data_reg_input = 1;
			next_data_load = 1;
			next_ark_enable = 1;
			next_iter_out = count_out + 1;
		end
		SB_3: begin
			next_process_output = 2'd1;	
			next_data_reg_input = 1;
			next_data_load = 1;
			next_sb_enable = 1;
			next_iter_out = 10;
		end
		SR_3: begin
			next_process_output = 2'd3;	
			next_data_reg_input = 1;
			next_data_load = 1;
			next_sr_enable = 1;
			next_iter_out = 10;
		end
		ARK_3: begin
			next_process_output = 2'd0;	
			next_data_reg_input = 1;
			next_ark_enable = 1;
			next_data_out_load = 1;
			next_iter_out = 10;
		end
	endcase

end
endmodule
	
		