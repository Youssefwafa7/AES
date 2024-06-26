module mixColumns(state_in,state_out);

input [0:127] state_in;
output[0:127] state_out;

function [7:0] mul02;
	input [7:0] x;
	begin 
			if(x[7] == 1) mul02 = ((x << 1) ^ 8'h1b);
			else mul02 = x << 1; 
	end 	
endfunction


function [7:0] mul03;
	input [7:0] x;
	begin 
			
			mul03 = mul02(x) ^ x;
	end 
endfunction


genvar i;

generate

for(i=0;i< 4;i=i+1) begin : m_col

assign state_out[i*32+:8]= mul02(state_in[i*32+:8]) ^ mul03(state_in[(i*32 + 8)+:8]) ^ state_in[(i*32 + 16)+:8] ^ state_in[(i*32 + 24)+:8];
assign state_out[(i*32 + 8)+:8]= state_in[i*32+:8] ^ mul02(state_in[(i*32 + 8)+:8]) ^ mul03(state_in[(i*32 + 16)+:8]) ^ state_in[(i*32 + 24)+:8];
assign state_out[(i*32 + 16)+:8]= state_in[i*32+:8] ^ state_in[(i*32 + 8)+:8] ^ mul02(state_in[(i*32 + 16)+:8]) ^ mul03(state_in[(i*32 + 24)+:8]);
assign state_out[(i*32 + 24)+:8]= mul03(state_in[i*32+:8]) ^ state_in[(i*32 + 8)+:8] ^ state_in[(i*32 + 16)+:8] ^ mul02(state_in[(i*32 + 24)+:8]);

end

endgenerate

endmodule