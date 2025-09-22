module tb_scorehand();
// declare variables:
logic [3:0] card1, card2, card3, total;
logic err;

// instantiate scorehand:
scorehand DUT(.card1(card1), .card2(card2), .card3(card3), .total(total));

task checkscorehand;
    input [3:0] carda, cardb, cardc; // correlates to card1, card2, card3 respectively
    begin
        logic [3:0] expected_val1, expected_val2, expected_val3;
        expected_val1 = (carda == 4'b1011 || carda == 4'b1100 || carda == 4'b1101 || carda == 4'b1110 || carda == 4'b1111) ? 4'b0000 : carda;
        expected_val2 = (cardb == 4'b1011 || cardb == 4'b1100 || cardb == 4'b1101 || cardb == 4'b1110 || cardb == 4'b1111) ? 4'b0000 : cardb;
        expected_val3 = (cardc == 4'b1011 || cardc == 4'b1100 || cardc == 4'b1101 || cardc == 4'b1110 || cardc == 4'b1111) ? 4'b0000 : cardc;

        if(DUT.val1 != expected_val1) begin
                    err = 1'b1;
                    $display("Card1 ErrorB - card1 has a value of %b, but val1 has a value of %b", carda, DUT.val1);
        end

        if(DUT.val2 != expected_val2) begin
                    err = 1'b1;
                    $display("Card2 ErrorB - card2 has a value of %b, but val2 has a value of %b", cardb, DUT.val2);
        end

        if(DUT.val3 != expected_val3) begin
                    err = 1'b1;
                    $display("Card3 ErrorB - card3 has a value of %b, but val3 has a value of %b", cardc, DUT.val3);
        end
        /*
        // checking if each card value is correct:
        case(carda)
            4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111:
                if (DUT.val1 != 4'b0000) begin
                    err = 1'b1;
                    $display("Card1 ErrorA - card1 has a value of %b, but val1 has a value of %b instead of 0", carda, DUT.val1);
                end
            default:
                if(DUT.val1 != carda) begin
                    err = 1'b1;
                    $display("Card1 ErrorB - card1 has a value of %b, but val1 has a value of %b", carda, DUT.val1);
                end
        endcase

        case(cardb)
            4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111:
                if (DUT.val2 != 4'b0000) begin
                    err = 1'b1;
                    $display("Card2 ErrorA - card2 has a value of %b, but val2 has a value of %b instead of 0", cardb, DUT.val2);
                end
            default:
                if(DUT.val2 != cardb) begin
                    err = 1'b1;
                    $display("Card2 ErrorB - card2 has a value of %b, but val2 has a value of %b", cardb, DUT.val2);
                end
        endcase

        case(cardc)
            4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111:
                if (DUT.val3 != 4'b0000) begin
                    err = 1'b1;
                    $display("Card3 ErrorA - card3 has a value of %b, but val3 has a value of %b instead of 0", cardc, DUT.val3);
                end 
            default:
                if(DUT.val3 != cardc) begin
                    err = 1'b1;
                    $display("Card3 ErrorB - card3 has a value of %b, but val3 has a value of %b", cardc, DUT.val3);
                end
        endcase
        */

        // checking total score calculation
        if (((expected_val1 + expected_val2 + expected_val3) % 10) !== total) begin
            err = 1'b1;
            $display("Calculation Error - Expected: %b, Actual: %b", ((expected_val1 + expected_val2 + expected_val3) % 10), total);
        end
        
    end
endtask
  
// testing different inputs
initial begin

    // initialize err = 0 (no errors detected right now):
    err = 1'b0; 
    #5; // wait 5 ticks

    // initalize inputs and test when all inputs are 0 and test:
    card1 = 4'b0000;
    card2 = 4'b0000;
    card3 = 4'b0000; #5;
    checkscorehand(card1, card2, card3); 
    #5;

    // test when card1, card2, and card3 draws a jack, king, and queen:
    card1 = 4'b1011;
    card2 = 4'b1100;
    card3 = 4'b1101; #5;
    checkscorehand(card1, card2, card3);
    #5;

    // test when card1, card2, and card 3 all draw numerical values:
    card1 = 4'b0001;
    card2 = 4'b0010;
    card3 = 4'b0011; #5;
    checkscorehand(card1, card2, card3);
    #5;

    // test when a mix of special cards and numerical vards:
    card1 = 4'b0100;
    card2 = 4'b1011;
    card3 = 4'b0001; #5;
    checkscorehand(card1, card2, card3);
    #5;

    // checking error value
   if (~err)
        $display("All tests passed!");
    else   
        $display("Tests failed.");

end
endmodule