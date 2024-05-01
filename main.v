
module main (input clk,output [127 : 0] out);
    wire [127:0] in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
    wire [1407:0] words;
    wire [127:0] out188;
    wire [127:0] out189;
    KeyExpansion k1 (key,words);
    Cipher c1 (in,words,clk,out188);
    DeCipher dc1 (out188,words,clk,out189);
    assign out=out189;
endmodule