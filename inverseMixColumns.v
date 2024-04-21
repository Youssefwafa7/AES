module inverseMixColumns(state_in,state_out);
input [0:127] state_in;
output [0:127] state_out;

function[7:0] multiply(input [7:0]x,input integer n);
integer i;
begin
	for(i=0;i<n;i=i+1)
		begin
			if(x[7] == 1) x = ((x << 1) ^ 8'h1b);
			else x = x << 1; 
		end
	multiply=x;
end

endfunction

function [7:0] mul14;
input [7:0] x;
begin
	mul14=multiply(x,3) ^ multiply(x,2)^ multiply(x,1);
end
endfunction

function [7:0] mul13;
input [7:0] x;
begin
	mul13=multiply(x,3) ^ multiply(x,2)^ x;
end
endfunction

function [7:0] mul11;
input [7:0] x;
begin
	mul11=multiply(x,3) ^ multiply(x,1)^ x;
end
endfunction


function [7:0] mul09;
input [7:0] x;
begin
	mul09=multiply(x,3) ^  x;
end
endfunction

genvar i;

generate
	
for(i=0;i< 4;i=i+1) begin : m_col

	assign state_out[i*32 + :8]		= mul14(state_in[i*32+:8]) ^ mul11(state_in[(i*32 + 8)+:8]) ^ mul13(state_in[(i*32 + 16)+:8]) ^ mul09(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 8)+:8]	= mul09(state_in[i*32+:8]) ^ mul14(state_in[(i*32 + 8)+:8]) ^ mul11(state_in[(i*32 + 16)+:8]) ^ mul13(state_in[(i*32 + 24)+:8]);
	assign state_out[(i*32 + 16)+:8]= mul13(state_in[i*32+:8]) ^ mul09(state_in[(i*32 + 8)+:8]) ^ mul14(state_in[(i*32 + 16)+:8]) ^ mul11(state_in[(i*32 + 24)+:8]);
   	assign state_out[(i*32 + 24)+:8]= mul11(state_in[i*32+:8]) ^ mul13(state_in[(i*32 + 8)+:8]) ^ mul09(state_in[(i*32 + 16)+:8]) ^ mul14(state_in[(i*32 + 24)+:8]);

end

endgenerate



endmodule