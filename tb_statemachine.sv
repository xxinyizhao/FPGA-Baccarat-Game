module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

// FSM inputs
  reg slow_clock;                 
  reg resetb;                     
  reg [3:0] dscore, pscore, pcard3; 

  // FSM outputs
  wire load_pcard1, load_pcard2, load_pcard3;
  wire load_dcard1, load_dcard2, load_dcard3;
  wire player_win_light, dealer_win_light;

  // Instantiate FSM
  statemachine dut(
    .slow_clock(slow_clock), .resetb(resetb),
    .dscore(dscore), .pscore(pscore), .pcard3(pcard3),
    .load_pcard1(load_pcard1), .load_pcard2(load_pcard2), .load_pcard3(load_pcard3),
    .load_dcard1(load_dcard1), .load_dcard2(load_dcard2), .load_dcard3(load_dcard3),
    .player_win_light(player_win_light), .dealer_win_light(dealer_win_light)
  );

  //States
  localparam Sa=4'b0000, Sb=4'b0001, Sc=4'b0010, Sd=4'b0011,
             Se=4'b0100, Sf=4'b0101, Sg=4'b0110, Sh=4'b0111;

  //Error flag
  reg err;

  // Clock generation: 10 ns period
  initial slow_clock = 1'b0;
  always #10 slow_clock = ~slow_clock;

  //tasks to check the state transitions and the outputs seperately

  task check_state;
    input [3:0] expected_state;
    input [255:0] tag; // this alllows us to know which state transition did not work
    begin
      if (dut.present_state !== expected_state) begin
        $display("ERROR: state got=%b exp=%b @%0t  %s",
                 dut.present_state, expected_state, $time, tag);
        err = 1;
      end
    end
  endtask

  task check_outputs;
    input lp1, lp2, lp3, ld1, ld2, ld3, pl, dl;
    input [255:0] tag;
    begin
      if ({load_pcard1,load_pcard2,load_pcard3,load_dcard1,load_dcard2,load_dcard3,player_win_light,dealer_win_light} !==
          {lp1,lp2,lp3,ld1,ld2,ld3,pl,dl}) begin
        $display("ERROR: outputs mismatch @%0t %s", $time, tag);
        $display(" got lp1=%0b lp2=%0b lp3=%0b ld1=%0b ld2=%0b ld3=%0b pl=%0b dl=%0b",
                  load_pcard1,load_pcard2,load_pcard3,load_dcard1,load_dcard2,load_dcard3,player_win_light,dealer_win_light);
        $display(" exp lp1=%0b lp2=%0b lp3=%0b ld1=%0b ld2=%0b ld3=%0b pl=%0b dl=%0b",
                  lp1,lp2,lp3,ld1,ld2,ld3,pl,dl);
        err = 1;
      end
    end
  endtask

   //reset is active low 0=high 1=low 

   //task for reaching Se and Sf quicker so we test all the if conditions

    task reach_Se; // reset, then walk Sa->Sb->Sc->Sd->Se and check outputs on each
    begin
        // apply reset
        resetb = 1'b0; dscore = 0; pscore = 0; pcard3 = 0;
        @(posedge slow_clock); #5;
        check_state(Sa,"reset -> Sa");
        check_outputs(0,0,0,0,0,0,0,0,"Sa outputs");

        // release reset and step to Sb..Se
        resetb = 1'b1;

        @(posedge slow_clock); #5; // Sb
        check_state(Sb,"Sa->Sb");
        check_outputs(1,0,0,0,0,0,0,0,"Sb: load_pcard1=1");

        @(posedge slow_clock); #5; // Sc
        check_state(Sc,"Sb->Sc");
        check_outputs(0,0,0,1,0,0,0,0,"Sc: load_dcard1=1");

        @(posedge slow_clock); #5; // Sd
        check_state(Sd,"Sc->Sd");
        check_outputs(0,1,0,0,0,0,0,0,"Sd: load_pcard2=1");

        @(posedge slow_clock); #5; // Se
        check_state(Se,"Sd->Se");
        check_outputs(0,0,0,0,1,0,0,0,"Se: load_dcard2=1");
    end
    endtask

    task force_Sf; // assumes we are in Se; set player 0..5 and dealer not 8/9
    begin
        pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd0;
        @(posedge slow_clock); #10; // Se -> Sf
        check_state(Sf,"Se -> Sf (player<=5)");
        check_outputs(0,0,1,0,0,0,0,0,"Sf: load_pcard3=1");
    end
    endtask  

    /* MAIN TEST!!!!THE OTHER STATES ARE ALWAYS CHECKED WHEN WE FORCE SE TO BE REACHED FASTER(SE HAS ALL IFs)*/

    // dealer 8 -> Sh
    pscore=4'd5; dscore=4'd8; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sh,"Se d=8 -> Sh");
    // Lights depend on scores; here dealer > player, so dealer light on.
    check_outputs(0,0,0,0,0,0,0,1,"Sh lights (dealer win)");

    // back to Se
    reach_Se();

    // dealer 9 -> Sh
    pscore=4'd0; dscore=4'd9; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sh,"Se d=9 -> Sh");

    // back to Se
    reach_Se();

    // player 8 -> Sh
    pscore=4'd8; dscore=4'd4; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sh,"Se p=8 -> Sh");
    // tie example: set equal scores, both lights on
    pscore=4'd8; dscore=4'd8; pcard3=0;
    check_outputs(0,0,0,0,0,0,1,1,"Sh lights (tie)");

    // back to Se
    reach_Se();

    // player 9 -> Sh
    pscore=4'd9; dscore=4'd4; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sh,"Se p=9 -> Sh");

    // back to Se
    reach_Se();

    // player 0..5 -> Sf
    pscore=4'd0; dscore=4'd4; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sf,"Se p in 0..5 -> Sf");
    check_outputs(0,0,1,0,0,0,0,0,"Sf: load_pcard3=1");

    // back to Se
    reach_Se();

    // player 6/7 and dealer <=5 -> Sg
    pscore=4'd6; dscore=4'd5; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sg,"Se p=6 d<=5 -> Sg");
    check_outputs(0,0,0,0,0,1,0,0,"Sg: load_dcard3=1");
    // Sg -> Sh
    @(posedge slow_clock); #5;
    check_state(Sh,"Sg -> Sh");

    // back to Se
    reach_Se();

    // player 6/7 and dealer >=6 -> Sh
    pscore=4'd7; dscore=4'd6; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Sh,"Se p=7 d>=6 -> Sh");

    // back to Se
    reach_Se();

    // default stay Se (use pscore out of normal range to hit default)
    pscore=4'd10; dscore=4'd4; pcard3=0;
    @(posedge slow_clock); #5;
    check_state(Se,"Se default stay Se");

endmodule
