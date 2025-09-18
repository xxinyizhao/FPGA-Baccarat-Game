// Defining constants for the state machines:
`define Sa 4'b0000
`define Sb 4'b0001
`define Sc 4'b0010
`define Sd 4'b0011
`define Se 4'b0100
`define Sf 4'b0101
`define Sg 4'b0111
`define Sh 4'b1000

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);


reg[3:0] present_state; // variable has the state we are currently in 

always_ff@(posedge slow_clock) begin
    if (~resetb) begin
        present_state <= `Sa;
    end else begin
        case(present_state)
        // move between states based on the current state value
        `Sa: present_state <= `Sb;

        `Sb: present_state <= `Sc;

        `Sc: present_state <= `Sd;
        
        `Sd: present_state <= `Se;
        
        `Se: begin
            if (dscore == 4'b1000 || dscore == 4'b1001) begin
                present_state <= `Sh; // game over
            end else  
                case (pscore) 
                    4'b1000, 4'b1001: present_state <= `Sh; // game over

                    4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: present_state <= `Sf; //draw pcard3

                    4'b0110, 4'b0111: begin

                        if (dscore <= 4'b0101) // might be wrong
                            present_state <= `Sg; // banker draws a card
                        else 
                            present_state <= `Sh; // game over

                    end
                endcase
            end
        end

        `Sf: begin
            if (dscore ==  4b'0111) begin
                present_state <= `Sh; //gameover
            end
            
            case (dscore) //check this, might be badddd
            4'b0110: if(pcard3 == 4'b0110 || pcard3 == 4'b0111 )
                present_state <= `Sg;
            else
                present_state <= `Sh;
            4'b0101: if(pcard3 == 4'b0110 || pcard3 == 4'b0111 ) present_state <= `Sg;
            4'b0100: if(pcard3 == 4'b0110 || pcard3 == 4'b0111 ) present_state <= `Sg;
            4'b0011: if(pcard3 == 4'b0110 || pcard3 == 4'b0111 ) present_state <= `Sg;
            4'b0010, 4'b0001, 4'b0000: present_state <= `Sg;
           
            endcase
        end
        `Sg: 
        
        default: present_state <= `Sa;
        
        endcase
    end
end

always_comb begin
    case (present_state)
    
    `Sa: begin
        load_pcard1 = 1'b0;
        load_pcard2 = 1'b0;
        load_pcard3 = 1'b0;
        load_dcard1 = 1'b0;
        load_dcard2 = 1'b0;
        load_dcard3 = 1'b0;
    end
    
    `Sb: load_pcard1 = 1'b1;
    
    `Sc: begin
        load_pcard1 = 1'b0;
        load_dcard1 = 1'b1;
    end
    `Sd: begin
        load_dcard1 = 1'b0;
        load_pccard2 = 1'b1;
    end
    `Se: begin
        load_pcard2 = 1'b0;
        load_dcard2 = 1'b1;
    end
    `Sf: load_dcard2 = 1'b0;
    `Sg: 

    endcase
end

endmodule