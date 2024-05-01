module KeyExpansion(input [127 : 0] key , output [1407 : 0] word);
 
  assign word[1407 : 1280] = key[127 : 0];

  genvar i;
  generate
    for (i = 1; i <= 10; i = i + 1) begin: Key
      wire [31:0] G;
      g getG (word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127], i , G);
      assign word[1407 - i*128	    : 1407 - i*128 - 31 ] = word[1407 - (i-1)*128	   : 1407 - (i-1)*128 - 31 ] ^ G;
      assign word[1407 - i*128 - 32 : 1407 - i*128 - 63 ] = word[1407 - (i-1)*128 - 32 : 1407 - (i-1)*128 - 63 ] ^ word[1407 - i*128	  : 1407 - i*128 - 31 ];
      assign word[1407 - i*128 - 64 : 1407 - i*128 - 95 ] = word[1407 - (i-1)*128 - 64 : 1407 - (i-1)*128 - 95 ] ^ word[1407 - i*128 - 32 : 1407 - i*128 - 63 ];
      assign word[1407 - i*128 - 96 : 1407 - i*128 - 127] = word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127] ^ word[1407 - i*128 - 64 : 1407 - i*128 - 95 ];
    end
  endgenerate
endmodule

module getrcon(input [3:0] x, output [31:0] rcon);
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

module g (input [31:0] x, input [3:0] rconi, output [31:0] out);
   
    wire [31:0] shiftedx = {x[23:0], x[31:24]};
    wire [31:0] rconx;
    wire [31:0] subx;

    subword getsubword (shiftedx , subx);
    getrcon GR1 (rconi , rconx);
    assign out = subx ^ rconx;
endmodule

 module subword(input [31:0] a , output [31:0] subwordx);
    wire [31:0] subwire;
    sbox spart1 (a[31:24], subwire[31:24]);
    sbox spart2 (a[23:16], subwire[23:16]);
    sbox spart3 (a[15:8] , subwire[15:8] );
    sbox spart4 (a[7:0]  , subwire[7:0]  );
    assign subwordx = subwire;
endmodule