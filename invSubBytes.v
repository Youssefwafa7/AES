// Write your modules here!
module invSubBytes(input [127:0] in , output [127:0] out);
genvar i;

generate
  for(i=0;i<16;i=i+1)begin
    inverseSbox s1(in[(i+1)*8-1:i*8],out[(i+1)*8-1:i*8]);
    end
endgenerate
endmodule