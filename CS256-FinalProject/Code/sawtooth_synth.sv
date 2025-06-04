`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/25/2024 04:28:49 AM
// Design Name: 
// Module Name: sawtooth_synth
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
module sawtooth_synth (
    input wire clk25,
    input wire reset,
    input wire [15:0] note_freq,
    output wire pwm_out,
    output logic [7:0] wave_out
);

    logic [7:0] sawtooth_value;
    assign wave_out[7:0] = sawtooth_value[7:0];
    logic [31:0] cycle_step;
    logic [31:0] cycle_counter;

    always_comb begin
        cycle_step = (25_000_000 / (note_freq * 256));
    end

    always_ff @(posedge clk25) begin
        if (reset) begin
            sawtooth_value <= 8'b0;
            cycle_counter <= 32'b0;
        end else if (cycle_counter >= cycle_step) begin
            cycle_counter <= 32'b0;
            sawtooth_value <= sawtooth_value + 1;
        end else begin
            cycle_counter <= cycle_counter + 1;
        end
    end

    assign pwm_out = (cycle_counter < sawtooth_value) ? 1'b1 : 1'b0;

endmodule