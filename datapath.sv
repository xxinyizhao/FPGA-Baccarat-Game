module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);


// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
// Follow the block diagram in the Lab 1 handout closely as you write this code.

// in the brackets our signals in main module i am working on 


// internal signals:
logic [3:0] new_card, pcard1, pcard2, pcard3, dcard1, dcard2, dcard3;
logic [3:0] next_pcard1, next_pcard2, next_pcard3, next_dcard1, next_dcard2, next_dcard3;

// assign pcard3 value:
assign pcard3_out = pcard3;

// Instantiate dealcard
dealcard DEAL(
  .clock(fast_clock),
  .resetb(resetb),
  .new_card(new_card)
);

// Instantiate scorehand for player and dealer
scorehand P_SCORE (
  .card1(pcard1),
  .card2(pcard2),
  .card3(pcard3),
  .total(pscore_out)
);

scorehand D_SCORE (
  .card1(dcard1),
  .card2(dcard2),
  .card3(dcard3),
  .total(dscore_out)
);

// Instantiate card7 seg for player and dealer cards 1, 2, 3
card7seg D3 (.card(dcard3), .seg7(HEX5));
card7seg D2 (.card(dcard2), .seg7(HEX4));
card7seg D1 (.card(dcard1), .seg7(HEX3));

card7seg P3 (.card(pcard3), .seg7(HEX2));
card7seg P2 (.card(pcard2), .seg7(HEX1));
card7seg P1 (.card(pcard1), .seg7(HEX0));

// flip flop enables:
assign next_pcard1 = load_pcard1 ? new_card : pcard1;
assign next_pcard2 = load_pcard2 ? new_card : pcard2;
assign next_pcard3 = load_pcard3 ? new_card : pcard3;
assign next_dcard1 = load_dcard1 ? new_card : dcard1;
assign next_dcard2 = load_dcard2 ? new_card : dcard2;
assign next_dcard3 = load_dcard3 ? new_card : dcard3;

// flip flop clock registers:
always_ff @(posedge slow_clock) begin
    if (~resetb) begin
        pcard1 <= 4'b0;
        pcard2 <= 4'b0;
        pcard3 <= 4'b0;
        dcard1 <= 4'b0;
        dcard2 <= 4'b0;
        dcard3 <= 4'b0;
    end else begin
        pcard1 <= next_pcard1;
        pcard2 <= next_pcard2;
        pcard3 <= next_pcard3;
        dcard1 <= next_dcard1;
        dcard2 <= next_dcard2;
        dcard3 <= next_dcard3;
    end
end


endmodule