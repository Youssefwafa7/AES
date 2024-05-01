module Cipher(input [127 : 0] in, input [1407 : 0] w , input clk ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
    integer i=-1;
	reg [127:0] currentstate;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    AddRoundKey addrk1 (in, w[1407 : 1280], firstround);
	encryptRound er (currentstate ,w[1407-((i+1)*128)-:128],midrounds);
	SubBytes sb(currentstate,sub);
	ShiftRows sr(sub,shift);
	AddRoundKey addrk2(shift,w[127:0],finalround);


	always @ (negedge clk) begin 
		if(i<10)begin 
				if(i==-1&& firstround !== 'bx)begin
					currentstate<=firstround;
					finalout <= firstround;
					i=i+1;
				end
				else if(i<=8&& midrounds !== 'bx)begin
						currentstate<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==9&& midrounds !== 'bx)begin
						finalout <= finalround;
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