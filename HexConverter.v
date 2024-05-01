module HexConverter (in, converted);
	input [3:0] in;
	output reg [6:0] converted;
    always @(*)
        begin
	       case(in)
            4'h0: converted[6:0] = 7'b0111111;
            4'h1: converted[6:0] = 7'b0000110;
            4'h2: converted[6:0] = 7'b1011011;
            4'h3: converted[6:0] = 7'b1001111;
            4'h4: converted[6:0] = 7'b1100110;
            4'h5: converted[6:0] = 7'b1101101;
            4'h6: converted[6:0] = 7'b1111101;
            4'h7: converted[6:0] = 7'b0000111;
            4'h8: converted[6:0] = 7'b1111111;
            4'h9: converted[6:0] = 7'b1101111;
            4'hA: converted[6:0] = 7'b1110111;
            4'hB: converted[6:0] = 7'b1111100;
            4'hC: converted[6:0] = 7'b1011000;
            4'hD: converted[6:0] = 7'b1011110;
            4'hE: converted[6:0] = 7'b1111001;
            default : converted[6:0] = 7'b1110001;
           endcase
        end
endmodule