module Cipher(input [127 : 0] in, input [1407 : 0] w , input clk ,output reg [127 : 0] out7);
   	wire [127 : 0] out1;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
    //wire [127 : 0] out2;
   // wire [127 : 0] out9;
    integer i=-1;
	reg [1407:0] states;
    wire [127 : 0] out44;
	wire [127:0] k222;
    AddRoundKey k2 (in, w[1407 : 1280], k222);
	encryptRound e9 (states [1407-((i)*128)-:128] ,w[1407-((i+1)*128)-:128],out44);
	SubBytes sb(states[255:128],sub);
	ShiftRows sr(sub,shift);
	AddRoundKey addrk2(shift,w[127:0],out1);


	always @ (posedge clk) begin 
		if(i<10)begin 
				if(i==-1&& k222 !== 'bx)begin
					states[1407-:128]<=k222;
					out7 <= k222;
					i=i+1;
				end
				else if(i<=8&& out44 !== 'bx)begin
						states[1407-((i+1)*128)-:128]<=out44;
						out7 <= out44;
						i=i+1;
					end 
					else if(i==9&& out44 !== 'bx)begin
						states[127:0]<=out44;
						out7<=out1;
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