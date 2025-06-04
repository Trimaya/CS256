`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/25/2024 04:28:49 AM
// Design Name: 
// Module Name: song_player 
// Project Name: CS 256 Final Project
// Target Devices: Nexys A7
// Tool Versions: Vivado v2020.2 (64-bit)
// Description: 
// 
// Dependencies: song_reader sawtooth_synth
// 
// Revision:Final
// Revision 0.01 - File Created
// Additional Comments: This was fun
// 
//////////////////////////////////////////////////////////////////////////////////

module song_player (
    input wire clk,
    input wire reset,//CPU_RESETN,
    input [1:0] music_track,
    output logic AUD_PWM,
    output wire AUD_SD
);
    assign AUD_SD = 1'b1;
    // Clock divider to generate 25 MHz signal
    wire clk25;
    logic [2:0] clk_counter;
    //assign reset = !CPU_RESETN;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            clk_counter <= 2'b00;
        end else begin
            clk_counter <= clk_counter + 1'b1;
        end
    end
    assign clk25 = !clk_counter[2]; // Divide clock
    
    wire [3:0] main_note_idx;
    wire [3:0] bass_note_idx;
    wire [15:0] main_note_freq;
    wire [15:0] bass_note_freq;
    wire main_pwm;
    wire bass_pwm;

    wire [15:0] main_note_lut [0:15];
    wire [15:0] bass_note_lut [0:15];
    assign main_note_lut[0] = 2093; // C7
    assign main_note_lut[1] = 1047; // A6
    assign main_note_lut[2] = 1568; // G6
    assign main_note_lut[3] = 1319; // E6
    assign main_note_lut[4] = 1175; // D6
    assign main_note_lut[5] = 987;  // C6
    assign main_note_lut[6] = 880;  // A5
    assign main_note_lut[7] = 784;  // G5
    assign main_note_lut[8] = 659;  // E5
    assign main_note_lut[9] = 587;  // D5
    assign main_note_lut[10] = 1661; // A6#
    assign main_note_lut[11] = 1397; // F6
    assign main_note_lut[12] = 392; // G4
    assign main_note_lut[13] = 330; // E4
    assign main_note_lut[14] = 294; // D4
    assign main_note_lut[15] = 0; // Silent
    
    // Bass notes
    assign bass_note_lut[0] = 2093; // C7
    assign bass_note_lut[1] = 1047; // A6
    assign bass_note_lut[2] = 1568; // G6
    assign bass_note_lut[3] = 1319; // E6
    assign bass_note_lut[4] = 1175; // D6
    assign bass_note_lut[5] = 987;  // C6
    assign bass_note_lut[6] = 880;  // A5
    assign bass_note_lut[7] = 784;  // G5
    assign bass_note_lut[8] = 659;  // E5
    assign bass_note_lut[9] = 587;  // D5
    assign bass_note_lut[10] = 523; // C5
    assign bass_note_lut[11] = 440; // A4
    assign bass_note_lut[12] = 392; // G4
    assign bass_note_lut[13] = 330; // E4
    assign bass_note_lut[14] = 294; // D4
    assign bass_note_lut[15] = 0; // Silent

    song_reader song_reader_inst (
        .clk(clk25),
        .reset(reset),
        .track(music_track),
        .main_note_idx(main_note_idx),
        .bass_note_idx(bass_note_idx)
    );

    assign main_note_freq = main_note_lut[main_note_idx];
    assign bass_note_freq = bass_note_lut[bass_note_idx];

    logic [7:0] main_wave;
    logic [7:0] bass_wave;
    
    sawtooth_synth main_synth (
        .clk25(clk25),
        .reset(reset),
        .note_freq(main_note_freq),
        .pwm_out(main_pwm),
        .wave_out(main_wave)
    );
    
     sawtooth_synth bass_synth (
        .clk25(clk25),
        .reset(reset),
        .note_freq(bass_note_freq),
        .pwm_out(bass_pwm),
        .wave_out(bass_wave)
    );
      ////////////////////////////////
     // Mix the two waves together //
    ////////////////////////////////
    logic [8:0] sum_wave;

    always_comb begin
        sum_wave = main_wave + bass_wave; // Sum the waveforms
    end

    // Clip down the result to fit in 8 bits
    assign mixed_wave = sum_wave[8] ? 8'b1111_1111 : sum_wave[7:0];
    
    // PWM Generator //
    
    logic [7:0] pwm_counter;

    always_ff @(posedge clk25) begin
        if (reset) begin
            pwm_counter <= 8'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
        end
    end
    
    always_comb begin
        if(music_track != 2'b00) begin
            if(pwm_counter < sum_wave) begin
                AUD_PWM = 1'b1;
            end else begin
                AUD_PWM = 1'b0;
            end
        end else begin
            AUD_PWM = 1'b0;
        end
    end
    //assign AUD_PWM = (pwm_counter < sum_wave) ? 1'b1 : 1'b0;
endmodule