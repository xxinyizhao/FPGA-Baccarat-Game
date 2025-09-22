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

module tb_task5();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 100,000 ticks (equivalent to "initial #100000 $finish();").

// declare variables:
logic CLOCK_50, err;
logic [3:0] KEY, expected_card;
logic [9:0] LEDR;
logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

// instantiate task5:
task5 DUT(.CLOCK_50(CLOCK_50), .KEY(KEY), .LEDR(LEDR), .HEX5(HEX5), .HEX4(HEX4), 
.HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0));


// checking LED outputs before winners are declared:
task checkled;
    input [9:0] expected_led; // expected LED output

    if (expected_led != {DUT.sm.dealer_win_light, DUT.sm.player_win_light, DUT.dp.dscore_out, DUT.dp.pscore_out}) begin
        err = 1'b1;
        $display("LED error - expected: %b, actual: %b", expected_led, {DUT.sm.dealer_win_light, DUT.sm.player_win_light, DUT.dp.dscore_out, DUT.dp.pscore_out});
    end

endtask
// checking HEX outputs:
task checkhex;
    input [6:0] h5, h4, h3, h2, h1, h0; // expected hex values
    if (HEX5 != h5) begin
        err = 1'b1;
        $display("HEX5 error - expected: %b, actual: %b", h5, HEX5);
    end
    if (HEX4 != h4) begin
        err = 1'b1;
        $display("HEX4 error - expected: %b, actual: %b", h4, HEX4);
    end
    if (HEX3 != h3) begin
        err = 1'b1;
        $display("HEX3 error - expected: %b, actual: %b", h3, HEX3);
    end
    if (HEX2 != h2) begin
        err = 1'b1;
        $display("HEX2 error - expected: %b, actual: %b", h2, HEX2);
    end
    if (HEX1 != h1) begin
        err = 1'b1;
        $display("HEX1 error - expected: %b, actual: %b", h1, HEX1);
    end
    if (HEX0 != h0) begin
        err = 1'b1;
        $display("HEX0 error - expected: %b, actual: %b", h0, HEX0);
    end
endtask

// generate CLOCK_50 signal:
initial begin
    CLOCK_50 = 1'b0; #1;
    forever begin
        CLOCK_50 = 1'b1; #1;
        CLOCK_50 = 1'b0; #1;
    end
end

// test by simulating one round of baccarat and checking if the HEX and LED outputs are correct
initial begin
    // initialize inputs
    err = 1'b0;
    KEY = 4'b1111; #2; // all KEY buttons are active-low
    //$display("starting new_clock value: %b", DUT.dp.DEAL.new_card);
    
    // reset to state A:
    KEY[3] = 1'b0; #2; // turn on reset
    KEY[0] = 1'b0; #2; // resetb is active-low
    KEY[0] = 1'b1; #2; // KEY[3] = resetb
    KEY[3] = 1'b1; #26; // now new_card = 1 (since new_card resets to 1 after 13 ticks or reset)

    $display("starting new_card value: %b", DUT.dp.DEAL.new_card); // for debugging purposes - 0001
    
    // set pcard1 = 1 and load to register
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #28;
    // should be in state A
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0010
    // check outputs: -- note that outputs are correlating to next_state in the statemachine as 
    // to remove the need for an extra waiting state in the beginning, so the outputs below would be for "state B"
    checkled(10'b00_0000_0001);
    checkhex(`display_blank, `display_blank, `display_blank, `display_blank, `display_blank, `display_ace);

    // set dcard1 = 2 and load
    KEY[0] = 1'b0; #26; // wait one cycle
    KEY[0] = 1'b1; #28; // one increment in new_card = 1 period of CLOCK_50 = 2
    // should be in state B
    $display("dcard1: %b", DUT.dp.D_SCORE.card1); 
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0011
    // check outputs:
    checkled(10'b00_0010_0001);
    checkhex(`display_blank, `display_blank, `display_2, `display_blank, `display_blank, `display_ace);

    // set pcard2 = 3; pscore = 1+3 = 4
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #28;
    // should be in state C
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0100
    // check outputs:
    checkled(10'b00_0010_0100);
    checkhex(`display_blank, `display_blank, `display_2, `display_blank, `display_3, `display_ace);

    // set dcard2 = 4; dscore = 2+4 = 6
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #28;
    // should be in state D
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0101
    //$display("dcard2: %b", DUT.dp.D_SCORE.card2);
    // check outputs:
    checkled(10'b00_0110_0100);
    checkhex(`display_blank, `display_4, `display_2, `display_blank, `display_3, `display_ace);

    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b0; #26;
    // should be in state E - decide that player draws card3
    // check outputs:
    checkled(10'b00_0110_0100);
    checkhex(`display_blank, `display_4, `display_2, `display_blank, `display_3, `display_ace);

    // set pcard3 = 6; pscore = (4+6)mod10 = 0
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #28;
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0110   
    // should be in state I
    // check outputs:
    checkled(10'b00_0110_0100); // actually 10'b00-0110-0100
    checkhex(`display_blank, `display_4, `display_2, `display_blank, `display_3, `display_ace);

    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b0; #26;
    // should be in state F - decide that dealer gets a third card
    // check outputs:
    checkled(10'b00_0110_0100); // actually 10'b00-0110-0100
    checkhex(`display_blank, `display_4, `display_2, `display_blank, `display_3, `display_ace);

    // set dcard3 = 6; dscore = (6+6)mod10 = 2
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #26;
    // should be in state J
    // check outputs:
    checkled(10'b00_0110_0000); 
    checkhex(`display_blank, `display_4, `display_2, `display_6, `display_3, `display_ace);

    // should be in state G
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #26;
    $display("new_card value: %b", DUT.dp.DEAL.new_card); // 0110
    // check outputs:
    checkled(10'b00_0110_0000);
    checkhex(`display_blank, `display_4, `display_2, `display_6, `display_3, `display_ace);

    // should be in state H
    // since 2>0, dealer wins
    KEY[0] = 1'b0; #26;
    KEY[0] = 1'b1; #26;
    $display("new_card value: %b", DUT.dp.DEAL.new_card); 
    // check outputs:
    checkled(10'b10_0010_0000);
    checkhex(`display_6, `display_4, `display_2, `display_6, `display_3, `display_ace);

    // checking error value
    if (~err)
        $display("All tests passed!");
    else   
        $display("Tests failed.");

end
endmodule
