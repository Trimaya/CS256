`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/24/2024 10:21:36 PM
// Design Name: 
// Module Name: audio_test_top
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

module audio_test_top (
    input logic CPU_RESETN,   // Reset signal (active-low)
    output logic AUD_PWM,     // Audio PWM output
    output logic AUD_SD,      // Audio amplifier enable
    input logic clk,          // Input clock (25.6 MHz)
    input logic [15:0] SW
);

    // Internal signals
    logic pwm_out;
    logic clk_25_6_MHz;
    logic reset;              // Active-high reset
    logic [2:0] clk_counter;
    logic [15:0] note_freq;
    
    //
    assign note_freq[15:0] = SW[15:0];

    // Active-high reset
    assign reset = ~CPU_RESETN;

    // Clock divider to generate 25.6 MHz signal
    always_ff @(posedge clk) begin
        if (reset) begin
            clk_counter <= 3'b000;  // Reset counter
            clk_25_6_MHz <= 1'b0;  // Initialize clock
        end else begin
            clk_counter <= clk_counter + 1'b1;
            clk_25_6_MHz <= clk_counter[2]; // Divide clock
        end
    end

    // Output assignments
    assign AUD_PWM = pwm_out;  // Connect PWM output
    assign AUD_SD = 1'b1;      // Audio amplifier always on

    // Parameters
    localparam integer MAX_COUNT = 256;  // 8-bit resolution
    localparam integer CLK_FREQ = 25_600_000; // 25.6 MHz

    // Registers
    logic [7:0] sawtooth_value; // Sawtooth waveform value (8-bit)
    logic [7:0] pwm_counter;    // PWM counter
    logic [31:0] cycle_step;    // Step size for cycle counter
    logic [31:0] cycle_counter; // Counts cycles for the note frequency

    // Calculate cycle step based on desired frequency
    always_comb begin
        if (note_freq > 0)
            cycle_step = (CLK_FREQ / (note_freq * MAX_COUNT));
        else
            cycle_step = 32'b0; // Default step size for invalid frequency
    end

    // Generate the sawtooth wave
    always_ff @(posedge clk_25_6_MHz or posedge reset) begin
        if (reset) begin
            sawtooth_value <= 8'b0;   // Initialize sawtooth value
            cycle_counter <= 32'b0;  // Initialize cycle counter
        end else if (cycle_counter >= cycle_step) begin
            cycle_counter <= 32'b0;  // Reset cycle counter
            sawtooth_value <= sawtooth_value + 1; // Increment sawtooth
        end else begin
            cycle_counter <= cycle_counter + 1;
        end
    end

    // Generate PWM signal
    always_ff @(posedge clk_25_6_MHz or posedge reset) begin
        if (reset) begin
            pwm_counter <= 8'b0;  // Initialize PWM counter
            pwm_out <= 1'b0;      // Initialize PWM output
        end else begin
            pwm_counter <= pwm_counter + 1;
            pwm_out <= (pwm_counter < sawtooth_value) ? 1'b1 : 1'b0;
        end
    end

endmodule