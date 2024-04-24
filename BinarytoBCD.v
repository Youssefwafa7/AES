module shift_add(input [0:3] in, output [0:3]out);
     if(in >= 5)   out = in + 3;
     else out = in;
endmodule;



module binarytoBCD(input [0:7] in, output [0:11] out);
wire [0:3]A,B,C,D,E,F,G;

shift_add({in[5:7], 1'b0},A);
shift_add({in[4],A[0:2]},B);
shift_add({in[3],B[0:2]},C);
shift_add({in[2],C[0:2]},D);
shift_add({in[1],D[0:2]},E);
shift_add({1'b0,A[3],B[3],C[3]},F);
shift_add({D[3],F[0:2]},G);

out[0] = A[0];
out[1] = E[0];
out[2] = E[1];
out[3] = E[2];
out[4] = E[3];
out[5] = G[0];
out[6] = G[1];
out[7] = G[2];
out[8] = G[3];
out[9] = F[3];
out[10] = 1'b0;
out[11] = 1'b0;

endmodule