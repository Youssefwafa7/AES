module Cipher(input in[127 : 0] ,input w[1407 : 0] , output out[127 : 0] );
    wire [127 : 0] state = in;
    wire out1[127 : 0];
    AddRoundKey k1 (state, w[1407 : 1280], out1);

    genvar i;
    generate
        for( i = 1 ; i <= 9 ; i = i + 1 ) begin
            wire sub [127 : 0];
            wire shift [127 : 0];
            wire mix [127 : 0];
            wire out2 [127 : 0];
            SubBytes s1 (out1 , sub);
            ShiftRows r1 (sub , shift);
            MixColumns c1(shift , mix);
            AddRoundKey k1 (mix, w[1407 - i*128 : 1407 - (i+1)*128 + 1], out2);
        end
    endgenerate
    wire sub2 [127 : 0]; 
    wire shift2 [127 : 0];
    wire out3 [127 : 0];
    SubBytes s2 (out2 , sub2);
    ShiftRows r2 (sub , shift2);
    AddRoundKey k2 (mix, w[1407 - i*128 : 1407 - (i+1)*128 + 1], out3);
    assign out = out3;

endmodule