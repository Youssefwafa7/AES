
module main (input clk,output [127 : 0] out);
    wire [127:0] in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
    wire [1407:0] words;
    wire [127:0] out189;
    KeyExpansion k1 (key,words);
    DeCipher dc1 (in,words,clk,out189);
    assign out=out189;
endmodule

module DeCipher(input [127 : 0] in, input [1407 : 0] w , input clk ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
    integer i=-1;
	reg [1407:0] states;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    AddRoundKey addrk3 (in, w[127 : 0], firstround);
	decryptRound dr (states [1407-((i)*128)-:128] ,w[(((i+1)*128)-1)-:128],midrounds);
	InvShiftRows isr(states[255:128],shift);
	invSubBytes isb(shift,sub);
	AddRoundKey addrk4 (sub,w[1407:1280],finalround);


	always @ (posedge clk) begin 
		if(i<10)begin 
				if(i==-1&& firstround !== 'bx)begin
					states[1407-:128]<=firstround;
					finalout <= firstround;
					i=i+1;
				end
				else if(i<=8&& midrounds !== 'bx)begin
						states[1407-((i+1)*128)-:128]<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==9&& midrounds !== 'bx)begin
						states[127:0]<=midrounds;
						finalout <= finalround;
					end

		end	
	end
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

module KeyExpansion(input [127 : 0] key , output [1407 : 0] word);
 
  assign word[1407 : 1280] = key[127 : 0];

  genvar i;
  generate
    for (i = 1; i <= 10; i = i + 1) begin
      wire [31:0] G;
      g getG (word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127], i , G);
      assign word[1407 - i*128	    : 1407 - i*128 - 31 ] = word[1407 - (i-1)*128	   : 1407 - (i-1)*128 - 31 ] ^ G;
      assign word[1407 - i*128 - 32 : 1407 - i*128 - 63 ] = word[1407 - (i-1)*128 - 32 : 1407 - (i-1)*128 - 63 ] ^ word[1407 - i*128	  : 1407 - i*128 - 31 ];
      assign word[1407 - i*128 - 64 : 1407 - i*128 - 95 ] = word[1407 - (i-1)*128 - 64 : 1407 - (i-1)*128 - 95 ] ^ word[1407 - i*128 - 32 : 1407 - i*128 - 63 ];
      assign word[1407 - i*128 - 96 : 1407 - i*128 - 127] = word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127] ^ word[1407 - i*128 - 64 : 1407 - i*128 - 95 ];
    end
  endgenerate
endmodule

module getrcon(input integer x, output [31:0] rcon);
    assign rcon = (x == 1)  ? 32'h01000000 :
                  (x == 2)  ? 32'h02000000 :
                  (x == 3)  ? 32'h04000000 :
                  (x == 4)  ? 32'h08000000 :
                  (x == 5)  ? 32'h10000000 :
                  (x == 6)  ? 32'h20000000 :
                  (x == 7)  ? 32'h40000000 :
                  (x == 8)  ? 32'h80000000 :
                  (x == 9)  ? 32'h1b000000 :
                  (x == 10) ? 32'h36000000 :
                              32'h00000000;
endmodule

module g (input [31:0] x, input integer rconi, output [31:0] out);
   
    wire [31:0] shiftedx = {x[23:0], x[31:24]};
    wire [31:0] rconx;
    wire [31:0] subx;

    subword getsubword (shiftedx , subx);
    getrcon GR1 (rconi , rconx);
    assign out = subx ^ rconx;
endmodule

 module subword(input [31:0] a , output [31:0] subwordx);
    wire [31:0] subwire;
    sbox spart1 (a[31:24], subwire[31:24]);
    sbox spart2 (a[23:16], subwire[23:16]);
    sbox spart3 (a[15:8] , subwire[15:8] );
    sbox spart4 (a[7:0]  , subwire[7:0]  );
    assign subwordx = subwire;
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

	assign state_out[i*32 + :8]		= mul14(state_in[i*32+:8]) ^ mul11(state_in[(i*32 + 8)+:8]) ^ mul13(state_in[(i*32 + 16)+:8]) ^ mul09(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 8)+:8]	= mul09(state_in[i*32+:8]) ^ mul14(state_in[(i*32 + 8)+:8]) ^ mul11(state_in[(i*32 + 16)+:8]) ^ mul13(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 16)+:8]= mul13(state_in[i*32+:8]) ^ mul09(state_in[(i*32 + 8)+:8]) ^ mul14(state_in[(i*32 + 16)+:8]) ^ mul11(state_in[(i*32 + 24)+:8]);
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


