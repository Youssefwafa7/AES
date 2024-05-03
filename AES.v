module aes(input clk,input [1:0]SW,input reset,output[6:0]HEX0,output[6:0]HEX1,output[6:0]HEX2,output Equal);
	wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
	wire [127:0] key128 = 128'h000102030405060708090a0b0c0d0e0f;
	wire [191:0] key192 = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;
	wire [255:0] key256 = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
	wire [127:0] out;
    wire [127:0] out128;
    wire [127:0] out192;
    wire [127:0] out256;
    wire [1407:0] words128;
    wire [1663:0] words192;
    wire [1919:0] words256;
    wire [127:0] decrypted128;
    wire [127:0] decrypted192;
    wire [127:0] decrypted256;
    wire [127:0] encrypted128;
    wire [127:0] encrypted192;
    wire [127:0] encrypted256;
	reg enable = 0;
    integer i = -1;
    integer Nr=10;
     always @(*) begin
       	if (SW[0]) begin
            Nr=12;
         end
        else if (SW[1]) begin
            Nr=14;
        end
    end
    KeyExpansion #(4,10) k10985 (key128,words128);
    KeyExpansion #(6,12) k223412we (key192,words192);
    KeyExpansion #(8,14) k3234sa (key256,words256);
    Cipher #(4,10) c1234sad (in,words128,clk,reset,encrypted128);
    Cipher #(6,12) c2234ad (in,words192,clk,reset,encrypted192);
    Cipher #(8,14) c32134sdf (in,words256,clk,reset,encrypted256);
    DeCipher #(4,10) dc1234asf (encrypted128,words128,clk,reset,enable,decrypted128);
    DeCipher #(6,12) dc2234sdf (encrypted192,words192,clk,reset,enable,decrypted192);
  	DeCipher #(8,14) dc324sdf (encrypted256,words256,clk,reset,enable,decrypted256);
    assign out128=(i<Nr+1)?encrypted128:decrypted128;
    assign out192=(i<Nr+1)?encrypted192:decrypted192;
   	assign out256=(i<Nr+1)?encrypted256:decrypted256;
    assign out=(Nr==10)?out128:(Nr==12)?out192:(Nr==14)?out256:127'bx;
    always@(negedge clk, posedge reset) begin
		if(reset) begin 
			i = -1;
		end
        else if(i<2*(Nr+1)) begin
                 if(i==Nr-1)begin
					enable = 1;
				 end
            i = i + 1;
            end
        end
    wire [7:0] bin = (i == -1) ? in[7:0] : out[7:0];
    wire [11:0] bout;
    binarytoBCD B2B(bin , bout);
    wire [20:0]hexout;
    HexConverter HC0(bout[3:0] , hexout[6:0]);
    HexConverter HC1(bout[7:4] , hexout[13:7]);
    HexConverter HC2(bout[11:8], hexout[20:14]);
    assign HEX0 =hexout[6:0];
    assign HEX1 =hexout[13:7];
    assign HEX2 =hexout[20:14];
	assign Equal = (in==out)? 1:0;
endmodule

