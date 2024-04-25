module KeyExpansion(input [127 : 0] key , output [1407 : 0] word);
 
  assign word[1407 : 1280] = key[127 : 0];

  genvar i;
  generate
    for (i = 1; i <= 10; i = i + 1) begin
      wire [31:0] G;
      g g1 (word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127], i , G);
      assign word[1407 - i*128	    : 1407 - i*128 - 31 ] = word[1407 - (i-1)*128	   : 1407 - (i-1)*128 - 31 ] ^ G;
      assign word[1407 - i*128 - 32 : 1407 - i*128 - 63 ] = word[1407 - (i-1)*128 - 32 : 1407 - (i-1)*128 - 63 ] ^ word[1407 - i*128	  : 1407 - i*128 - 31 ];
      assign word[1407 - i*128 - 64 : 1407 - i*128 - 95 ] = word[1407 - (i-1)*128 - 64 : 1407 - (i-1)*128 - 95 ] ^ word[1407 - i*128 - 32 : 1407 - i*128 - 63 ];
      assign word[1407 - i*128 - 96 : 1407 - i*128 - 127] = word[1407 - (i-1)*128 - 96 : 1407 - (i-1)*128 - 127] ^ word[1407 - i*128 - 64 : 1407 - i*128 - 95 ];
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
    wire [31:0] subx;

    subword s1 (shiftedx , subx);
    getrcon r1 (rconi , rconx);
    assign out = subx ^ rconx;
endmodule

 module subword(input [31:0] a , output [31:0] subwordx);
    wire [31:0] subwire;
    sbox s1 (a[31:24], subwire[31:24]);
    sbox s2 (a[23:16], subwire[23:16]);
    sbox s3 (a[15:8] , subwire[15:8] );
    sbox s4 (a[7:0]  , subwire[7:0]  );
    assign subwordx = subwire;
endmodule
//wafa
//2b7e151628aed2a6abf7158809cf4f3c
//2b7e1516 28aed2a6 abf71588 09cf4f3c a0fafe17 88542cb1 23a33939 2a6c7605 f2c295f2 7a96b943 5935807a 7359f67f 3d80477d 4716fe3e 1e237e44 6d7a883b ef44a541 a8525b7f b671253b db0bad00 d4d1c6f8 7c839d87 caf2b8bc 11f915bc 6d88a37a 110b3efd dbf98641 ca0093fd 4e54f70e 5f5fc9f3 84a64fb2 4ea6dc4f ead27321 b58dbad2 312bf560 7f8d292f ac7766f3 19fadc21 28d12941 575c006e d014f9a8 c9ee2589 e13f0cc8 b6630ca6