`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/25/2024 04:28:49 AM
// Design Name: 
// Module Name: song_reader
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

module song_reader (
    input logic clk,
    input logic reset,
    input [1:0] track,
    output logic [3:0] main_note_idx,
    output logic [3:0] bass_note_idx
);
    parameter [15:0] BPM = 150;
    localparam [31:0] CLK_FREQ = 25_000_000;
    localparam [31:0] TPB = CLK_FREQ * 60 / BPM / 4; // Ticks per 1/16 note

    // Define the number of sections and notes per section
    localparam integer MAIN_SECTIONS = 8;
    localparam integer BASS_SECTIONS = 3;
    localparam integer NOTES_PER_SECTION = 16; // Notes in each section
    localparam integer SONG_LENGTH = 16; // Total number of sections in the song

    // Song structure (sections point to notes)
    logic [3:0] main_sections [0:MAIN_SECTIONS-1][0:NOTES_PER_SECTION-1];
    logic [3:0] bass_sections [0:BASS_SECTIONS-1][0:NOTES_PER_SECTION-1];
    logic [3:0] main_song_structure [0:SONG_LENGTH-1]; // Main melody structure
    logic [3:0] bass_song_structure [0:SONG_LENGTH-1]; // Bass line structure

    // Initialize song data
    always_comb begin
    case (track)
        2'd1:  begin
        // Main sections
        main_sections[1] = '{4'h0, 4'h1, 4'h6, 4'h3, 4'hF, 4'h1, 4'hF, 4'hF,
                             4'h0, 4'h1, 4'h2, 4'hF, 4'h3, 4'h3, 4'h3, 4'h3};
        main_sections[2] = '{4'h0, 4'h1, 4'h6, 4'h3, 4'hF, 4'h1, 4'hF, 4'hF,
                             4'h0, 4'h1, 4'h2, 4'hF, 4'h4, 4'h4, 4'h4, 4'h4};
        main_sections[3] = '{4'h8, 4'h7, 4'h8, 4'h8, 4'h5, 4'h6, 4'h4, 4'h4,
                             4'h7, 4'h8, 4'h6, 4'h6, 4'h9, 4'h8, 4'h7, 4'h7};
        main_sections[4] = '{4'h1, 4'h1, 4'h1, 4'h1, 4'h4, 4'h4, 4'h0, 4'h0,
                             4'h1, 4'h1, 4'h2, 4'h2, 4'h3, 4'h3, 4'h4, 4'h4};
        main_sections[5] = '{4'h1, 4'h1, 4'h1, 4'h1, 4'h0, 4'h0, 4'h4, 4'h4,
                             4'h3, 4'h3, 4'h2, 4'h2, 4'h3, 4'h3, 4'h5, 4'h5};
        main_sections[6] = '{4'h1, 4'h1, 4'h1, 4'h1, 4'h4, 4'h4, 4'h0, 4'h0,
                             4'h5, 4'h5, 4'h5, 4'h5, 4'h5, 4'h5, 4'h5, 4'h5};
        main_sections[7] = '{4'h2, 4'h3, 4'h1, 4'h1, 4'h7, 4'h6, 4'h8, 4'h8,
                             4'h4, 4'h3, 4'h2, 4'h2, 4'h4, 4'h5, 4'h3, 4'h3};
        main_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};

        // Bass sections
        bass_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[1] = '{4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6,
                             4'h7, 4'h7, 4'h7, 4'h7, 4'h7, 4'h7, 4'h7, 4'h7};
        bass_sections[2] = '{4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6,
                             4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6, 4'h6};

        // Main song structure
        main_song_structure = '{4'd1, 4'd2, 4'd1, 4'd2, 4'd3, 4'd3, 4'd7, 4'd4,
                                4'd5, 4'd6, 4'd3, 4'd7, 4'd3, 4'd1, 4'd2, 4'd0};

        // Bass song structure
        bass_song_structure = '{4'd0, 4'd0, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1,
                                4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd1, 4'd2};
        end
        2'd2: begin
        main_sections[1] = '{4'h5, 4'hF, 4'h5, 4'hF, 4'h4, 4'h4, 4'h5, 4'h5,
                             4'hB, 4'hB, 4'hB, 4'hB, 4'h3, 4'h3, 4'h3, 4'h3};
        main_sections[2] = '{4'h5, 4'hF, 4'h5, 4'hF, 4'h4, 4'h4, 4'h5, 4'h5,
                             4'h2, 4'h2, 4'h2, 4'h2, 4'hB, 4'hB, 4'hB, 4'hB};
        main_sections[3] = '{4'h5, 4'hF, 4'h5, 4'hF, 4'h0, 4'h0, 4'h1, 4'h1,
                             4'h2, 4'h2, 4'h2, 4'h2, 4'h3, 4'h3, 4'h4, 4'h4};
        main_sections[4] = '{4'hA, 4'hA, 4'hA, 4'hA, 4'h1, 4'h1, 4'hB, 4'hB,
                             4'h2, 4'h2, 4'h2, 4'h2, 4'hB, 4'hB, 4'hB, 4'hB};
        main_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[5] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[6] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[7] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[1] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[2] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_song_structure = '{4'd1, 4'd2, 4'd3, 4'd4, 4'd0, 4'd0, 4'd1, 4'd2,
                                4'd3, 4'd4, 4'd0, 4'd0, 4'd1, 4'd2, 4'd3, 4'd4};
        bass_song_structure = '{4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
                                4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0};
        end
        
        default: begin
        main_sections[1] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[2] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[3] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[4] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[5] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[6] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_sections[7] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[0] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[1] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        bass_sections[2] = '{4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF,
                             4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF};
        main_song_structure = '{4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
                                4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0};
        bass_song_structure = '{4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0,
                                4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0};
        end
    endcase
    end

    // State variables
    logic [31:0] note_counter;            // Counter for timing each 1/16 note
    logic [3:0] current_main_section;     // Index of the current main section
    logic [3:0] current_bass_section;     // Index of the current bass section
    logic [3:0] main_note_within_section; // Note index within the main section
    logic [3:0] bass_note_within_section; // Note index within the bass section

    // Playback logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            note_counter <= 32'd0;
            current_main_section <= 4'd0;
            current_bass_section <= 4'd0;
            main_note_within_section <= 4'd0;
            bass_note_within_section <= 4'd0;
        end else if (note_counter >= TPB) begin
            note_counter <= 32'd0;

            // Increment main note index within the current section
            if (main_note_within_section == NOTES_PER_SECTION - 1) begin
                main_note_within_section <= 4'd0;

                // Increment main section index or loop back to the start
                if (current_main_section == SONG_LENGTH - 1)
                    current_main_section <= 4'd0;
                else
                    current_main_section <= current_main_section + 1;
            end else begin
                main_note_within_section <= main_note_within_section + 1;
            end

            // Increment bass note index within the current section
            if (bass_note_within_section == NOTES_PER_SECTION - 1) begin
                bass_note_within_section <= 4'd0;

                // Increment bass section index or loop back to the start
                if (current_bass_section == SONG_LENGTH - 1)
                    current_bass_section <= 4'd0;
                else
                    current_bass_section <= current_bass_section + 1;
            end else begin
                bass_note_within_section <= bass_note_within_section + 1;
            end
        end else begin
            note_counter <= note_counter + 1;
        end
    end

    // Assign current notes based on the section and note index
    assign main_note_idx = main_sections[main_song_structure[current_main_section]][main_note_within_section];
    assign bass_note_idx = bass_sections[bass_song_structure[current_bass_section]][bass_note_within_section];

endmodule