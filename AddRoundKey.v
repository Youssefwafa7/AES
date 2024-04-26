module AddRoundKey(input [127:0] in,input[127:0] in2, output[127:0] out);
assign out=in2^in;
endmodule