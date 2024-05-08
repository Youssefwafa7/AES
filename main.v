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
     always @(SW) begin
       	if (SW==1) begin
            Nr=12;
         end
        else if (SW==2) begin
            Nr=14;
        end else Nr=10;
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
			enable=0;
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