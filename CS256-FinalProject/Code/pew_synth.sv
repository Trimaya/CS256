`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/25/2024 08:40:43 PM
// Design Name: 
// Module Name: pew_synth
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

module pew_synth (
    input wire clk25,
    input wire reset,
    input wire fire,
    output wire [7:0] waveform_out
);
    logic [15:0] freq;
    logic [15:0] base_freq;
    logic [31:0] duration_counter;
    logic [7:0] wave_value;
    logic active;

    parameter MAX_DURATION = 25_000_000 / 2; // Half a second duration (adjust as needed)
    parameter FREQ_STEP = 100;

    always_ff @(posedge clk25) begin
        if (reset) begin
            freq <= 16'd0;
            base_freq <= 16'd0;
            duration_counter <= 32'd0;
            wave_value <= 8'b0;
            active <= 1'b0;
        end else if (fire && !active) begin
            // Start the pew sound
            base_freq <= 16'd2000; // Initial frequency (adjust as needed)
            freq <= 16'd2000;
            duration_counter <= 32'd0;
            active <= 1'b1;
        end else if (active) begin
            if (duration_counter >= MAX_DURATION) begin
                // End the pew sound
                active <= 1'b0;
                wave_value <= 8'b0;
            end else begin
                // Generate the pew sound
                duration_counter <= duration_counter + 1;
                wave_value <= wave_value + 1;
                if (freq > FREQ_STEP) freq <= freq - FREQ_STEP; // Decrease frequency
            end
        end
    end

    // Output the waveform
    assign waveform_out = active ? wave_value : 8'b0;
endmodule