`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 10/04/2024 04:43:13 PM
// Design Name: VGA Output
// Module Name: vga_out
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


module vga_out(
    input clk,
    input rst,
    input [3:0] draw_r,
    input [3:0] draw_g,
    input [3:0] draw_b,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync,
    output vsync,
    output logic [10:0] curr_x,
    output logic [9:0] curr_y
    );
    
logic [10:0] hcount; // 11-bit hcount
logic [9:0] vcount; // 10-bit vcount
wire display_area;

always_ff @(posedge clk) begin
    if(rst) begin
        hcount <= 0;
        vcount <= 0;
    end else begin
        if(hcount < 1679) begin // counts from 0 to 1679
            hcount <= hcount + 1'b1;
        end else begin
            hcount <= 0; // wraps around
            if(vcount < 827) begin // counts from 0 to 827
                vcount <= vcount + 1'b1;
            end else begin
                vcount <= 0; // wraps around    
            end
        end
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        curr_x <= 0;
        curr_y <= 0;
    end else begin
        if(display_area) begin
            if(curr_x < 1279) begin // counts from 0 to 1279
                curr_x <= curr_x + 1'b1;
            end else begin
                curr_x <= 0; // wraps around
                if(curr_y < 799) begin // counts from 0 to 799
                    curr_y <= curr_y + 1'b1;
                end else begin
                    curr_y <= 0; // wraps around    
                end
            end
        end
    end
end

// hsync output to be 0 when hcount is between 0 and 135 inclusive (and 1 otherwise)
assign hsync = (hcount >= 0 && hcount <= 135) ? 0 : 1;
// vsync to be 1 when vcount is between 0 and 2 inclusive (and 0 otherwise)
assign vsync = (vcount >= 0 && vcount <= 2) ? 1 : 0;

// The visible region horizontally is between 336 and 1615 inclusive, and vertically between 27 and 826 inclusive.
assign display_area = (hcount >= 336 && hcount <= 1615) && (vcount >= 27 && vcount <= 826);

assign {pix_r, pix_g, pix_b} = display_area ? {draw_r, draw_g, draw_b} : 12'h000;

endmodule