`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date: 03/03/2015 09:06:31 PM
// Design Name: 
// Module Name: top
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: This project takes keyboard input from the PS2 port,
//  and outputs the keyboard scan code to the 7 segment display on the board.
//  The scan code is shifted left 2 characters each time a new code is
//  read.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Modified to work with project
/////////////////////////////////////////////////////////////////////////////////

module top_keyboard(
    input clk,
    input rst,
    input PS2_CLK,
    input PS2_DATA,
    //output [6:0] SEG,
    //output [7:0] AN,
    //output DP,
    //output UART_TXD,
    output reg [4:0] p1button_state_kb,  // P1 Button states: {BTNU, BTND, BTNL, BTNR, BTNC}
    output reg [4:0] p2button_state_kb   // P2 Button states: {BTNU, BTND, BTNL, BTNR, BTNC}
);

reg CLK50MHZ = 0;    
wire [31:0] keycode;
reg W_state = 0;  // Register to store W key state

always @(posedge clk) begin
    CLK50MHZ <= ~CLK50MHZ;
end

PS2Receiver keyboard (
    .clk(CLK50MHZ),
    .kclk(PS2_CLK),
    .kdata(PS2_DATA),
    .keycodeout(keycode[31:0])
);

//seg7decimal sevenSeg (
//    .x(keycode[31:0]),
//    .clk(clk),
//    .seg(SEG[6:0]),
//    .an(AN[7:0]),
//    .dp(DP)
//);

// Key States for P1 and P2
always @(posedge CLK50MHZ) begin
    if (rst) begin
        p1button_state_kb <= 5'b00000;
        p2button_state_kb <= 5'b00000;
    end else begin
        if (keycode[15:8] == 8'hF0) begin  // Key Release
            case (keycode[7:0])
                8'h1D: p1button_state_kb[4] <= 0; // W -> P1 BTNU
                8'h1B: p1button_state_kb[3] <= 0; // S -> P1 BTND
                8'h1C: p1button_state_kb[2] <= 0; // A -> P1 BTNL
                8'h23: p1button_state_kb[1] <= 0; // D -> P1 BTNR
                8'h29: p1button_state_kb[0] <= 0; // Space -> P1 BTNC
                
                8'h75: p2button_state_kb[4] <= 0; // Up Arrow -> P2 BTNU
                8'h72: p2button_state_kb[3] <= 0; // Down Arrow -> P2 BTND
                8'h6B: p2button_state_kb[2] <= 0; // Left Arrow -> P2 BTNL
                8'h74: p2button_state_kb[1] <= 0; // Right Arrow -> P2 BTNR
                8'h5A: p2button_state_kb[0] <= 0; // Enter -> P2 BTNC
            endcase
        end else begin  // Key Press
            case (keycode[7:0])
                8'h1D: p1button_state_kb[4] <= 1; // W -> P1 BTNU
                8'h1B: p1button_state_kb[3] <= 1; // S -> P1 BTND
                8'h1C: p1button_state_kb[2] <= 1; // A -> P1 BTNL
                8'h23: p1button_state_kb[1] <= 1; // D -> P1 BTNR
                8'h29: p1button_state_kb[0] <= 1; // Space -> P1 BTNC
                
                8'h75: p2button_state_kb[4] <= 1; // Up Arrow -> P2 BTNU
                8'h72: p2button_state_kb[3] <= 1; // Down Arrow -> P2 BTND
                8'h6B: p2button_state_kb[2] <= 1; // Left Arrow -> P2 BTNL
                8'h74: p2button_state_kb[1] <= 1; // Right Arrow -> P2 BTNR
                8'h5A: p2button_state_kb[0] <= 1; // Enter -> P2 BTNC
            endcase
        end
    end
end

endmodule