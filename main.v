
module AES (input clk,output reg [127 : 0] out , output [20:0] sevensegment);
    wire [127:0] in = 128'h00112233445566778899aabbccddeeff;
    wire [127:0] key = 128'h000102030405060708090a0b0c0d0e0f;
	integer i = -1;
    wire [1407:0] words;
    wire [127:0] encrypted;
    wire [127:0] decrypted;
    KeyExpansion k1 (key,words);
    Cipher c1 (in,words,clk,i,encrypted);
    DeCipher dc1 (encrypted,words,clk,i,decrypted);
    always@(negedge clk) begin
		if(i<21) begin
        	if(i<10) begin
        	     out <= encrypted;
        	end
        	else begin
        	    out <= decrypted;
        	end
			i = i + 1;
		end
    end
    wire [7:0] bin = out[7:0];
    wire [11:0] bout;
    binarytoBCD B2B(bin , bout);
	wire [20:0]hexout;
    HexConverter HC0(bout[3:0] , hexout[6:0]);
    HexConverter HC1(bout[7:4] , hexout[13:7]);
    HexConverter HC2(bout[11:8], hexout[20:14]);
	assign sevensegment = hexout;
endmodule
