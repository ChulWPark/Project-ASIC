// $Id: $
// File name:   controller.sv
// Created:     9/26/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Controller for Slave Block

module controller
(
	input wire clk,
	input wire n_rst,
	input wire stop_found,
	input wire start_found,
	input wire byte_received,
	input wire ack_prep,
	input wire check_ack,
	input wire ack_done,
	input wire rw_mode,
	input wire address_match,
	input wire key_received,
	input wire sda_in,
	input wire fifo_empty,
	output wire rx_enable,
	output wire tx_enable,
	output wire read_enable,
	output wire [1:0] sda_mode,
	output wire load_data,
	output wire reg_enable,
	output wire start_byte_received,
	output wire key_loaded
);

reg	  [3:0] state, next_state;
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

reg  reg_rx_enable;
reg next_rx_enable;

reg  reg_tx_enable;
reg next_tx_enable;

reg  reg_read_enable;
reg next_read_enable;

reg [1:0]  reg_sda_mode;
reg [1:0] next_sda_mode;

reg  reg_load_data;
reg next_load_data;

reg  reg_reg_enable;
reg next_reg_enable;

reg  reg_start_byte_received;
reg next_start_byte_received;

reg  reg_key_loaded;
reg next_key_loaded;

assign rx_enable = reg_rx_enable;
assign tx_enable = reg_tx_enable;
assign read_enable = reg_read_enable;
assign sda_mode = reg_sda_mode;
assign load_data = reg_load_data;
assign key_loaded = reg_key_loaded;
assign start_byte_received = reg_start_byte_received;
assign reg_enable = reg_reg_enable;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		state 		<= IDLE;
		reg_rx_enable 	<= 0;
		reg_tx_enable 	<= 0;
		reg_read_enable <= 0;
		reg_sda_mode 	<= 0;
		reg_load_data	<= 0;
		reg_reg_enable	<= 0;
		reg_start_byte_received	<= 0;
		reg_key_loaded	<= 0;
	end else begin
		state 		<= next_state;
		reg_rx_enable 	<= next_rx_enable;
		reg_tx_enable 	<= next_tx_enable;
		reg_read_enable <= next_read_enable;
		reg_sda_mode 	<= next_sda_mode;
		reg_load_data	<= next_load_data;
		reg_reg_enable	<= next_reg_enable;
		reg_start_byte_received	<= next_start_byte_received;
		reg_key_loaded	<= next_key_loaded;
	end
end

always_comb begin
	next_state = state;

	if (start_found == 1) begin
		next_state = WAIT_FOR_BYTE;
	end else if (stop_found == 1) begin
		next_state = IDLE;
	end else begin
	case(state)
		IDLE: begin
			if(start_found == 1) begin
				next_state = WAIT_FOR_BYTE;
			end
		end
		WAIT_FOR_BYTE: begin
			if(byte_received == 1) begin
				next_state = PREP_ACK;
			end
		end
		PREP_ACK: begin
			if(ack_prep == 1) begin
				if(rw_mode == 1 && address_match == 1 && fifo_empty == 0 && reg_key_loaded == 1) begin
					next_state = ACK_TX;
				end else if(rw_mode == 0 && address_match == 1 && reg_key_loaded == 0) begin
					next_state = ACK_RX;
				end else begin
					next_state = IDLE;
				end
			end
		end
		ACK_TX: begin
			if(ack_done == 1) begin
				next_state = LOAD_BYTE;
			end
		end
		LOAD_BYTE: begin
			next_state = SEND_BYTE;
		end
		SEND_BYTE: begin
			if(ack_prep == 1) begin
				next_state = MAKE_BUS_IDLE;
			end
		end
		MAKE_BUS_IDLE: begin
			if(check_ack == 1) begin
				next_state = MASTER_ACK;
			end
		end
		MASTER_ACK: begin
			if(stop_found == 1) begin
				next_state = IDLE;
			end else if (start_found == 1) begin
				next_state = WAIT_FOR_BYTE;
			end else if (sda_in == 0) begin
				next_state = RX_WAIT;
			end else if (ack_done == 1) begin
				next_state = IDLE;
			end
		end	
		RX_WAIT: begin
			if(stop_found == 1) begin
				next_state = IDLE;
			end else if (start_found == 1) begin
				next_state = WAIT_FOR_BYTE;
			end else if(ack_done == 1) begin
				if (key_received == 1) begin
					next_state = LOAD_BYTE;
				end else begin
					next_state = SEND_BYTE;
				end
			end
		end
		ACK_RX: begin
			if(ack_done == 1) begin
				next_state = RX_BYTE;
			end
		end
		RX_BYTE: begin
			if(byte_received == 1) begin
				next_state = RX_ACK_PREP;
			end
		end
		RX_ACK_PREP: begin
			if (key_received == 1) begin
				next_state = RX_REG_LOAD;
			end else if (ack_prep == 1) begin
				next_state = ACK_RX;
			end
		end
		RX_REG_LOAD: begin
			next_state = RX_KEY_SIGNAL;
		end
		RX_KEY_SIGNAL: begin
			next_state = IDLE;
		end
	endcase
	end

	next_rx_enable = 0;
	next_tx_enable = 0;
	next_read_enable = 0;
	next_sda_mode = 0;
	next_load_data = 0;
	next_reg_enable = 0;
	next_start_byte_received = 0;
	next_key_loaded = reg_key_loaded;

	case(next_state)
		IDLE: begin

		end
		WAIT_FOR_BYTE: begin
			next_rx_enable = 1;
		end
		PREP_ACK: begin
			next_start_byte_received = 1;
		end
		ACK_TX: begin
			next_sda_mode = 2'd1;
		end
		LOAD_BYTE: begin
			next_read_enable = 1;
			next_load_data = 1;
		end
		SEND_BYTE: begin
			next_tx_enable = 1;
			next_sda_mode = 2'd3;
		end
		MAKE_BUS_IDLE: begin
			
		end
		MASTER_ACK: begin
			
		end	
		RX_WAIT: begin
		
		end
		ACK_RX: begin
			next_sda_mode = 2'd1;
		end
		RX_BYTE: begin
			next_rx_enable = 1;
		end
		RX_ACK_PREP: begin

		end
		RX_REG_LOAD: begin
			next_reg_enable = 1;
		end
		RX_KEY_SIGNAL: begin
			next_key_loaded = 1;
		end
	endcase
end

endmodule