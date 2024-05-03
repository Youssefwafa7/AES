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
