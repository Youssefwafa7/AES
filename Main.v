
module main (input clk,output [127 : 0] out);
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
    wire [1407:0] words;
    wire [127:0] out188;
    KeyExpansion k1 (key,words);
    Cipher c1 (in,words,clk,out188);
    assign out=out188;
endmodule