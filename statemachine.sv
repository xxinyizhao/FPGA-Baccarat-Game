module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

// defining constants for the state machines
enum logic [3:0] {
    Sa = 4'b0000, // starting state
    Sb = 4'b0001, // draw pcard1
    Sc = 4'b0010, // draw dcard1
    Sd = 4'b0011, // draw pcard2
    Se = 4'b0100, // draw dcard2
    Sf = 4'b0101, // draw pcard3
    Sg = 4'b0110, // draw dcard3
    Sh = 4'b0111, // game over
	 Si = 4'b1111
	 
} present_state, next_state;

always_comb begin // combinational logic to find next_state
    /*if (~resetb)
        next_state = Sa;
    else begin */
        case(present_state)
        // immediately proceed to next state on next rising slow_clk edge
            Sa: next_state = Sb;
            Sb: next_state = Sc;
            Sc: next_state = Sd;
            Sd: next_state = Se;
				Se: next_state = Si;
				
            Si: begin
                if (dscore == 4'b1000 || dscore == 4'b1001)
                    next_state = Sh; // game over if dealer's score is 8 or 9
                else begin
                    case (pscore)
                        4'b1000, 4'b1001: next_state = Sh; // game over if player's score is 8 or 9
                        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: next_state = Sf; // player draws third card
                        4'b0110, 4'b0111: begin
                            if (dscore <= 4'b0101) // for when dscore = 0, 1, 2, 3, 4, 5
                                next_state = Sg; // dealer draws a card
                            else
                                next_state = Sh; // game over
                        end
                        default: next_state = Si; // stay in same state otherwise
                    endcase
                    
                end
            end

            Sf: begin // decide if dealer draws a third card after player draws their third card
                    if (dscore ==  4'b0111)
                        next_state = Sh; // game over
                    else case (dscore)
                            4'b0110: next_state = ((pcard3 == 4'b0110) || (pcard3 == 4'b0111)) ? Sg : Sh;
                            4'b0101: next_state = ((pcard3 >= 4'b0100) && (pcard3 <= 4'b0111)) ? Sg : Sh;
                            4'b0100: next_state = ((pcard3 >= 4'd0010) && (pcard3 <= 4'b0111)) ? Sg : Sh;
                            4'b0011: next_state = (pcard3 != 4'b1000) ? Sg : Sh;
                            default: next_state = Sg; // if dscore is 0,1,2,3 then dealer draws a 3rd card
                    endcase
            end

            Sg: next_state = Sh;

            Sh: next_state = Sh;

            default: next_state = Sa;
        endcase
    //end
end

// sequential logic to change present_state based on rising edge of slow_clock
always_ff@(posedge slow_clock) begin
    if (~resetb) 
        present_state <= Sa;
    else
        present_state <= next_state;

end

always_comb begin // combinational logic to determine outputs based on present_state
    load_pcard1 = 1'b0;
    load_pcard2 = 1'b0;
    load_pcard3 = 1'b0;
    load_dcard1 = 1'b0;
    load_dcard2 = 1'b0;
    load_dcard3 = 1'b0;
    player_win_light = 1'b0;
    dealer_win_light = 1'b0;

    case (present_state)
        Sb: load_pcard1 = 1'b1;
        Sc: begin
            load_pcard1 = 1'b0;
            load_dcard1 = 1'b1;
        end
        Sd: begin
            load_dcard1 = 1'b0;
            load_pcard2 = 1'b1;
        end
        Se: begin
            load_pcard2 = 1'b0;
            load_dcard2 = 1'b1;
        end
        Sf: begin
            load_dcard2 = 1'b0;
            load_pcard3 = 1'b1;
        end
        Sg: begin
            load_pcard3 = 1'b0;
            load_dcard3 = 1'b1;
        end
		 
		  
        Sh: begin // game over: display winner or tie
            load_dcard3 = 1'b0;
            if (pscore == dscore) begin
                player_win_light = 1'b1;
                dealer_win_light = 1'b1;
            end else begin
                player_win_light = (pscore > dscore) ? 1'b1 : 1'b0;
                dealer_win_light = (pscore < dscore) ? 1'b1 : 1'b0;
            end
        end
		
        Si: begin
		end
		  
        default: begin // reset all signals when in Sa and all other values of present_state
            load_pcard1 = 1'b0;
            load_pcard2 = 1'b0;
            load_pcard3 = 1'b0;
            load_dcard1 = 1'b0;
            load_dcard2 = 1'b0;
            load_dcard3 = 1'b0;
            player_win_light = 1'b0;
            dealer_win_light = 1'b0;
        end
    endcase
end

endmodule