module Cipher#(parameter Nk = 4 ,parameter Nr = 10)(input [127 : 0] in, input [(Nr+1)*128-1 : 0] w , input clk ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
	reg [127:0] currentState;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    integer i=-1;
    AddRoundKey addrk1 (in, w[(Nr+1)*128-1 -: 128], firstround);
	encryptRound er (currentState ,w[(Nr+1)*128-1-((i+1)*128)-:128],midrounds);
	SubBytes sb(currentState,sub);
	ShiftRows sr(sub,shift);
  	AddRoundKey addrk2(shift,w[127:0],finalround);


	always @ (negedge clk) begin 
		if(i<Nr)begin 
				if(i==-1&& firstround !== 'bx)begin
					currentState<=firstround;
					finalout = firstround;
					i=i+1;
				end
				else if(i<=Nr-2&& midrounds !== 'bx)begin
						currentState<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==Nr-1&& midrounds !== 'bx)begin
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