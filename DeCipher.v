module DeCipher#(parameter Nk = 4 ,parameter Nr = 10)(input [127 : 0] in, input [(Nr+1)*128-1 : 0] w , input clk,input enable ,output reg [127 : 0] finalout);
   	wire [127 : 0] finalround;
    wire [127 : 0] sub;
    wire [127 : 0] shift;
	reg [127:0] currentstate;
    wire [127 : 0] midrounds;
	wire [127:0] firstround;
    integer i=-1;
    AddRoundKey addrk3 (in, w[127 : 0], firstround);
	  decryptRound dr (currentstate ,w[(((i+2)*128)-1)-:128],midrounds);
	  InvShiftRows isr(currentstate,shift);
	  invSubBytes isb(shift,sub);
	  AddRoundKey addrk4 (sub,w[(Nr+1)*128-1-:128],finalround);


	always @ (negedge clk) begin 
		if(i<Nr && enable)begin 
				if(i==-1&& firstround !== 'bx)begin
					currentstate<=firstround;
					finalout <= firstround;
					i=i+1;
				end
				else if(i<=Nr-2&& midrounds !== 'bx)begin
						currentstate<=midrounds;
						finalout <= midrounds;
						i=i+1;
					end 
					else if(i==Nr-1&& midrounds !== 'bx)begin
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
