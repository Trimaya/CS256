`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEMSE -- KAUST
// Engineer: Abril Alvarado
// 
// Create Date: 09/21/2024 04:14:23 PM
// Design Name: Seven Segment Decoder
// Module Name: sevenseg
// Project Name: CS 256 Homework 1
// Target Devices: Xilinx Nexys A7
// Tool Versions: Vivado 2020.2
// Description: This module translates a 4 bit number to seven 1 bit signals to be
//              used in a seven-segment display.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sevenseg(
    input [3:0] num,
    output reg a,
    output reg b,
    output reg c,
    output reg d,
    output reg e,
    output reg f,
    output reg g
);

    always @(*) begin // combinational logic
        case (num) // case statement
            // we use the concatenation operator {} to make things simpler.
            // note how the truth table is active-low
            4'b0000: {a, b, c, d, e, f, g} = 7'b0000001; // 0
            4'b0001: {a, b, c, d, e, f, g} = 7'b1001111; // 1
            4'b0010: {a, b, c, d, e, f, g} = 7'b0010010; // 2
            4'b0011: {a, b, c, d, e, f, g} = 7'b0000110; // 3
            4'b0100: {a, b, c, d, e, f, g} = 7'b1001100; // 4
            4'b0101: {a, b, c, d, e, f, g} = 7'b0100100; // 5
            4'b0110: {a, b, c, d, e, f, g} = 7'b0100000; // 6
            4'b0111: {a, b, c, d, e, f, g} = 7'b0001111; // 7
            4'b1000: {a, b, c, d, e, f, g} = 7'b0000000; // 8
            4'b1001: {a, b, c, d, e, f, g} = 7'b0000100; // 9
            4'b1010: {a, b, c, d, e, f, g} = 7'b0001000; // A
            4'b1011: {a, b, c, d, e, f, g} = 7'b1100000; // B
            4'b1100: {a, b, c, d, e, f, g} = 7'b0110001; // C
            4'b1101: {a, b, c, d, e, f, g} = 7'b1000010; // D
            4'b1110: {a, b, c, d, e, f, g} = 7'b0110000; // E
            4'b1111: {a, b, c, d, e, f, g} = 7'b0111000; // F
            default: {a, b, c, d, e, f, g} = 7'b1111111; // default (off)
        endcase
    end
endmodule