module Cipher#(parameter Nk = 4 ,parameter Nr = 10)(input [127 : 0] in, input [(Nr+1)*128-1 : 0] w , input clk ,input reset, output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
	reg [127:0] currentState;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    integer i=-1;
    AddRoundKey addrk1 (in, w[(Nr+1)*128-1 -: 128], firstround);
	encryptRound er (currentState ,w[(Nr+1)*128-1-((i+1)*128)-:128],midrounds);
	SubBytes sb(currentState,sub);
	ShiftRows sr(sub,shift);
  	AddRoundKey addrk2(shift,w[127:0],finalround);


	always @ (negedge clk,posedge reset) begin 
		if(reset)begin 
			i = -1;
		end
		else if(i<Nr)begin 
				if(i==-1&& firstround !== 'bx)begin
					currentState<=firstround;
					finalout = firstround;
					i=i+1;
				end
				else if(i<=Nr-2&& midrounds !== 'bx)begin
						currentState<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==Nr-1&& midrounds !== 'bx)begin
						finalout <= finalround;
					end

		end	
	end
endmodule

module DeCipher#(parameter Nk = 4 ,parameter Nr = 10)(input [127 : 0] in, input [(Nr+1)*128-1 : 0] w , input clk,input reset,input enable ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
	reg [127:0] currentstate;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    integer i=-1;
    AddRoundKey addrk3 (in, w[127 : 0], firstround);
	  decryptRound dr (currentstate ,w[(((i+2)*128)-1)-:128],midrounds);
	  InvShiftRows isr(currentstate,shift);
	  invSubBytes isb(shift,sub);
	  AddRoundKey addrk4 (sub,w[(Nr+1)*128-1-:128],finalround);


	always @ (negedge clk,posedge reset) begin 
		if(reset)begin 
			i = -1;
		end
		else if(i<Nr && enable)begin 
				if(i==-1&& firstround !== 'bx)begin
					currentstate<=firstround;
					finalout <= firstround;
					i=i+1;
				end
				else if(i<=Nr-2&& midrounds !== 'bx)begin
						currentstate<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==Nr-1&& midrounds !== 'bx)begin
						finalout <= finalround;
					end

		end	
	end
endmodule

module encryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
wire [127:0] afterSubBytes;
wire [127:0] keyout;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;

SubBytes s1(in,afterSubBytes);
ShiftRows r1(afterSubBytes,afterShiftRows);
mixColumns m32323(afterShiftRows,afterMixColumns);
AddRoundKey k77(afterMixColumns,key,keyout);
assign out = keyout;
		
endmodule

module AddRoundKey(input [127:0] in,input[127:0] in2, output[127:0] out);
assign out=in2^in;
endmodule


module KeyExpansion #(parameter Nk = 4 ,parameter Nr = 10)(input [Nk*32-1: 0] key , output [(Nr+1)*128-1:0] words);
  reg [31:0] word_array [0:4*(Nr+1)];
  reg [31:0]temp ;
  reg [31:0] shiftedx;
  reg [31:0] rconx;
  reg [31:0] subx;

  integer i,j;
  always@ (*) begin
	 
  	for(j = 0 ; j < Nk ; j = j + 1) begin:Keyj
     	word_array[j] = key[(Nk*32-1) - 32*j -:32];
 	 end

    for(i = Nk; i < 4*(Nr + 1); i = i + 1) begin:Keyi
        temp = word_array[i-1];
        if(i % Nk == 0) begin 
         shiftedx = shift(temp);
         subx = subwordx(shiftedx);
         rconx = rcon(i/Nk);
         temp = subx ^ rconx;
        end
        else if(Nk > 6 && i % Nk == 4) begin
         temp = subwordx(temp);
        end
        word_array[i] = word_array[i-Nk]^temp;
    end
  end

genvar z;
generate
 for (z = 0 ; z < 4 * (Nr+1) ; z = z + 1) begin:Keyz
    assign words[(Nr+1)*128-1 -32*z -:32] = word_array[z];
  end
endgenerate

function [31:0] shift;
input [31:0] x;
begin
		shift={x[23:0], x[31:24]};
end
endfunction

 function [31:0] subwordx;
 input [31:0] a;
 begin
    subwordx[31:24] = sub(a[31:24]);
    subwordx[23:16] = sub(a[23:16]);
    subwordx[15:8]  = sub(a[15:8]);
    subwordx[7:0]   = sub(a[7:0]);
 end
endfunction

function[0:31] rcon;
input [0:31] r; 
begin
 case(r)
    4'h1: rcon=32'h01000000;
    4'h2: rcon=32'h02000000;
    4'h3: rcon=32'h04000000;
    4'h4: rcon=32'h08000000;
    4'h5: rcon=32'h10000000;
    4'h6: rcon=32'h20000000;
    4'h7: rcon=32'h40000000;
    4'h8: rcon=32'h80000000;
    4'h9: rcon=32'h1b000000;
    4'ha: rcon=32'h36000000;
    default: rcon=32'h00000000;
  endcase
  end
endfunction
function [7:0] sub(input [7:0] befsub);  
begin
    case (befsub)
       8'h00: sub=8'h63;
	   8'h01: sub=8'h7c;
	   8'h02: sub=8'h77;
	   8'h03: sub=8'h7b;
	   8'h04: sub=8'hf2;
	   8'h05: sub=8'h6b;
	   8'h06: sub=8'h6f;
	   8'h07: sub=8'hc5;
	   8'h08: sub=8'h30;
	   8'h09: sub=8'h01;
	   8'h0a: sub=8'h67;
	   8'h0b: sub=8'h2b;
	   8'h0c: sub=8'hfe;
	   8'h0d: sub=8'hd7;
	   8'h0e: sub=8'hab;
	   8'h0f: sub=8'h76;
	   8'h10: sub=8'hca;
	   8'h11: sub=8'h82;
	   8'h12: sub=8'hc9;
	   8'h13: sub=8'h7d;
	   8'h14: sub=8'hfa;
	   8'h15: sub=8'h59;
	   8'h16: sub=8'h47;
	   8'h17: sub=8'hf0;
	   8'h18: sub=8'had;
	   8'h19: sub=8'hd4;
	   8'h1a: sub=8'ha2;
	   8'h1b: sub=8'haf;
	   8'h1c: sub=8'h9c;
	   8'h1d: sub=8'ha4;
	   8'h1e: sub=8'h72;
	   8'h1f: sub=8'hc0;
	   8'h20: sub=8'hb7;
	   8'h21: sub=8'hfd;
	   8'h22: sub=8'h93;
	   8'h23: sub=8'h26;
	   8'h24: sub=8'h36;
	   8'h25: sub=8'h3f;
	   8'h26: sub=8'hf7;
	   8'h27: sub=8'hcc;
	   8'h28: sub=8'h34;
	   8'h29: sub=8'ha5;
	   8'h2a: sub=8'he5;
	   8'h2b: sub=8'hf1;
	   8'h2c: sub=8'h71;
	   8'h2d: sub=8'hd8;
	   8'h2e: sub=8'h31;
	   8'h2f: sub=8'h15;
	   8'h30: sub=8'h04;
	   8'h31: sub=8'hc7;
	   8'h32: sub=8'h23;
	   8'h33: sub=8'hc3;
	   8'h34: sub=8'h18;
	   8'h35: sub=8'h96;
	   8'h36: sub=8'h05;
	   8'h37: sub=8'h9a;
	   8'h38: sub=8'h07;
	   8'h39: sub=8'h12;
	   8'h3a: sub=8'h80;
	   8'h3b: sub=8'he2;
	   8'h3c: sub=8'heb;
	   8'h3d: sub=8'h27;
	   8'h3e: sub=8'hb2;
	   8'h3f: sub=8'h75;
	   8'h40: sub=8'h09;
	   8'h41: sub=8'h83;
	   8'h42: sub=8'h2c;
	   8'h43: sub=8'h1a;
	   8'h44: sub=8'h1b;
	   8'h45: sub=8'h6e;
	   8'h46: sub=8'h5a;
	   8'h47: sub=8'ha0;
	   8'h48: sub=8'h52;
	   8'h49: sub=8'h3b;
	   8'h4a: sub=8'hd6;
	   8'h4b: sub=8'hb3;
	   8'h4c: sub=8'h29;
	   8'h4d: sub=8'he3;
	   8'h4e: sub=8'h2f;
	   8'h4f: sub=8'h84;
	   8'h50: sub=8'h53;
	   8'h51: sub=8'hd1;
	   8'h52: sub=8'h00;
	   8'h53: sub=8'hed;
	   8'h54: sub=8'h20;
	   8'h55: sub=8'hfc;
	   8'h56: sub=8'hb1;
	   8'h57: sub=8'h5b;
	   8'h58: sub=8'h6a;
	   8'h59: sub=8'hcb;
	   8'h5a: sub=8'hbe;
	   8'h5b: sub=8'h39;
	   8'h5c: sub=8'h4a;
	   8'h5d: sub=8'h4c;
	   8'h5e: sub=8'h58;
	   8'h5f: sub=8'hcf;
	   8'h60: sub=8'hd0;
	   8'h61: sub=8'hef;
	   8'h62: sub=8'haa;
	   8'h63: sub=8'hfb;
	   8'h64: sub=8'h43;
	   8'h65: sub=8'h4d;
	   8'h66: sub=8'h33;
	   8'h67: sub=8'h85;
	   8'h68: sub=8'h45;
	   8'h69: sub=8'hf9;
	   8'h6a: sub=8'h02;
	   8'h6b: sub=8'h7f;
	   8'h6c: sub=8'h50;
	   8'h6d: sub=8'h3c;
	   8'h6e: sub=8'h9f;
	   8'h6f: sub=8'ha8;
	   8'h70: sub=8'h51;
	   8'h71: sub=8'ha3;
	   8'h72: sub=8'h40;
	   8'h73: sub=8'h8f;
	   8'h74: sub=8'h92;
	   8'h75: sub=8'h9d;
	   8'h76: sub=8'h38;
	   8'h77: sub=8'hf5;
	   8'h78: sub=8'hbc;
	   8'h79: sub=8'hb6;
	   8'h7a: sub=8'hda;
	   8'h7b: sub=8'h21;
	   8'h7c: sub=8'h10;
	   8'h7d: sub=8'hff;
	   8'h7e: sub=8'hf3;
	   8'h7f: sub=8'hd2;
	   8'h80: sub=8'hcd;
	   8'h81: sub=8'h0c;
	   8'h82: sub=8'h13;
	   8'h83: sub=8'hec;
	   8'h84: sub=8'h5f;
	   8'h85: sub=8'h97;
	   8'h86: sub=8'h44;
	   8'h87: sub=8'h17;
	   8'h88: sub=8'hc4;
	   8'h89: sub=8'ha7;
	   8'h8a: sub=8'h7e;
	   8'h8b: sub=8'h3d;
	   8'h8c: sub=8'h64;
	   8'h8d: sub=8'h5d;
	   8'h8e: sub=8'h19;
	   8'h8f: sub=8'h73;
	   8'h90: sub=8'h60;
	   8'h91: sub=8'h81;
	   8'h92: sub=8'h4f;
	   8'h93: sub=8'hdc;
	   8'h94: sub=8'h22;
	   8'h95: sub=8'h2a;
	   8'h96: sub=8'h90;
	   8'h97: sub=8'h88;
	   8'h98: sub=8'h46;
	   8'h99: sub=8'hee;
	   8'h9a: sub=8'hb8;
	   8'h9b: sub=8'h14;
	   8'h9c: sub=8'hde;
	   8'h9d: sub=8'h5e;
	   8'h9e: sub=8'h0b;
	   8'h9f: sub=8'hdb;
	   8'ha0: sub=8'he0;
	   8'ha1: sub=8'h32;
	   8'ha2: sub=8'h3a;
	   8'ha3: sub=8'h0a;
	   8'ha4: sub=8'h49;
	   8'ha5: sub=8'h06;
	   8'ha6: sub=8'h24;
	   8'ha7: sub=8'h5c;
	   8'ha8: sub=8'hc2;
	   8'ha9: sub=8'hd3;
	   8'haa: sub=8'hac;
	   8'hab: sub=8'h62;
	   8'hac: sub=8'h91;
	   8'had: sub=8'h95;
	   8'hae: sub=8'he4;
	   8'haf: sub=8'h79;
	   8'hb0: sub=8'he7;
	   8'hb1: sub=8'hc8;
	   8'hb2: sub=8'h37;
	   8'hb3: sub=8'h6d;
	   8'hb4: sub=8'h8d;
	   8'hb5: sub=8'hd5;
	   8'hb6: sub=8'h4e;
	   8'hb7: sub=8'ha9;
	   8'hb8: sub=8'h6c;
	   8'hb9: sub=8'h56;
	   8'hba: sub=8'hf4;
	   8'hbb: sub=8'hea;
	   8'hbc: sub=8'h65;
	   8'hbd: sub=8'h7a;
	   8'hbe: sub=8'hae;
	   8'hbf: sub=8'h08;
	   8'hc0: sub=8'hba;
	   8'hc1: sub=8'h78;
	   8'hc2: sub=8'h25;
	   8'hc3: sub=8'h2e;
	   8'hc4: sub=8'h1c;
	   8'hc5: sub=8'ha6;
	   8'hc6: sub=8'hb4;
	   8'hc7: sub=8'hc6;
	   8'hc8: sub=8'he8;
	   8'hc9: sub=8'hdd;
	   8'hca: sub=8'h74;
	   8'hcb: sub=8'h1f;
	   8'hcc: sub=8'h4b;
	   8'hcd: sub=8'hbd;
	   8'hce: sub=8'h8b;
	   8'hcf: sub=8'h8a;
	   8'hd0: sub=8'h70;
	   8'hd1: sub=8'h3e;
	   8'hd2: sub=8'hb5;
	   8'hd3: sub=8'h66;
	   8'hd4: sub=8'h48;
	   8'hd5: sub=8'h03;
	   8'hd6: sub=8'hf6;
	   8'hd7: sub=8'h0e;
	   8'hd8: sub=8'h61;
	   8'hd9: sub=8'h35;
	   8'hda: sub=8'h57;
	   8'hdb: sub=8'hb9;
	   8'hdc: sub=8'h86;
	   8'hdd: sub=8'hc1;
	   8'hde: sub=8'h1d;
	   8'hdf: sub=8'h9e;
	   8'he0: sub=8'he1;
	   8'he1: sub=8'hf8;
	   8'he2: sub=8'h98;
	   8'he3: sub=8'h11;
	   8'he4: sub=8'h69;
	   8'he5: sub=8'hd9;
	   8'he6: sub=8'h8e;
	   8'he7: sub=8'h94;
	   8'he8: sub=8'h9b;
	   8'he9: sub=8'h1e;
	   8'hea: sub=8'h87;
	   8'heb: sub=8'he9;
	   8'hec: sub=8'hce;
	   8'hed: sub=8'h55;
	   8'hee: sub=8'h28;
	   8'hef: sub=8'hdf;
	   8'hf0: sub=8'h8c;
	   8'hf1: sub=8'ha1;
	   8'hf2: sub=8'h89;
	   8'hf3: sub=8'h0d;
	   8'hf4: sub=8'hbf;
	   8'hf5: sub=8'he6;
	   8'hf6: sub=8'h42;
	   8'hf7: sub=8'h68;
	   8'hf8: sub=8'h41;
	   8'hf9: sub=8'h99;
	   8'hfa: sub=8'h2d;
	   8'hfb: sub=8'h0f;
	   8'hfc: sub=8'hb0;
	   8'hfd: sub=8'h54;
	   8'hfe: sub=8'hbb;
	   8'hff: sub=8'h16;
	endcase
end
endfunction
endmodule




module mixColumns(state_in,state_out);

input [0:127] state_in;
output[0:127] state_out;

function [7:0] mul02;
	input [7:0] x;
	begin 
			if(x[7] == 1) mul02 = ((x << 1) ^ 8'h1b);
			else mul02 = x << 1; 
	end 	
endfunction


function [7:0] mul03;
	input [7:0] x;
	begin 
			
			mul03 = mul02(x) ^ x;
	end 
endfunction


genvar i;

generate

for(i=0;i< 4;i=i+1) begin : m_col

assign state_out[i*32+:8]= mul02(state_in[i*32+:8]) ^ mul03(state_in[(i*32 + 8)+:8]) ^ state_in[(i*32 + 16)+:8] ^ state_in[(i*32 + 24)+:8];
assign state_out[(i*32 + 8)+:8]= state_in[i*32+:8] ^ mul02(state_in[(i*32 + 8)+:8]) ^ mul03(state_in[(i*32 + 16)+:8]) ^ state_in[(i*32 + 24)+:8];
assign state_out[(i*32 + 16)+:8]= state_in[i*32+:8] ^ state_in[(i*32 + 8)+:8] ^ mul02(state_in[(i*32 + 16)+:8]) ^ mul03(state_in[(i*32 + 24)+:8]);
assign state_out[(i*32 + 24)+:8]= mul03(state_in[i*32+:8]) ^ state_in[(i*32 + 8)+:8] ^ state_in[(i*32 + 16)+:8] ^ mul02(state_in[(i*32 + 24)+:8]);

end

endgenerate

endmodule


module ShiftRows(input  [0:127] state_in ,  output  [0:127] state_out );

//first row
assign state_out[0:7] = state_in[0:7];
assign state_out[32:39] = state_in[32:39];
assign state_out[64:71] = state_in[64:71];
assign state_out[96:103] = state_in[96:103];

//second row
assign state_out[8:15] = state_in[40:47];
assign state_out[40:47] = state_in[72:79];
assign state_out[72:79] = state_in[104:111];
assign state_out[104:111] = state_in[8:15];

//third row
assign state_out[16:23] = state_in[80:87];
assign state_out[48:55] = state_in[112:119];
assign state_out[80:87] = state_in[16:23];
assign state_out[112:119] = state_in[48:55];

//forth row
assign state_out[24:31] = state_in[120:127];
assign state_out[56:63] = state_in[24:31];
assign state_out[88:95] = state_in[56:63];
assign state_out[120:127] = state_in[88:95];

endmodule

module SubBytes(input [127:0] in , output [127:0] out);
genvar i;

generate
  for(i=0;i<16;i=i+1)begin : sub_bytes
    sbox s16969(in[(i+1)*8-1:i*8],out[(i+1)*8-1:i*8]);
    end
endgenerate
endmodule
	
module sbox(in,out);

input  [7:0] in;
output [7:0] out;
reg [7:0] c;
     
   always @(in) begin
    case (in) 
       8'h00: c=8'h63;
	   8'h01: c=8'h7c;
	   8'h02: c=8'h77;
	   8'h03: c=8'h7b;
	   8'h04: c=8'hf2;
	   8'h05: c=8'h6b;
	   8'h06: c=8'h6f;
	   8'h07: c=8'hc5;
	   8'h08: c=8'h30;
	   8'h09: c=8'h01;
	   8'h0a: c=8'h67;
	   8'h0b: c=8'h2b;
	   8'h0c: c=8'hfe;
	   8'h0d: c=8'hd7;
	   8'h0e: c=8'hab;
	   8'h0f: c=8'h76;
	   8'h10: c=8'hca;
	   8'h11: c=8'h82;
	   8'h12: c=8'hc9;
	   8'h13: c=8'h7d;
	   8'h14: c=8'hfa;
	   8'h15: c=8'h59;
	   8'h16: c=8'h47;
	   8'h17: c=8'hf0;
	   8'h18: c=8'had;
	   8'h19: c=8'hd4;
	   8'h1a: c=8'ha2;
	   8'h1b: c=8'haf;
	   8'h1c: c=8'h9c;
	   8'h1d: c=8'ha4;
	   8'h1e: c=8'h72;
	   8'h1f: c=8'hc0;
	   8'h20: c=8'hb7;
	   8'h21: c=8'hfd;
	   8'h22: c=8'h93;
	   8'h23: c=8'h26;
	   8'h24: c=8'h36;
	   8'h25: c=8'h3f;
	   8'h26: c=8'hf7;
	   8'h27: c=8'hcc;
	   8'h28: c=8'h34;
	   8'h29: c=8'ha5;
	   8'h2a: c=8'he5;
	   8'h2b: c=8'hf1;
	   8'h2c: c=8'h71;
	   8'h2d: c=8'hd8;
	   8'h2e: c=8'h31;
	   8'h2f: c=8'h15;
	   8'h30: c=8'h04;
	   8'h31: c=8'hc7;
	   8'h32: c=8'h23;
	   8'h33: c=8'hc3;
	   8'h34: c=8'h18;
	   8'h35: c=8'h96;
	   8'h36: c=8'h05;
	   8'h37: c=8'h9a;
	   8'h38: c=8'h07;
	   8'h39: c=8'h12;
	   8'h3a: c=8'h80;
	   8'h3b: c=8'he2;
	   8'h3c: c=8'heb;
	   8'h3d: c=8'h27;
	   8'h3e: c=8'hb2;
	   8'h3f: c=8'h75;
	   8'h40: c=8'h09;
	   8'h41: c=8'h83;
	   8'h42: c=8'h2c;
	   8'h43: c=8'h1a;
	   8'h44: c=8'h1b;
	   8'h45: c=8'h6e;
	   8'h46: c=8'h5a;
	   8'h47: c=8'ha0;
	   8'h48: c=8'h52;
	   8'h49: c=8'h3b;
	   8'h4a: c=8'hd6;
	   8'h4b: c=8'hb3;
	   8'h4c: c=8'h29;
	   8'h4d: c=8'he3;
	   8'h4e: c=8'h2f;
	   8'h4f: c=8'h84;
	   8'h50: c=8'h53;
	   8'h51: c=8'hd1;
	   8'h52: c=8'h00;
	   8'h53: c=8'hed;
	   8'h54: c=8'h20;
	   8'h55: c=8'hfc;
	   8'h56: c=8'hb1;
	   8'h57: c=8'h5b;
	   8'h58: c=8'h6a;
	   8'h59: c=8'hcb;
	   8'h5a: c=8'hbe;
	   8'h5b: c=8'h39;
	   8'h5c: c=8'h4a;
	   8'h5d: c=8'h4c;
	   8'h5e: c=8'h58;
	   8'h5f: c=8'hcf;
	   8'h60: c=8'hd0;
	   8'h61: c=8'hef;
	   8'h62: c=8'haa;
	   8'h63: c=8'hfb;
	   8'h64: c=8'h43;
	   8'h65: c=8'h4d;
	   8'h66: c=8'h33;
	   8'h67: c=8'h85;
	   8'h68: c=8'h45;
	   8'h69: c=8'hf9;
	   8'h6a: c=8'h02;
	   8'h6b: c=8'h7f;
	   8'h6c: c=8'h50;
	   8'h6d: c=8'h3c;
	   8'h6e: c=8'h9f;
	   8'h6f: c=8'ha8;
	   8'h70: c=8'h51;
	   8'h71: c=8'ha3;
	   8'h72: c=8'h40;
	   8'h73: c=8'h8f;
	   8'h74: c=8'h92;
	   8'h75: c=8'h9d;
	   8'h76: c=8'h38;
	   8'h77: c=8'hf5;
	   8'h78: c=8'hbc;
	   8'h79: c=8'hb6;
	   8'h7a: c=8'hda;
	   8'h7b: c=8'h21;
	   8'h7c: c=8'h10;
	   8'h7d: c=8'hff;
	   8'h7e: c=8'hf3;
	   8'h7f: c=8'hd2;
	   8'h80: c=8'hcd;
	   8'h81: c=8'h0c;
	   8'h82: c=8'h13;
	   8'h83: c=8'hec;
	   8'h84: c=8'h5f;
	   8'h85: c=8'h97;
	   8'h86: c=8'h44;
	   8'h87: c=8'h17;
	   8'h88: c=8'hc4;
	   8'h89: c=8'ha7;
	   8'h8a: c=8'h7e;
	   8'h8b: c=8'h3d;
	   8'h8c: c=8'h64;
	   8'h8d: c=8'h5d;
	   8'h8e: c=8'h19;
	   8'h8f: c=8'h73;
	   8'h90: c=8'h60;
	   8'h91: c=8'h81;
	   8'h92: c=8'h4f;
	   8'h93: c=8'hdc;
	   8'h94: c=8'h22;
	   8'h95: c=8'h2a;
	   8'h96: c=8'h90;
	   8'h97: c=8'h88;
	   8'h98: c=8'h46;
	   8'h99: c=8'hee;
	   8'h9a: c=8'hb8;
	   8'h9b: c=8'h14;
	   8'h9c: c=8'hde;
	   8'h9d: c=8'h5e;
	   8'h9e: c=8'h0b;
	   8'h9f: c=8'hdb;
	   8'ha0: c=8'he0;
	   8'ha1: c=8'h32;
	   8'ha2: c=8'h3a;
	   8'ha3: c=8'h0a;
	   8'ha4: c=8'h49;
	   8'ha5: c=8'h06;
	   8'ha6: c=8'h24;
	   8'ha7: c=8'h5c;
	   8'ha8: c=8'hc2;
	   8'ha9: c=8'hd3;
	   8'haa: c=8'hac;
	   8'hab: c=8'h62;
	   8'hac: c=8'h91;
	   8'had: c=8'h95;
	   8'hae: c=8'he4;
	   8'haf: c=8'h79;
	   8'hb0: c=8'he7;
	   8'hb1: c=8'hc8;
	   8'hb2: c=8'h37;
	   8'hb3: c=8'h6d;
	   8'hb4: c=8'h8d;
	   8'hb5: c=8'hd5;
	   8'hb6: c=8'h4e;
	   8'hb7: c=8'ha9;
	   8'hb8: c=8'h6c;
	   8'hb9: c=8'h56;
	   8'hba: c=8'hf4;
	   8'hbb: c=8'hea;
	   8'hbc: c=8'h65;
	   8'hbd: c=8'h7a;
	   8'hbe: c=8'hae;
	   8'hbf: c=8'h08;
	   8'hc0: c=8'hba;
	   8'hc1: c=8'h78;
	   8'hc2: c=8'h25;
	   8'hc3: c=8'h2e;
	   8'hc4: c=8'h1c;
	   8'hc5: c=8'ha6;
	   8'hc6: c=8'hb4;
	   8'hc7: c=8'hc6;
	   8'hc8: c=8'he8;
	   8'hc9: c=8'hdd;
	   8'hca: c=8'h74;
	   8'hcb: c=8'h1f;
	   8'hcc: c=8'h4b;
	   8'hcd: c=8'hbd;
	   8'hce: c=8'h8b;
	   8'hcf: c=8'h8a;
	   8'hd0: c=8'h70;
	   8'hd1: c=8'h3e;
	   8'hd2: c=8'hb5;
	   8'hd3: c=8'h66;
	   8'hd4: c=8'h48;
	   8'hd5: c=8'h03;
	   8'hd6: c=8'hf6;
	   8'hd7: c=8'h0e;
	   8'hd8: c=8'h61;
	   8'hd9: c=8'h35;
	   8'hda: c=8'h57;
	   8'hdb: c=8'hb9;
	   8'hdc: c=8'h86;
	   8'hdd: c=8'hc1;
	   8'hde: c=8'h1d;
	   8'hdf: c=8'h9e;
	   8'he0: c=8'he1;
	   8'he1: c=8'hf8;
	   8'he2: c=8'h98;
	   8'he3: c=8'h11;
	   8'he4: c=8'h69;
	   8'he5: c=8'hd9;
	   8'he6: c=8'h8e;
	   8'he7: c=8'h94;
	   8'he8: c=8'h9b;
	   8'he9: c=8'h1e;
	   8'hea: c=8'h87;
	   8'heb: c=8'he9;
	   8'hec: c=8'hce;
	   8'hed: c=8'h55;
	   8'hee: c=8'h28;
	   8'hef: c=8'hdf;
	   8'hf0: c=8'h8c;
	   8'hf1: c=8'ha1;
	   8'hf2: c=8'h89;
	   8'hf3: c=8'h0d;
	   8'hf4: c=8'hbf;
	   8'hf5: c=8'he6;
	   8'hf6: c=8'h42;
	   8'hf7: c=8'h68;
	   8'hf8: c=8'h41;
	   8'hf9: c=8'h99;
	   8'hfa: c=8'h2d;
	   8'hfb: c=8'h0f;
	   8'hfc: c=8'hb0;
	   8'hfd: c=8'h54;
	   8'hfe: c=8'hbb;
	   8'hff: c=8'h16;
       default: c = 8'h00;
    endcase
   end
  assign out=c;
endmodule


module decryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
wire [127:0] afterSubBytes;
wire [127:0] keyout;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;

InvShiftRows ir1(in,afterShiftRows);
invSubBytes is1(afterShiftRows,afterSubBytes);
AddRoundKey addkr5(afterSubBytes,key,keyout);
inverseMixColumns im2(keyout,afterMixColumns);
assign out = afterMixColumns;
		
endmodule

module inverseMixColumns(state_in,state_out);
input [0:127] state_in;
output [0:127] state_out;

function[7:0] multiply(input [7:0]x,input integer n);
integer i;
begin
	for(i=0;i<n;i=i+1)
		begin
			if(x[7] == 1) x = ((x << 1) ^ 8'h1b);
			else x = x << 1; 
		end
	multiply=x;
end

endfunction

function [7:0] mul14;
input [7:0] x;
begin
	mul14=multiply(x,3) ^ multiply(x,2)^ multiply(x,1);
end
endfunction

function [7:0] mul13;
input [7:0] x;
begin
	mul13=multiply(x,3) ^ multiply(x,2)^ x;
end
endfunction

function [7:0] mul11;
input [7:0] x;
begin
	mul11=multiply(x,3) ^ multiply(x,1)^ x;
end
endfunction


function [7:0] mul09;
input [7:0] x;
begin
	mul09=multiply(x,3) ^  x;
end
endfunction

genvar i;

generate
	
for(i=0;i< 4;i=i+1) begin : m_col
	assign state_out[i*32+:8]= mul14(state_in[i*32+:8]) ^ mul11(state_in[(i*32 + 8)+:8]) ^ mul13(state_in[(i*32 + 16)+:8])^ mul09(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 8)+:8]= mul09(state_in[i*32+:8]) ^ mul14(state_in[(i*32 + 8)+:8]) ^ mul11(state_in[(i*32 + 16)+:8]) ^ mul13(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 16)+:8]= mul13(state_in[i*32+:8])^ mul09(state_in[(i*32 + 8)+:8]) ^ mul14(state_in[(i*32 + 16)+:8]) ^ mul11(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 24)+:8]= mul11(state_in[i*32+:8]) ^ mul13(state_in[(i*32 + 8)+:8]) ^ mul09(state_in[(i*32 + 16)+:8]) ^ mul14(state_in[(i*32 + 24)+:8]);

	
end

endgenerate



endmodule

module inverseSbox(selector,out);
input  [7:0] selector; 
output [7:0] out;
reg [7:0] sbout;
assign out=sbout;
  always@(selector)
 begin  
    case(selector)
				8'h00:sbout =8'h52;
				8'h01:sbout =8'h09;
				8'h02:sbout =8'h6a;
				8'h03:sbout =8'hd5;
				8'h04:sbout =8'h30;
				8'h05:sbout =8'h36;
				8'h06:sbout =8'ha5;
				8'h07:sbout =8'h38;
				8'h08:sbout =8'hbf;
				8'h09:sbout =8'h40;
				8'h0a:sbout =8'ha3;
				8'h0b:sbout =8'h9e;
				8'h0c:sbout =8'h81;
				8'h0d:sbout =8'hf3;
				8'h0e:sbout =8'hd7;
				8'h0f:sbout =8'hfb;
				8'h10:sbout =8'h7c;
				8'h11:sbout =8'he3;
				8'h12:sbout =8'h39;
				8'h13:sbout =8'h82;
				8'h14:sbout =8'h9b;
				8'h15:sbout =8'h2f;
				8'h16:sbout =8'hff;
				8'h17:sbout =8'h87;
				8'h18:sbout =8'h34;
				8'h19:sbout =8'h8e;
				8'h1a:sbout =8'h43;
				8'h1b:sbout =8'h44;
				8'h1c:sbout =8'hc4;
				8'h1d:sbout =8'hde;
				8'h1e:sbout =8'he9;
				8'h1f:sbout =8'hcb;
				8'h20:sbout =8'h54;
				8'h21:sbout =8'h7b;
				8'h22:sbout =8'h94;
				8'h23:sbout =8'h32;
				8'h24:sbout =8'ha6;
				8'h25:sbout =8'hc2;
				8'h26:sbout =8'h23;
				8'h27:sbout =8'h3d;
				8'h28:sbout =8'hee;
				8'h29:sbout =8'h4c;
				8'h2a:sbout =8'h95;
				8'h2b:sbout =8'h0b;
				8'h2c:sbout =8'h42;
				8'h2d:sbout =8'hfa;
				8'h2e:sbout =8'hc3;
				8'h2f:sbout =8'h4e;
				8'h30:sbout =8'h08;
				8'h31:sbout =8'h2e;
				8'h32:sbout =8'ha1;
				8'h33:sbout =8'h66;
				8'h34:sbout =8'h28;
				8'h35:sbout =8'hd9;
				8'h36:sbout =8'h24;
				8'h37:sbout =8'hb2;
				8'h38:sbout =8'h76;
				8'h39:sbout =8'h5b;
				8'h3a:sbout =8'ha2;
				8'h3b:sbout =8'h49;
				8'h3c:sbout =8'h6d;
				8'h3d:sbout =8'h8b;
				8'h3e:sbout =8'hd1;
				8'h3f:sbout =8'h25;
				8'h40:sbout =8'h72;
				8'h41:sbout =8'hf8;
				8'h42:sbout =8'hf6;
				8'h43:sbout =8'h64;
				8'h44:sbout =8'h86;
				8'h45:sbout =8'h68;
				8'h46:sbout =8'h98;
				8'h47:sbout =8'h16;
				8'h48:sbout =8'hd4;
				8'h49:sbout =8'ha4;
				8'h4a:sbout =8'h5c;
				8'h4b:sbout =8'hcc;
				8'h4c:sbout =8'h5d;
				8'h4d:sbout =8'h65;
				8'h4e:sbout =8'hb6;
				8'h4f:sbout =8'h92;
				8'h50:sbout =8'h6c;
				8'h51:sbout =8'h70;
				8'h52:sbout =8'h48;
				8'h53:sbout =8'h50;
				8'h54:sbout =8'hfd;
				8'h55:sbout =8'hed;
				8'h56:sbout =8'hb9;
				8'h57:sbout =8'hda;
				8'h58:sbout =8'h5e;
				8'h59:sbout =8'h15;
				8'h5a:sbout =8'h46;
				8'h5b:sbout =8'h57;
				8'h5c:sbout =8'ha7;
				8'h5d:sbout =8'h8d;
				8'h5e:sbout =8'h9d;
				8'h5f:sbout =8'h84;
				8'h60:sbout =8'h90;
				8'h61:sbout =8'hd8;
				8'h62:sbout =8'hab;
				8'h63:sbout =8'h00;
				8'h64:sbout =8'h8c;
				8'h65:sbout =8'hbc;
				8'h66:sbout =8'hd3;
				8'h67:sbout =8'h0a;
				8'h68:sbout =8'hf7;
				8'h69:sbout =8'he4;
				8'h6a:sbout =8'h58;
				8'h6b:sbout =8'h05;
				8'h6c:sbout =8'hb8;
				8'h6d:sbout =8'hb3;
				8'h6e:sbout =8'h45;
				8'h6f:sbout =8'h06;
				8'h70:sbout =8'hd0;
				8'h71:sbout =8'h2c;
				8'h72:sbout =8'h1e;
				8'h73:sbout =8'h8f;
				8'h74:sbout =8'hca;
				8'h75:sbout =8'h3f;
				8'h76:sbout =8'h0f;
				8'h77:sbout =8'h02;
				8'h78:sbout =8'hc1;
				8'h79:sbout =8'haf;
				8'h7a:sbout =8'hbd;
				8'h7b:sbout =8'h03;
				8'h7c:sbout =8'h01;
				8'h7d:sbout =8'h13;
				8'h7e:sbout =8'h8a;
				8'h7f:sbout =8'h6b;
				8'h80:sbout =8'h3a;
				8'h81:sbout =8'h91;
				8'h82:sbout =8'h11;
				8'h83:sbout =8'h41;
				8'h84:sbout =8'h4f;
				8'h85:sbout =8'h67;
				8'h86:sbout =8'hdc;
				8'h87:sbout =8'hea;
				8'h88:sbout =8'h97;
				8'h89:sbout =8'hf2;
				8'h8a:sbout =8'hcf;
				8'h8b:sbout =8'hce;
				8'h8c:sbout =8'hf0;
				8'h8d:sbout =8'hb4;
				8'h8e:sbout =8'he6;
				8'h8f:sbout =8'h73;
				8'h90:sbout =8'h96;
				8'h91:sbout =8'hac;
				8'h92:sbout =8'h74;
				8'h93:sbout =8'h22;
				8'h94:sbout =8'he7;
				8'h95:sbout =8'had;
				8'h96:sbout =8'h35;
				8'h97:sbout =8'h85;
				8'h98:sbout =8'he2;
				8'h99:sbout =8'hf9;
				8'h9a:sbout =8'h37;
				8'h9b:sbout =8'he8;
				8'h9c:sbout =8'h1c;
				8'h9d:sbout =8'h75;
				8'h9e:sbout =8'hdf;
				8'h9f:sbout =8'h6e;
				8'ha0:sbout =8'h47;
				8'ha1:sbout =8'hf1;
				8'ha2:sbout =8'h1a;
				8'ha3:sbout =8'h71;
				8'ha4:sbout =8'h1d;
				8'ha5:sbout =8'h29;
				8'ha6:sbout =8'hc5;
				8'ha7:sbout =8'h89;
				8'ha8:sbout =8'h6f;
				8'ha9:sbout =8'hb7;
				8'haa:sbout =8'h62;
				8'hab:sbout =8'h0e;
				8'hac:sbout =8'haa;
				8'had:sbout =8'h18;
				8'hae:sbout =8'hbe;
				8'haf:sbout =8'h1b;
				8'hb0:sbout =8'hfc;
				8'hb1:sbout =8'h56;
				8'hb2:sbout =8'h3e;
				8'hb3:sbout =8'h4b;
				8'hb4:sbout =8'hc6;
				8'hb5:sbout =8'hd2;
				8'hb6:sbout =8'h79;
				8'hb7:sbout =8'h20;
				8'hb8:sbout =8'h9a;
				8'hb9:sbout =8'hdb;
				8'hba:sbout =8'hc0;
				8'hbb:sbout =8'hfe;
				8'hbc:sbout =8'h78;
				8'hbd:sbout =8'hcd;
				8'hbe:sbout =8'h5a;
				8'hbf:sbout =8'hf4;
				8'hc0:sbout =8'h1f;
				8'hc1:sbout =8'hdd;
				8'hc2:sbout =8'ha8;
				8'hc3:sbout =8'h33;
				8'hc4:sbout =8'h88;
				8'hc5:sbout =8'h07;
				8'hc6:sbout =8'hc7;
				8'hc7:sbout =8'h31;
				8'hc8:sbout =8'hb1;
				8'hc9:sbout =8'h12;
				8'hca:sbout =8'h10;
				8'hcb:sbout =8'h59;
				8'hcc:sbout =8'h27;
				8'hcd:sbout =8'h80;
				8'hce:sbout =8'hec;
				8'hcf:sbout =8'h5f;
				8'hd0:sbout =8'h60;
				8'hd1:sbout =8'h51;
				8'hd2:sbout =8'h7f;
				8'hd3:sbout =8'ha9;
				8'hd4:sbout =8'h19;
				8'hd5:sbout =8'hb5;
				8'hd6:sbout =8'h4a;
				8'hd7:sbout =8'h0d;
				8'hd8:sbout =8'h2d;
				8'hd9:sbout =8'he5;
				8'hda:sbout =8'h7a;
				8'hdb:sbout =8'h9f;
				8'hdc:sbout =8'h93;
				8'hdd:sbout =8'hc9;
				8'hde:sbout =8'h9c;
				8'hdf:sbout =8'hef;
				8'he0:sbout =8'ha0;
				8'he1:sbout =8'he0;
				8'he2:sbout =8'h3b;
				8'he3:sbout =8'h4d;
				8'he4:sbout =8'hae;
				8'he5:sbout =8'h2a;
				8'he6:sbout =8'hf5;
				8'he7:sbout =8'hb0;
				8'he8:sbout =8'hc8;
				8'he9:sbout =8'heb;
				8'hea:sbout =8'hbb;
				8'heb:sbout =8'h3c;
				8'hec:sbout =8'h83;
				8'hed:sbout =8'h53;
				8'hee:sbout =8'h99;
				8'hef:sbout =8'h61;
				8'hf0:sbout =8'h17;
				8'hf1:sbout =8'h2b;
				8'hf2:sbout =8'h04;
				8'hf3:sbout =8'h7e;
				8'hf4:sbout =8'hba;
				8'hf5:sbout =8'h77;
				8'hf6:sbout =8'hd6;
				8'hf7:sbout =8'h26;
				8'hf8:sbout =8'he1;
				8'hf9:sbout =8'h69;
				8'hfa:sbout =8'h14;
				8'hfb:sbout =8'h63;
				8'hfc:sbout =8'h55;
				8'hfd:sbout =8'h21;
				8'hfe:sbout =8'h0c;
				8'hff:sbout =8'h7d;
				endcase
end

endmodule

module InvShiftRows(input  [0:127] state_in ,  output  [0:127] state_out );

//first row
assign state_out[0:7] = state_in[0:7];
assign state_out[32:39] = state_in[32:39];
assign state_out[64:71] = state_in[64:71];
assign state_out[96:103] = state_in[96:103];

//second row
assign state_out[8:15] = state_in[104:111];
assign state_out[40:47] = state_in[8:15];
assign state_out[72:79] = state_in[40:47];
assign state_out[104:111] = state_in[72:79];

//third row
assign state_out[16:23] = state_in[80:87];
assign state_out[48:55] = state_in[112:119];
assign state_out[80:87] = state_in[16:23];
assign state_out[112:119] = state_in[48:55];

//forth row
assign state_out[24:31] = state_in[56:63];
assign state_out[56:63] = state_in[88:95];
assign state_out[88:95] = state_in[120:127];
assign state_out[120:127] = state_in[24:31];

endmodule

module invSubBytes(input [127:0] in , output [127:0] out);
genvar i;

generate
  for(i=0;i<16;i=i+1)begin : sub_bytes
    inverseSbox isb1(in[(i+1)*8-1:i*8],out[(i+1)*8-1:i*8]);
    end
endgenerate
endmodule

module shift_add(input [0:3] in, output reg [0:3]out);
     always @(*) begin
    if (in >= 4'b0101) out = in + 4'b0011; // Add 3 if input is 5 or greater
     else out = in;
     end
endmodule



module binarytoBCD(input [0:7] in, output [0:11] out);
wire [0:3]A,B,C,D,E,F,G;

shift_add A1({1'b0, in[0:2]},A);
shift_add B1({A[1:3],in[3]},B);
shift_add C1 ({B[1:3],in[4]},C);
shift_add D1({C[1:3],in[5]},D);
shift_add E1({D[1:3],in[6]},E);
shift_add F1({1'b0,A[0],B[0],C[0]},F);
shift_add G1({F[1:3],D[0]},G);

assign out[11] = in[7];
assign out[10] = E[3];
assign out[9] = E[2];
assign out[8] = E[1];
assign out[7] = E[0];
assign out[6] = G[3];
assign out[5] = G[2];
assign out[4] = G[1];
assign out[3] = G[0];
assign out[2] = F[0];
assign out[1] = 1'b0;
assign out[0] = 1'b0;

endmodule

module HexConverter (in, converted);
	input [3:0] in;
	output reg [6:0] converted;
    always @(*)
        begin
	       case(in)
            4'h0: converted[6:0] = 7'b1000000;
            4'h1: converted[6:0] = 7'b1111001;
            4'h2: converted[6:0] = 7'b0100100;
            4'h3: converted[6:0] = 7'b0110000;
            4'h4: converted[6:0] = 7'b0011001;
            4'h5: converted[6:0] = 7'b0010010;
            4'h6: converted[6:0] = 7'b0000010;
            4'h7: converted[6:0] = 7'b1111000;
            4'h8: converted[6:0] = 7'b0000000;
            4'h9: converted[6:0] = 7'b0010000;
            4'hA: converted[6:0] = 7'b0001000;
            4'hB: converted[6:0] = 7'b0000011;
            4'hC: converted[6:0] = 7'b0100111;
            4'hD: converted[6:0] = 7'b0100001;
            4'hE: converted[6:0] = 7'b0000110;
            default : converted[6:0] = 7'b0001110;
           endcase
        end
endmodule