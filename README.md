Here’s a polished README you can use for your personal project portfolio focusing on **Task 5** of the CPEN 311 Baccarat Lab, highlighting your work with Gorata Gaolaolwe:

---

# CPEN 311: Lab 1 – Baccarat Game (Task 5)

## Overview

I designed a baccarat game engine with my lab partner Gorata Gaolaolwe for our CPEN 311 (Digital Systems Design) course. We implemented a baccarat game on the DE1-SoC FPGA board, including a random number generator, datapath, state machine, score computation, and seven-segment display outputs. This game follows the **Punto Banco** variant of Baccarat, automating all card dealing, scoring, and score display.

---

## Project Objectives

* Implement the Baccarat game logic in **SystemVerilog**.
* Complete the **datapath** and **state machine** for automatic card dealing.
* Compute player and dealer scores correctly according to Baccarat rules.
* Display card values on **HEX displays** and scores on LEDs.
* Indicate the winner (player, dealer, or tie) using LEDs.
* Write **unit testbenches** for all modules to verify functionality.

---

### Datapath

The datapath manages the following operations:

1. **Card registers (`reg4`)**: Store up to three cards for both player and dealer hands.
2. **Score calculation (`scorehand`)**: Computes hand scores modulo 10.
3. **Seven-segment display (`card7seg`)**: Shows card values on HEX displays.
4. **Control signals**: Managed by the state machine, determining when each register is loaded with a new card.

### State Machine

The state machine automates the game flow:

* Deals the first four cards alternately between player and dealer.
* Determines whether a third card is necessary for either hand based on Baccarat rules.
* Generates control signals (`load_pcard1`, `load_dcard1`, etc.) for the datapath.
* Signals the winner using LEDs: LEDR8 for player, LEDR9 for dealer, or both for a tie.

### Testbenches

We wrote **exhaustive testbenches** for all modules, and simulated them using ModelSim:

* `tb_datapath.sv` – Validates correct card storage and score updates.
* `tb_scorehand.sv` – Ensures hand scores are calculated correctly for all card combinations.
* `tb_statemachine.sv` – Checks the correct sequence of states and control signals.
* `tb_task5.sv` – Tests the top-level module, simulating a complete game sequence.

Testbenches used **both waveform monitoring** and `$display` statements to confirm expected outputs.
