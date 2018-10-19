// $Id: $
// File name:   mc.sv
// Created:     11/1/2017
// Author:      Chul Woo Park
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: mc.sv

module mc
  (
   input mc_enable,
   input wire [127:0] data,
   input wire [127:0] key,
   output reg [127:0] mc_out
   );

   reg [7:0] 	      double;
   reg [7:0] 	      triple;
   
   always_comb
     begin
	mc_out = '0;
	if(mc_enable == 1'b1)
	  begin
	     // FIRST ROW
	     double = {data[126:120],1'b0};
	     if(data[127] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[118:112],1'b0};
	     if(data[119] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[119:112];
	     mc_out[127:120] = double ^ triple ^ data[111:104] ^ data[103:96];
	     
	     double = {data[94:88],1'b0};
	     if(data[95] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[86:80],1'b0};
	     if(data[87] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[87:80];
	     mc_out[95:88] = double ^ triple ^ data[79:72] ^ data[71:64];
	     
	     double = {data[62:56],1'b0};
	     if(data[63] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[54:48],1'b0};
	     if(data[55] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[55:48];
	     mc_out[63:56] = double ^ triple ^ data[47:40] ^ data[39:32];
	     
	     double = {data[30:24],1'b0};
	     if(data[31] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[22:16],1'b0};
	     if(data[23] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[23:16];
	     mc_out[31:24] = double ^ triple ^ data[15:8] ^ data[7:0];
	     
	     // SECOND ROW
	     double = {data[118:112],1'b0};
	     if(data[119] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[110:104],1'b0};
	     if(data[111] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[111:104];
	     mc_out[119:112] = data[127:120] ^ double ^ triple ^ data[103:96];
	     
	     double = {data[86:80],1'b0};
	     if(data[87] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[78:72],1'b0};
	     if(data[79] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[79:72];
	     mc_out[87:80] = data[95:88] ^ double ^ triple ^ data[71:64];
	     
	     double = {data[54:48],1'b0};
	     if(data[55] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[46:40],1'b0};
	     if(data[47] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[47:40];
	     mc_out[55:48] = data[63:56] ^ double ^ triple ^ data[39:32];
	     
	     double = {data[22:16],1'b0};
	     if(data[23] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[14:8],1'b0};
	     if(data[15] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[15:8];
	     mc_out[23:16] = data[32:24] ^ double ^ triple ^ data[7:0];
	     
	     // THIRD ROW
	     double = {data[110:104],1'b0};
	     if(data[111] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[102:96],1'b0};
	     if(data[103] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[103:96];
	     mc_out[111:104] = data[127:120] ^ data[119:112] ^ double ^ triple;
	     
	     double = {data[78:72],1'b0};
	     if(data[79] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[70:64],1'b0};
	     if(data[71] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[71:64];
	     mc_out[79:72] = data[95:88] ^ data[87:80] ^ double ^ triple;
	     
	     double = {data[46:40],1'b0};
	     if(data[47] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[38:32],1'b0};
	     if(data[39] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[39:32];
	     mc_out[47:40] = data[63:56] ^ data[55:48] ^ double ^ triple;
	     
	     double = {data[14:8],1'b0};
	     if(data[15] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[6:0],1'b0};
	     if(data[7] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[7:0];
	     mc_out[15:8] = data[32:24] ^ data[23:16] ^ double ^ triple;
	     
	     // FOURTH ROW
	     double = {data[102:96],1'b0};
	     if(data[103] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[126:120],1'b0};
	     if(data[127] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[127:120];
	     mc_out[103:96] = triple ^ data[119:112] ^ data[111:104] ^ double;
	     
	     double = {data[70:64],1'b0};
	     if(data[71] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[94:88],1'b0};
	     if(data[95] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[95:88];
	     mc_out[71:64] = triple ^ data[87:80] ^ data[79:72] ^ double;
	     
	     double = {data[38:32],1'b0};
	     if(data[39] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[62:56],1'b0};
	     if(data[63] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[63:56];
	     mc_out[39:32] = triple ^ data[55:48] ^ data[47:40] ^ double;
	     
	     double = {data[6:0],1'b0};
	     if(data[7] == 1'b1)
	       double = double ^ 8'h1B;
	     triple = {data[30:24],1'b0};
	     if(data[31] == 1'b1)
	       triple = triple ^ 8'h1B;
	     triple = triple ^ data[31:24];
	     mc_out[7:0] = triple ^ data[23:16] ^ data[15:8] ^ double;
	  end // if (mc_enable == 1'b1...
	
     end // always_comb
   
endmodule // mc
