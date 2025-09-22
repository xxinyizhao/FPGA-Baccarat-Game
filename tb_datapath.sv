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

module tb_datapath();

// declare variables:
logic slow_clock, fast_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3, err;
logic [3:0] pcard_out, pscore_out, dscore_out;
logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

// instantiate datapath:
datapath DUT(.slow_clock(slow_clock), .fast_clock(fast_clock), .resetb(resetb), .load_pcard1(load_pcard1), .load_pcard2(load_pcard2), 
.load_pcard3(load_pcard3),.load_dcard1(load_dcard1), .load_dcard2(load_dcard2), .load_dcard3(load_dcard3), .pcard3_out(pcard3_out), 
.pscore_out(pscore_out), .dscore_out(dscore_out), .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0));

// checking if registers have been loaded correctly
task checkreg;
    begin
        if (load_pcard1 && (DUT.pcard1 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading pcard1 - expected: %b, actual: %b", DUT.pcard1, DUT.new_card);
        end else if (load_pcard2 && (DUT.pcard2 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading pcard2 - expected: %b, actual: %b", DUT.pcard2, DUT.new_card);
        end else if (load_pcard3 && (DUT.pcard3 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading pcard3 - expected: %b, actual: %b", DUT.pcard3, DUT.new_card);
        end else if (load_dcard1 && (DUT.dcard1 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading dcard1 - expected: %b, actual: %b", DUT.dcard1, DUT.new_card);
        end else if (load_dcard2 && (DUT.dcard2 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading dcard2 - expected: %b, actual: %b", DUT.dcard2, DUT.new_card);
        end else if (load_dcard3 && (DUT.dcard3 != DUT.new_card)) begin
            err = 1'b1;
            $display("Error loading dcard3 - expected: %b, actual: %b", DUT.dcard3, DUT.new_card);
        end 
    end
endtask

// checking if HEX values have been displayed correctly from card7seg module
task checkhex;
    input [6:0] HEX;
    input [3:0] card;
    begin
        case(card)
            4'b0001: if (HEX != `display_ace) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_ace, HEX);
            end
            4'b0010: if (HEX != `display_2) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_2, HEX);
            end
            4'b0011: if (HEX != `display_3) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_3, HEX);
            end
            4'b0100: if (HEX != `display_4) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_4, HEX);
            end
            4'b0101: if (HEX != `display_5) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_5, HEX);
            end
            4'b0110: if (HEX != `display_6) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_6, HEX);
            end
            4'b0111: if (HEX != `display_7) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_7, HEX);
            end
            4'b1000: if (HEX != `display_8) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_8, HEX);
            end
            4'b1001: if (HEX != `display_9) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_9, HEX);
            end
            4'b1010: if (HEX != `display_10) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_10, HEX);
            end
            4'b1011: if (HEX != `display_jack) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_jack, HEX);
            end
            4'b1100: if (HEX != `display_queen) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_queen, HEX);
            end
            4'b1101: if (HEX != `display_king) begin
                err = 1'b1;
                $display("Error with HEX display - expected: %b, actual: %b", `display_king, HEX);
            end

            default: if (HEX != `display_blank) begin
                err = 1'b1;
                $display("Error with HEX display - expected %b, actual: %b", `display_blank, HEX);
            end
        endcase
    end
endtask

// generate slow_clock input:
initial begin
    slow_clock = 1'b0; #5;
    forever begin
        slow_clock = 1'b1; #5;
        slow_clock = 1'b0; #5;
    end
end

// generate fast_clock input:
initial begin
    fast_clock = 1'b0; #1;
    forever begin
        fast_clock = 1'b1; #1;
        fast_clock = 1'b0; #1;
    end
end

// test various test cases:
initial begin
    // initialize every variable to zero:
    err = 1'b0;
    resetb = 1'b0; // active-low
    load_pcard1 = 1'b0;
    load_pcard2 = 1'b0;
    load_pcard3 = 1'b0;
    load_dcard1 = 1'b0;
    load_dcard2 = 1'b0;
    load_dcard3 = 1'b0;

    // turn off reset:
    #10; resetb = 1'b1;

    // loading card values -- value of new_card should still be "random" based on the dealcard module
    load_pcard1 = 1'b1; #10;
    load_pcard1 = 1'b0; 
    checkreg;
    checkhex(HEX0, DUT.pcard1);


    load_pcard2 = 1'b1; #10;
    load_pcard2 = 1'b0; 
    checkreg;
    checkhex(HEX1, DUT.pcard2);

    load_pcard3 = 1'b1; #10;
    load_pcard3 = 1'b0; 
    checkreg;
    checkhex(HEX2, DUT.pcard3);

    load_dcard1 = 1'b1; #10;
    load_dcard1 = 1'b0;
    checkreg;
    checkhex(HEX3, DUT.dcard1);

    load_dcard2 = 1'b1; #10;
    load_dcard2 = 1'b0; 
    checkreg;
    checkhex(HEX4, DUT.dcard2);

    load_dcard3 = 1'b1; #10;
    load_dcard3 = 1'b0; 
    checkreg;
    checkhex(HEX5, DUT.dcard3);
    
    #10;

    // check err signal:
    if (~err)
        $display("All tests passed!");
    else   
        $display("Tests failed.");
end

endmodule