module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

logic [3:0] val1, val2, val3;

always_comb begin
    case(card1[3:0])
    4'b1011, 4'b1100, 4'b1101: val1 = 4'b0000;
    default: val1 = card1;
    endcase

    case(card2[3:0])
    4'b1011, 4'b1100, 4'b1101: val2 = 4'b0000;
    default: val2 = card2;
    endcase

    case(card3[3:0])
    4'b1011, 4'b1100, 4'b1101: val3 = 4'b0000;
    default: val3 = card3;
    endcase

    total = (val1+val2+val3)%10;

end

endmodule

