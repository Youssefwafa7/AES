module shift_add(input [0:3] in, output reg [0:3]out);
     always @(*) begin
    if (in >= 4'b0101) out = in + 4'b0011; // Add 3 if input is 5 or greater
     else out = in;
     end
endmodule



module binarytoBCD(input [0:7] in, output [0:11] out);
wire [0:3]A,B,C,D,E,F,G;

shift_add A1({1'b0, in[0:2]},A);
shift_add B1({A[1:3],in[3]},B);
shift_add C1 ({B[1:3],in[4]},C);
shift_add D1({C[1:3],in[5]},D);
shift_add E1({D[1:3],in[6]},E);
shift_add F1({1'b0,A[0],B[0],C[0]},F);
shift_add G1({F[1:3],D[0]},G);

assign out[11] = in[7];
assign out[10] = E[3];
assign out[9] = E[2];
assign out[8] = E[1];
assign out[7] = E[0];
assign out[6] = G[3];
assign out[5] = G[2];
assign out[4] = G[1];
assign out[3] = G[0];
assign out[2] = F[0];
assign out[1] = 1'b0;
assign out[0] = 1'b0;

endmodule