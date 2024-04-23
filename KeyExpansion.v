module KeyExpansion(input [127 : 0] key , output [1408 : 0] word);

 
  assign word[127 : 0] = key[127 : 0];

  genvar i;
  generate
    for (i = 1; i <= 10; i = i + 1) begin
      wire [31:0] G;
      g g1 (word[(i-1)*128 + 31 : (i-1)*128], i , G);
      assign word[i*128 + 31  : i*128     ] = word[(i-1)*128 + 31  : (i-1)*128] ^ G;
      assign word[i*128 + 63  : i*128 + 32] = word[(i-1)*128 + 63  : (i-1)*128 + 32] ^ word[i*128 + 31  : i*128     ];
      assign word[i*128 + 95  : i*128 + 64] = word[(i-1)*128 + 95  : (i-1)*128 + 64] ^ word[i*128 + 63  : i*128 + 32];
      assign word[i*128 + 127 : i*128 + 96] = word[(i-1)*128 + 127 : (i-1)*128 + 96] ^ word[i*128 + 95  : i*128 + 64];
    end
  endgenerate
endmodule

module getrcon(input integer x, output [31:0] rcon);
    assign rcon = (x == 1)  ? 32'h01000000 :
                  (x == 2)  ? 32'h02000000 :
                  (x == 3)  ? 32'h04000000 :
                  (x == 4)  ? 32'h08000000 :
                  (x == 5)  ? 32'h10000000 :
                  (x == 6)  ? 32'h20000000 :
                  (x == 7)  ? 32'h40000000 :
                  (x == 8)  ? 32'h80000000 :
                  (x == 9)  ? 32'h1b000000 :
                  (x == 10) ? 32'h36000000 :
                              32'h00000000;
endmodule


module g (input [31:0] x, input integer rconi, output [31:0] out);
      wire [31:0] shiftedx = {x[23:0], x[31:24]};
      wire [31:0] rconx;
      //wire [31:0] subx;
      //SubBytes(shiftedx , subx)
      getrcon r1 (rconi , rconx);
      //assign out = subx ^ rconx;
endmodule

