module AES (input clk,output[6:0]HEX0,output[6:0]HEX1,output[6:0]HEX2,output Equal);
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
    integer i = -1;
    wire [127:0] out;
    wire [1407:0] words;
    wire [127:0] encrypted;
	reg enable   = 0;
    wire [127:0] decrypted;
    KeyExpansion k1 (key,words);
    Cipher c1 (in,words,clk,encrypted);
    DeCipher dc1 (encrypted,words,clk,enable,decrypted);
    assign out=(i<11)?encrypted:decrypted;
    always@(negedge clk) begin
        if(i<22) begin
                 if(i==9)begin
					enable = 1;
				 end
            end
            i = i + 1;
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
