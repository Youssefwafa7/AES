module HexConverter (in, converted);
	input [3:0] in;
	output reg [6:0] converted;
    always @(*)
        begin
	       case(in)
            4'h0: converted[6:0] = 7'b1000000;
            4'h1: converted[6:0] = 7'b1111001;
            4'h2: converted[6:0] = 7'b0100100;
            4'h3: converted[6:0] = 7'b0110000;
            4'h4: converted[6:0] = 7'b0011001;
            4'h5: converted[6:0] = 7'b0010010;
            4'h6: converted[6:0] = 7'b0000010;
            4'h7: converted[6:0] = 7'b1111000;
            4'h8: converted[6:0] = 7'b0000000;
            4'h9: converted[6:0] = 7'b0010000;
            4'hA: converted[6:0] = 7'b0001000;
            4'hB: converted[6:0] = 7'b0000011;
            4'hC: converted[6:0] = 7'b0100111;
            4'hD: converted[6:0] = 7'b0100001;
            4'hE: converted[6:0] = 7'b0000110;
            default : converted[6:0] = 7'b0001110;
           endcase
        end
endmodule