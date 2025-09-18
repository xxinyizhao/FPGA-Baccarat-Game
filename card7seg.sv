//Defining constants for the seven segment display 7-bit binary codes:
`define display_blank 7'b1111111
`define display_ace 7'b0001000
`define display_2 7'b0100100
`define display_3 7'b0110000
`define display_4 7'b0011001
`define display_5 7'b0010010
`define display_6 7'b0000010
`define display_7 7'b1111000
`define display_8 7'b0000000
`define display_9 7'b0010000
`define display_10 7'b1000000
`define display_jack 7'b1100001
`define display_queen 7'b0011000
`define display_king 7'b0001001

module card7seg(input logic [3:0] card, output logic [6:0] seg7);

	always_comb begin
      case(card[3:0])
      4'b0001: seg7 = `display_ace;
      4'b0010: seg7 = `display_2;
      4'b0011: seg7 = `display_3;
      4'b0100: seg7 = `display_4;
      4'b0101: seg7 = `display_5;
      4'b0110: seg7 = `display_6;
      4'b0111: seg7 = `display_7;
      4'b1000: seg7 = `display_8;
      4'b1001: seg7 = `display_9;
      4'b1010: seg7 = `display_10;
      4'b1011: seg7 = `display_jack;
      4'b1100: seg7 = `display_queen;
      4'b1101: seg7 = `display_king;

      default: seg7 = `display_blank;
      endcase
   end

endmodule

