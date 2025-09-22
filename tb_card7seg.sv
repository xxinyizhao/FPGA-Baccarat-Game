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

module tb_card7seg();
// declare variables
logic err;
logic [3:0] card;
logic [6:0] seg7;

// instantiate card7seg
card7seg DUT(.card(card), .seg7(seg7));

// check hex outputs:
task check;
    begin
        case(card)
        4'b0001: if (seg7 != `display_ace) begin
            err = 1'b1;
            $display("Error - display_ace");
        end
        4'b0010: if (seg7 != `display_2) begin
            err = 1'b1;
            $display("Error - display_2");
        end
        4'b0011: if (seg7 != `display_3) begin
            err = 1'b1;
            $display("Error - display_3");
        end
        4'b0100: if (seg7 != `display_4) begin
            err = 1'b1;
            $display("Error - display_4");
        end
        4'b0101: if (seg7 != `display_5) begin
            err = 1'b1;
            $display("Error - display_5");
        end
        4'b0110: if (seg7 != `display_6) begin
            err = 1'b1;
            $display("Error - display_6");
        end
        4'b0111: if(seg7 != `display_7) begin
            err = 1'b1;
            $display("Error - display_7");
        end
        4'b1000: if (seg7 != `display_8) begin
            err = 1'b1;
            $display("Error - display_8");
        end
        4'b1001: if (seg7 != `display_9) begin
            err = 1'b1;
            $display("Error - display_9");
        end
        4'b1010: if (seg7 != `display_10) begin
            err = 1'b1;
            $display("Error - display_10");
        end
        4'b1011: if (seg7 != `display_jack) begin
            err = 1'b1;
            $display("Error - display_jack");
        end
        4'b1100: if (seg7 != `display_queen) begin
            err = 1'b1;
            $display("Error - display_queen");
        end
        4'b1101: if (seg7 != `display_king) begin
            err = 1'b1;
            $display("Error - display_king");
        end
        default: if (seg7 != `display_blank) begin
            err = 1'b1;
            $display("Error - display_blank");
        end
        endcase
    end
endtask
	
initial begin
    // intiialize inputs:
    err = 1'b0;
    card = 4'b0000;

    // test all possible cases
    card = 4'b0001;
    check();

    card = 4'b0010;
    check();

    card = 4'b0011;
    check();

    card = 4'b0100;
    check();

    card = 4'b0101;
    check();
    
    card = 4'b0110;
    check();

    card = 4'b0111;
    check();

    card = 4'b1000;
    check();
    
    card = 4'b1001;
    check();

    card = 4'b1010;
    check();
    
    card = 4'b1011;
    check();

    card = 4'b1100;
    check();

    card = 4'b1101;
    check();

    card = 4'b1110;
    check();

    card = 4'b1111;
    check();

    // check err signal:
    if (~err)
        $display("All tests passed!");
    else   
        $display("Tests failed.");

end
endmodule