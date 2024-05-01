module DeCipher(input [127 : 0] in, input [1407 : 0] w , input clk ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
    integer i=-1;
	reg [1407:0] states;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    AddRoundKey addrk3 (in, w[127 : 0], firstround);
	decryptRound dr (states [1407-((i)*128)-:128] ,w[((i*128)-1)-:128],midrounds);
	InvShiftRows isr(states[255:128],shift);
	invSubBytes isb(shift,sub);
	AddRoundKey addrk4 (sub,w[1407:1280],finalround);


	always @ (posedge clk) begin 
		if(i<10)begin 
				if(i==-1&& firstround !== 'bx)begin
					states[1407-:128]<=firstround;
					finalout <= firstround;
					i=i+1;
				end
				else if(i<=8&& midrounds !== 'bx)begin
						states[1407-((i+1)*128)-:128]<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==9&& midrounds !== 'bx)begin
						states[127:0]<=midrounds;
						finalout <= finalround;
					end

		end	
	end
endmodule
module decryptRound(in,key,out);
input [127:0] in;
output [127:0] out;
input [127:0] key;
wire [127:0] afterSubBytes;
wire [127:0] keyout;
wire [127:0] afterShiftRows;
wire [127:0] afterMixColumns;

InvShiftRows ir1(in,afterShiftRows);
invSubBytes is1(afterShiftRows,afterSubBytes);
AddRoundKey addkr5(afterSubBytes,key,keyout);
inverseMixColumns im2(keyout,afterMixColumns);
assign out = afterMixColumns;
		
endmodule