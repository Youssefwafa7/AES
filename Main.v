module main (input [127 : 0] in, input  [127 : 0] key , output [127 : 0] out);
    assign in = 00112233445566778899aabbccddeeff;
    assign key = 000102030405060708090a0b0c0d0e0f;
    wire [1407:0] words;
    wire [127:0] out1;
    KeyExpansion k1 (key,words);
    Cipher c1 (in,words,out1);
    assign out=out1;
endmodule