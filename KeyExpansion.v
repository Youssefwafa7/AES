module KeyExpansion(input [0:127] key , output [0:1408] word);

function [0:31] rcon;
input integer x;
begin
 case(x)
    2: rcon=32'h01000000;
    3: rcon=32'h02000000;
    4: rcon=32'h04000000;
    5: rcon=32'h08000000;
    6: rcon=32'h10000000;
    7: rcon=32'h20000000;
    8: rcon=32'h40000000;
    9: rcon=32'h80000000;
    10: rcon=32'h1b000000;
    11: rcon=32'h36000000;
    default: rcon=32'h00000000;
  endcase
  end
endfunction

function [0:31] g;
input [0:31] x;
input integer rconi;
begin
    wire y;
    x = {x[8:31],x[0:7]};
    //SubBytes(x,y);
    //g = y xor rcon
    input rconx = rcon(rconi);
    g = y ^ rconx;
//input rcon = [ 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36];
end
endfunction
assign word[0 : 127] = key[0 : 127];

genvar i;
generate
for(i = 2 ; i <= 11 ; i = i + 1) begin

    wire G = g(word[ (i-1)*128 + 96 : (i-1)*32 + 127]);
   assign word[ i*128       : i*32 + 31 ] = word[ (i-1)*128       : (i-1)*32 + 31 ] ^ G ;
   assign word[ i*128 + 32  : i*32 + 63 ] = word[ (i-1)*128 + 32  : (i-1)*32 + 63 ] ^ word[ i*128       : i*32 + 31 ];
   assign word[ i*128 + 64  : i*32 + 95 ] = word[ (i-1)*128 + 64  : (i-1)*32 + 95 ] ^ word[ i*128 + 32  : i*32 + 63 ];
   assign word[ i*128 + 96  : i*32 + 127] = word[ (i-1)*128 + 96  : (i-1)*32 + 127] ^ word[ i*128 + 64  : i*32 + 95 ];
end

endgenerate
endmodule