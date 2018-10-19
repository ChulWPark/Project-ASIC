// $Id: $
// File name:   sr.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: sr.sv

module sr
  (
   input wire sr_enable,
   input wire [127:0] data,
   input wire [127:0] key,
   output reg [127:0] sr_out
   );
   
   always_comb
     begin
	sr_out = '0;
	if(sr_enable == 1'b1)
	  begin
	     // FIRST ROW
	     // NO SHIFTING OCCURS FOR THE FIRST ROW
	     sr_out[127:120] = data[127:120];
	     sr_out[119:112] = data[87:80];
	     sr_out[111:104] = data[47:40];
	     sr_out[103:96]  = data[7:0];		
	     
	     // SECOND ROW
	     // SHIFT ONCE TO THE LEFT
	     sr_out[95:88] = data[95:88];
	     sr_out[87:80] = data[55:48];
	     sr_out[79:72] = data[15:8];
	     sr_out[71:64] = data[103:96];
	     
	     // THIRD ROW
	     // SHIFT TWICE TO THE LEFT
	     sr_out[63:56] = data[63:56];
	     sr_out[55:48] = data[23:16];
	     sr_out[47:40] = data[111:104];
	     sr_out[39:32] = data[71:64];
	     
	     // FOURTH ROW
	     // SHIFT THREE TIMES TO THE LEFT
	     sr_out[31:24] = data[31:24];
	     sr_out[23:16] = data[119:112];
	     sr_out[15:8]  = data[79:72];
	     sr_out[7:0]   = data[39:32];
	  
	  end // if (sr_enable == 1'b1)
     
     end // always_comb

endmodule // sr
