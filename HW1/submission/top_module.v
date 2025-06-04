`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CEMSE -- KAUST
// Engineer: Abril Alvarado
// 
// Create Date: 09/22/2024 07:55:21 PM
// Design Name: Multidigit seven segment display
// Module Name: top_module
// Project Name: CS 256 Homework 1
// Target Devices: Nexys A7
// Tool Versions: Xilinx Nexys A7
// Description: This module takes the inputs defined in the contraint file, as well
//              as the 100MHz clock, and outputs the correct signals for displaying
//              multiple digits on the seven-segment displays.
// 
// Dependencies: multidigit.v
// 
// Revision: 1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input CLK100MHZ,
    input CPU_RESETN,
    input [3:0] dig0,
    input [3:0] dig1,
    input [3:0] dig2,
    input [3:0] dig3,
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output [7:0] AN
    );

    // Display something on the leftmost values (my initials and birth year)
    wire [3:0] dig4 = 4'h9;
    wire [3:0] dig5 = 4'h9;
    wire [3:0] dig6 = 4'ha;
    wire [3:0] dig7 = 4'ha;
    
    // Divide a 17 bit counter to create a slow clock (Tip from the course repository).
    reg [16:0] counter17_100MHz;
    wire clk_slow = counter17_100MHz[16]; // Slow clock signal
    always @(posedge CLK100MHZ) begin
        if (!CPU_RESETN) begin
            counter17_100MHz <= 17'b0; // Reset the counter
        end else begin
            counter17_100MHz <= counter17_100MHz + 1'b1; // Increment counter
        end
    end
    
    // Instantiate the multidigit module
    multidigit instance0 (
        .dig0(dig0), .dig1(dig1), .dig2(dig2), .dig3(dig3),
        .dig4(dig4), .dig5(dig5), .dig6(dig6), .dig7(dig7),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .an(AN), .clk(clk_slow), .rst(!CPU_RESETN)
    );

endmodule