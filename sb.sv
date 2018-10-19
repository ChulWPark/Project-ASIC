// $Id: $
// File name:   sb.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: sb.sv

module sb
  (
   input wire sb_enable,
   input wire [127:0] data,
   input wire [127:0] key,
   output reg [127:0] sb_out
   );

   integer 	      i;
   integer 	      mob1;
   integer 	      mob2;
   reg [7:0] 	      lookup_table [0:15] [0:15];
   
   always_comb
     begin
	// Prevent Latch
	sb_out = '0;
	if(sb_enable == 1'b1)
	  begin
	     // 16 x 16 look up table for byte to byte substitution
	     lookup_table[0] = {8'h63, 8'h7C, 8'h77, 8'h7B, 8'hF2, 8'h6B, 8'h6F, 8'hC5, 8'h30, 8'h01, 8'h67, 8'h2B, 8'hFE, 8'hD7, 8'hAB, 8'h76};
	     lookup_table[1] = {8'hCA, 8'h82, 8'hC9, 8'h7D, 8'hFA, 8'h59, 8'h47, 8'hF0, 8'hAD, 8'hD4, 8'hA2, 8'hAF, 8'h9C, 8'hA4, 8'h72, 8'hC0};
	     lookup_table[2] = {8'hB7, 8'hFD, 8'h93, 8'h26, 8'h36, 8'h3F, 8'hF7, 8'hCC, 8'h34, 8'hA5, 8'hE5, 8'hF1, 8'h71, 8'hD8, 8'h31, 8'h15};
	     lookup_table[3] = {8'h04, 8'hC7, 8'h23, 8'hC3, 8'h18, 8'h96, 8'h05, 8'h9A, 8'h07, 8'h12, 8'h80, 8'hE2, 8'hEB, 8'h27, 8'hB2, 8'h75};
	     lookup_table[4] = {8'h09, 8'h83, 8'h2C, 8'h1A, 8'h1B, 8'h6E, 8'h5A, 8'hA0, 8'h52, 8'h3B, 8'hD6, 8'hB3, 8'h29, 8'hE3, 8'h2F, 8'h84};
	     lookup_table[5] = {8'h53, 8'hD1, 8'h00, 8'hED, 8'h20, 8'hFC, 8'hB1, 8'h5B, 8'h6A, 8'hCB, 8'hBE, 8'h39, 8'h4A, 8'h4C, 8'h58, 8'hCF};
	     lookup_table[6] = {8'hD0, 8'hEF, 8'hAA, 8'hFB, 8'h43, 8'h4D, 8'h33, 8'h85, 8'h45, 8'hF9, 8'h02, 8'h7F, 8'h50, 8'h3C, 8'h9F, 8'hA8};
	     lookup_table[7] = {8'h51, 8'hA3, 8'h40, 8'h8F, 8'h92, 8'h9D, 8'h38, 8'hF5, 8'hBC, 8'hB6, 8'hDA, 8'h21, 8'h10, 8'hFF, 8'hF3, 8'hD2};
	     lookup_table[8] = {8'hCD, 8'h0C, 8'h13, 8'hEC, 8'h5F, 8'h97, 8'h44, 8'h17, 8'hC4, 8'hA7, 8'h7E, 8'h3D, 8'h64, 8'h5D, 8'h19, 8'h73};
	     lookup_table[9] = {8'h60, 8'h81, 8'h4F, 8'hDC, 8'h22, 8'h2A, 8'h90, 8'h88, 8'h46, 8'hEE, 8'hB8, 8'h14, 8'hDE, 8'h5E, 8'h0B, 8'hDB};
	     lookup_table[10] = {8'hE0, 8'h32, 8'h3A, 8'h0A, 8'h49, 8'h06, 8'h24, 8'h5C, 8'hC2, 8'hD3, 8'hAC, 8'h62, 8'h91, 8'h95, 8'hE4, 8'h79};
	     lookup_table[11] = {8'hE7, 8'hC8, 8'h37, 8'h6D, 8'h8D, 8'hD5, 8'h4E, 8'hA9, 8'h6C, 8'h56, 8'hF4, 8'hEA, 8'h65, 8'h7A, 8'hAE, 8'h08};
	     lookup_table[12] = {8'hBA, 8'h78, 8'h25, 8'h2E, 8'h1C, 8'hA6, 8'hB4, 8'hC6, 8'hE8, 8'hDD, 8'h74, 8'h1F, 8'h4B, 8'hBD, 8'h8B, 8'h8A};
	     lookup_table[13] = {8'h70, 8'h3E, 8'hB5, 8'h66, 8'h48, 8'h03, 8'hF6, 8'h0E, 8'h61, 8'h35, 8'h57, 8'hB9, 8'h86, 8'hC1, 8'h1D, 8'h9E};
	     lookup_table[14] = {8'hE1, 8'hF8, 8'h98, 8'h11, 8'h69, 8'hD9, 8'h8E, 8'h94, 8'h9B, 8'h1E, 8'h87, 8'hE9, 8'hCE, 8'h55, 8'h28, 8'hDF};
	     lookup_table[15] = {8'h8C, 8'hA1, 8'h89, 8'h0D, 8'hBF, 8'hE6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2D, 8'h0F, 8'hB0, 8'h54, 8'hBB, 8'h16};
	     
	     // Byte 1
	     mob1 = data[127:124];
	     mob2 = data[123:120];
	     sb_out[127:120] = lookup_table[mob1][mob2];
	     // Byte 2
	     mob1 = data[119:116];
	     mob2 = data[115:112];
	     sb_out[119:112] = lookup_table[mob1][mob2];
	     // Byte 3
	     mob1 = data[111:108];
	     mob2 = data[107:104];
	     sb_out[111:104] = lookup_table[mob1][mob2];
	     // Byte 4
	     mob1 = data[103:100];
	     mob2 = data[99:96];
	     sb_out[103:96] = lookup_table[mob1][mob2];
	     // Byte 5
	     mob1 = data[95:92];
	     mob2 = data[91:88];
	     sb_out[95:88] = lookup_table[mob1][mob2];
	     // Byte 6
	     mob1 = data[87:84];
	     mob2 = data[83:80];
	     sb_out[87:80] = lookup_table[mob1][mob2];
	     // Byte 7
	     mob1 = data[79:76];
	     mob2 = data[75:72];
	     sb_out[79:72] = lookup_table[mob1][mob2];
	     // Byte 8
	     mob1 = data[71:68];
	     mob2 = data[67:64];
	     sb_out[71:64] = lookup_table[mob1][mob2];
	     // Byte 9
	     mob1 = data[63:60];
	     mob2 = data[59:56];
	     sb_out[63:56] = lookup_table[mob1][mob2];
	     // Byte 10
	     mob1 = data[55:52];
	     mob2 = data[51:48];
	     sb_out[55:48] = lookup_table[mob1][mob2];
	     // Byte 11
	     mob1 = data[47:44];
	     mob2 = data[43:40];
	     sb_out[47:40] = lookup_table[mob1][mob2];
	     // Byte 12
	     mob1 = data[39:36];
	     mob2 = data[35:32];
	     sb_out[39:32] = lookup_table[mob1][mob2];
	     // Byte 13
	     mob1 = data[31:28];
	     mob2 = data[27:24];
	     sb_out[31:24] = lookup_table[mob1][mob2];
	     // Byte 14
	     mob1 = data[23:20];
	     mob2 = data[19:16];
	     sb_out[23:16] = lookup_table[mob1][mob2];
	     // Byte 15
	     mob1 = data[15:12];
	     mob2 = data[11:8];
	     sb_out[15:8] = lookup_table[mob1][mob2];
	     // Byte 16
	     mob1 = data[7:4];
	     mob2 = data[3:0];
	     sb_out[7:0] = lookup_table[mob1][mob2];
	  end // if (sb_enable == 1'b1)	
     end // always_comb
endmodule // sb

   
