`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/25/2024 09:20:36 PM
// Design Name: Game Finite State Machine
// Module Name: game_fsm
// Project Name: CS 256 Final Project
// Target Devices: Nexys A7
// Tool Versions: Vivado v2020.2 (64-bit)
// Description: 
// 
// Dependencies:
// 
// Revision:Final
// Revision 0.01 - File Created
// Additional Comments: This was fun
// 
//////////////////////////////////////////////////////////////////////////////////


module game_fsm (
    input logic clk,                // Clock signal
    input logic rst,                // Reset signal
    input logic coin_inserted,      // Input to start the game
    input logic p1_wins,            // Player 1 wins condition
    input logic p2_wins,            // Player 2 wins condition
    input logic tie_game,           // Tie condition
    input logic replay,             // Input to replay
    input logic secret,             // Secret
    input logic game_initialized,
    output logic insert_coin_screen,// Insert Coin screen active
    output logic game_running,      // Game is running
    output logic p1_wins_screen,    // Player 1 wins screen active
    output logic p2_wins_screen,    // Player 2 wins screen active
    output logic tie_screen,         // Tie screen active
    output logic secret_screen,      // Secret screen is active
    output logic game_start         // State to initialize the game
);

    // Define states
    typedef enum {
        INSERT_COIN,    // Insert coin screen
        GAME,           // Game running
        P1_WINS,        // Player 1 wins screen
        P2_WINS,        // Player 2 wins screen
        TIE,            // Tie screen
        DAY27,           // Super Secret 
        GAME_START      // Initialize the game
    } state_t;

    state_t st, nst; // Current and next state

    // State transition logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            st <= INSERT_COIN;
        else
            st <= nst;
    end

    // Next state logic
    always_comb begin
        nst = st; // Default: stay in the same state
        case (st)
            INSERT_COIN: begin
                if (coin_inserted) begin
                    nst = GAME_START;
                end else begin
                    if (secret) begin
                        nst = DAY27;
                    end
                end
                
            end
            GAME: begin
                if (p1_wins) begin
                    nst = P1_WINS;
                end else if (p2_wins) begin
                    nst = P2_WINS;
                end else if (tie_game) begin
                    nst = TIE;
                end
            end
            P1_WINS: begin
                if (replay) begin
                    nst = INSERT_COIN; // Reset to Insert Coin after Player 1 wins
                end
            end
            P2_WINS: begin
                if (replay) begin
                    nst = INSERT_COIN; // Reset to Insert Coin after Player 2 wins
                end
            end
            TIE: begin
                if (replay) begin
                    nst = INSERT_COIN;     // Reset to Insert Coin after Tie
                end
            end
            DAY27: begin
                if (!secret) begin
                    nst = INSERT_COIN;
                end
            end
            GAME_START: begin
                if (game_initialized) begin
                    nst = GAME;
                end
            end
            default: begin
                nst = INSERT_COIN; // Default state
            end
        endcase
    end

    // Output logic
    assign insert_coin_screen = (st == INSERT_COIN);
    assign game_running       = (st == GAME);
    assign p1_wins_screen     = (st == P1_WINS);
    assign p2_wins_screen     = (st == P2_WINS);
    assign tie_screen         = (st == TIE);
    assign secret_screen      = (st == DAY27);
    assign game_start         = (st == GAME_START);

endmodule