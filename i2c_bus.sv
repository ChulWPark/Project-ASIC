// $Id: $
// File name:   i2c_bus.sv
// Created:     10/11/2017
// Author:      Andrew Hegewald
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Wrapper for I2c_bus

module i2c_bus
(
	input  wire [1:0] scl_write,
	input  wire [1:0] sda_write,
	output wire [1:0] scl_read,
	output wire [1:0] sda_read
);

