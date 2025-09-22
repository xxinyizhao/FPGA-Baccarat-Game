`timescale 1ns/1ns

module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

// FSM inputs
  reg slow_clock;                 
  reg resetb;                     
  reg [3:0] dscore, pscore, pcard3; 
 //Error flag
  reg err;


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

 localparam Sa=4'b0000, Sb=4'b0001, Sc=4'b0010, Sd=4'b0011,
           Se=4'b0100, Sf=4'b0101, Sg=4'b0110, Sh=4'b0111,
           Si = 4'b1000, // decision state after Se
           Sj = 4'b1001; // decision state after Sj
 

  // ---------------- TASKS TO CHECK STATES AND OUTPUTS ----------------//
  task check_state;
    input [3:0] expected_state;
   
    begin
      if (dut.next_state !== expected_state) begin
        $display("ERROR: state result=%b expected=%b",
                 dut.present_state, expected_state);
        err = 1;
      end
	//else err = 0;
    end
  endtask

  task check_outputs;
    input lp1, lp2, lp3, ld1, ld2, ld3, pl, dl;
    

    begin
      if ({load_pcard1,load_pcard2,load_pcard3,load_dcard1,load_dcard2,load_dcard3,player_win_light,dealer_win_light} !==
          {lp1,lp2,lp3,ld1,ld2,ld3,pl,dl}) begin
        $display("ERROR: outputs mismatch!");
        $display(" result lp1=%0b lp2=%0b lp3=%0b ld1=%0b ld2=%0b ld3=%0b pl=%0b dl=%0b",
                  load_pcard1,load_pcard2,load_pcard3,load_dcard1,load_dcard2,load_dcard3,player_win_light,dealer_win_light);
        $display(" expected lp1=%0b lp2=%0b lp3=%0b ld1=%0b ld2=%0b ld3=%0b pl=%0b dl=%0b",
                  lp1,lp2,lp3,ld1,ld2,ld3,pl,dl);
        err = 1;
      end
	//else err = 0;
    end
  endtask

  task reach_state_Si;

  begin
    err = 1'b0;
    @(posedge slow_clock);resetb = 1'b0; // Reset high
   
  //initialize scores
    dscore = 0; pscore = 0; pcard3=0;
    //#10;
    //@(posedge slow_clock); 
    check_state(Sa);
    check_outputs(0,0,0,0,0,0,0,0);
   
    #10;
    resetb = 1'b1; //go low

    @(posedge slow_clock); // Sb load player1 card
    check_state(Sb);
    check_outputs(1,0,0,0,0,0,0,0);

    @(posedge slow_clock);  // Sc load dealer1 card
    check_state(Sc);
    check_outputs(0,0,0,1,0,0,0,0);

    @(posedge slow_clock);  // Sd load player2 card
    check_state(Sd);
    check_outputs(0,1,0,0,0,0,0,0);

    @(posedge slow_clock);   // Se load dealer 2 card
    check_state(Se);
    check_outputs(0,0,0,0,1,0,0,0);

    //Si(to check all the if conditions)
    @(posedge slow_clock);   // Se -> Si
    check_state(Si);
    check_outputs(0,0,0,0,0,0,0,0);

   end
  endtask

task reach_Si_quick;
  	begin
  	resetb = 1'b0;
  	@(posedge slow_clock); // Sa
        dscore = 0; pscore = 0; pcard3 = 0;
  	resetb = 1'b1;
  	@(posedge slow_clock); // Sb
  	@(posedge slow_clock); // Sc
  	@(posedge slow_clock); // Sd
  	@(posedge slow_clock); // Se
  	@(posedge slow_clock); // Si
	end
endtask
  

  initial slow_clock = 1'b0;
  always  #5 slow_clock = ~slow_clock;

  //start tests//
 
  initial begin

      reach_state_Si;

//Check if we go to gameover state if pscore or dscore is 9 and check that player or winner lights are on
      pscore = 4'd9; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,1,0);

//check for a 8 for player     
      reach_Si_quick;

      pscore = 4'd8; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,1,0);
//check for a 9 for dealer      
      reach_Si_quick;

      pscore = 4'd2; dscore = 4'd9;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,0,1);
//check for a 8 for dealer      
      reach_Si_quick;

      pscore = 4'd2; dscore = 4'd8;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,0,1);
//check for a tie
      reach_Si_quick;

      pscore = 4'd9; dscore = 4'd9;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,1,1);

//check when pscore 
      reach_Si_quick;

      pscore = 4'd2; dscore = 4'd9;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,0,1);

//check if player gets third card (0-5 case)    
      reach_Si_quick;

      pscore = 4'd0; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      reach_Si_quick;

      pscore = 4'd1; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      reach_Si_quick;

      pscore = 4'd2; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

      reach_Si_quick;

      pscore = 4'd3; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

      reach_Si_quick;

      pscore = 4'd4; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

//check if player does not get third card

      reach_Si_quick;

//banker gets card but player doesnt because its 6 or 7
      pscore = 4'd6; dscore = 4'd5;
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      
      reach_Si_quick;

      pscore = 4'd7; dscore = 4'd4;
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
	
      reach_Si_quick;

//banker doesnt get a card and player doesnt because its 6 or 7, go to gameover and turn on winner lights
      pscore = 4'd6; dscore = 4'd7;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,0,1);

      reach_Si_quick;
      pscore = 4'd7; dscore = 4'd6;
      @(posedge slow_clock);
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,1,0); //yes

//check condition a) no card for banker if dscore = 7 so we go to gameover (start at si then decide from Sf if we go to Sh(gameover) or Sg(deal card) 

      reach_Si_quick;
      pscore = 4'd5; dscore = 4'd7;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

      @(posedge slow_clock) #3;
      check_state(Sh);
      check_outputs(0,0,0,0,0,0,0,1);


 
//check condition b) dscore = 6, banker gets card if pcard = 6/7

      reach_Si_quick;
      pscore = 4'd5; dscore = 4'd6; pcard3 = 4'd6;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd6; pcard3 = 4'd7;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      //reach_Si_quick;

//check condition c) dscore = 5 pcard=(4,5,6,7)

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd5; pcard3 = 4'd4;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd5; pcard3 = 4'd5;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd5; pcard3 = 4'd6;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd5; pcard3 = 4'd7;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0); 

//check condition d) dscore = 4, pcard3=2,3,4,5,6,7)

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd2;

      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);

      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);

      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd3;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
       @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd4;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd5;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd6;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd4; pcard3 = 4'd7;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
       @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

//check condition e) dscore = 3, pcard3=1,2,3,4,5,6,7

      reach_Si_quick;

      pscore = 4'd0; dscore = 4'd3; pcard3 = 4'd1;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd1; dscore = 4'd3; pcard3 = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd2; dscore = 4'd3; pcard3 = 4'd3;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd3; dscore = 4'd3; pcard3 = 4'd4;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd4; dscore = 4'd3; pcard3 = 4'd5;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd3; pcard3 = 4'd6;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd3; pcard3 = 4'd7;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

     

  //check f) dscore = 0,1,2 then dealer should get a card

     reach_Si_quick;

      pscore = 4'd5; dscore = 4'd0; 
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd1; 
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);
      reach_Si_quick;

      pscore = 4'd5; dscore = 4'd2;
      @(posedge slow_clock);
      check_state(Sf);
      check_outputs(0,0,1,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sj);
      check_outputs(0,0,0,0,0,0,0,0);
      @(posedge slow_clock);
      check_state(Sg);
      check_outputs(0,0,0,0,0,1,0,0);

      reach_Si_quick;

      if (!err) $display("TEST PASSED");
      else      $display("TEST FAILED");

end
endmodule

