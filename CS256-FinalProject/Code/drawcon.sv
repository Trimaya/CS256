`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/08/2024 05:31:02 PM
// Design Name: Draw Condition
// Module Name: drawcon
// Project Name: CS 256 Final Project
// Target Devices: Nexys A7
// Tool Versions: Vivado v2020.2 (64-bit)
// Description: 
// 
// Dependencies: blk_mem_tank_90 blk_mem_tank_45 blk_mem_tank_90_2 blk_mem_tank_45_2
// 
// Revision:Final
// Revision 0.01 - File Created
// Additional Comments: This was fun
// 
//////////////////////////////////////////////////////////////////////////////////

module drawcon(
    input [10:0] p1pos_x,
    input [9:0] p1pos_y,
    input logic [10:0] draw_x,
    input logic [9:0] draw_y,
    output logic [3:0] draw_r,
    output logic [3:0] draw_g,
    output logic [3:0] draw_b,
    input clk, // for memory access to sprites and nothing else
    input rst,
    input [2:0] rot1,
    input [10:0] p1bullpos_x,
    input [9:0] p1bullpos_y,
    // Player 2
    input [2:0] rot2,
    input [10:0] p2bullpos_x,
    input [9:0] p2bullpos_y,
    input [10:0] p2pos_x,
    input [9:0] p2pos_y,
    input logic [999:0] map0,
    // Color Decision
    input [1:0] colorize
    );
    
      ////////////////////////
     // Object Definitions //
    ////////////////////////
    
    localparam BORDERSIZE = 16;
    localparam BLKSIZE = 32;
    localparam BULLSIZE = 8;
    
    wire border;
    assign border = (draw_x < 0 + BORDERSIZE || draw_x > 1279 - BORDERSIZE || draw_y < 0 + BORDERSIZE || draw_y > 799 - BORDERSIZE);
    wire block0;
    assign block0 = (draw_x >= p1pos_x && draw_x < p1pos_x+BLKSIZE) && (draw_y >= p1pos_y && draw_y < p1pos_y + BLKSIZE);
    wire block1;
    assign block1 = (draw_x >= p2pos_x && draw_x < p2pos_x+BLKSIZE) && (draw_y >= p2pos_y && draw_y < p2pos_y + BLKSIZE);
    wire bull0;
    assign bull0 = (draw_x >= p1bullpos_x - BULLSIZE/2 && draw_x < p1bullpos_x + BULLSIZE/2) && (draw_y >= p1bullpos_y - BULLSIZE/2 && draw_y < p1bullpos_y + BULLSIZE/2);
    wire bull1;
    assign bull1 = (draw_x >= p2bullpos_x - BULLSIZE/2 && draw_x < p2bullpos_x + BULLSIZE/2) && (draw_y >= p2bullpos_y - BULLSIZE/2 && draw_y < p2bullpos_y + BULLSIZE/2);
    
    logic [5:0] map_x;
    logic [4:0] map_y;
    logic [9:0] flat_index;
    logic wall;
    always_comb begin
        map_x = 6'd0; // default
        map_y = 5'd0; // default
        flat_index = 10'd0; // default
        wall = 1'b0; // default
        map_x = draw_x >> 5; // Divide by 32
        map_y = draw_y >> 5; // Divide by 32
        flat_index = (map_y * 40) + map_x; // Calculate the flat index
        wall = map0[flat_index]; // Check if we should place a wall
    end
    
      ///////////////////
     // Sprite Memory //
    ///////////////////
    
    logic [9:0] sprite_address;
    logic [11:0] sprite_data90;
    logic [11:0] sprite_data45;
    logic [3:0] sprite_r; logic [3:0] sprite_g; logic [3:0] sprite_b;

//    blk_mem_gen_0 testsprite0 (
//    .clka(clk),
//    .addra(sprite_address),
//    .douta(sprite_data)
//    );

    blk_mem_tank_90 player1_90 (
    .clka(clk),
    .addra(sprite_address),
    .douta(sprite_data90)
    );
    
    blk_mem_tank_45 player1_45 (
    .clka(clk),
    .addra(sprite_address),
    .douta(sprite_data45)
    );
    
    always_ff @(posedge clk) begin
        if(rst) begin
            sprite_address <= 10'd0;
            {sprite_r, sprite_g, sprite_b} <= 12'h000;
        end else begin
            case (rot1)
                3'b000: begin // 0° rotation (facing up)
                    sprite_address <= (draw_y - p1pos_y) * BLKSIZE + (draw_x - p1pos_x) + 4; // Pre-read
                    {sprite_r, sprite_g, sprite_b} <= sprite_data90[11:0];
                end
                3'b001: begin // 90° rotation (facing right)
                    sprite_address <= ((BLKSIZE - 1 - (draw_x - p1pos_x) - 4) * BLKSIZE) + (draw_y - p1pos_y); // Fixed FINALLY Pre-read
                    {sprite_r, sprite_g, sprite_b} <= sprite_data90[11:0];
                end
                3'b010: begin // 180° rotation (facing down)
                    sprite_address <= (((BLKSIZE - 1 - (draw_y - p1pos_y)) * BLKSIZE) + (BLKSIZE - 1 - (draw_x - p1pos_x))) - 4; // Fixed2 Pre-read
                    {sprite_r, sprite_g, sprite_b} <= sprite_data90[11:0];
                end
                3'b011: begin // 270° rotation (facing left)
                    sprite_address <= ((draw_x - p1pos_x) + 4) * BLKSIZE + (BLKSIZE - 1 - (draw_y - p1pos_y)); // Pre-read
                    {sprite_r, sprite_g, sprite_b} <= sprite_data90[11:0];
                end
                3'b100: begin // 45° rotation (facing up-right) (45° memory)
                    sprite_address <= ((BLKSIZE - 1 - (draw_x - p1pos_x) - 4) * BLKSIZE) + (draw_y - p1pos_y);
                    {sprite_r, sprite_g, sprite_b} <= sprite_data45[11:0];
                end
                3'b101: begin // 135° rotation (facing down-right) (45° memory)
                    sprite_address <= (((BLKSIZE - 1 - (draw_y - p1pos_y)) * BLKSIZE) + (BLKSIZE - 1 - (draw_x - p1pos_x))) - 4;
                    {sprite_r, sprite_g, sprite_b} <= sprite_data45[11:0];
                end
                3'b110: begin // 225° rotation (facing down-left) (45° memory)
                    sprite_address <= ((draw_x - p1pos_x) + 4) * BLKSIZE + (BLKSIZE - 1 - (draw_y - p1pos_y));
                    {sprite_r, sprite_g, sprite_b} <= sprite_data45[11:0];
                end
                3'b111: begin // 315° rotation (facing up-left) (45° memory)
                    sprite_address <= (draw_y - p1pos_y) * BLKSIZE + (draw_x - p1pos_x) + 4;
                    {sprite_r, sprite_g, sprite_b} <= sprite_data45[11:0];
                end
                default: begin
                    sprite_address <= 10'd0; // Default case
                    {sprite_r, sprite_g, sprite_b} <= 12'h000;
                end
            endcase
        end
    end
    
    // Player 2 //
    logic [9:0] sprite_address_2;
    logic [11:0] sprite_data90_2;
    logic [11:0] sprite_data45_2;
    logic [3:0] sprite_r_2; logic [3:0] sprite_g_2; logic [3:0] sprite_b_2;
    
    blk_mem_tank_90_2 player2_90 (
        .clka(clk),
        .addra(sprite_address_2),
        .douta(sprite_data90_2)
        );
        
    blk_mem_tank_45_2 player2_45 (
    .clka(clk),
    .addra(sprite_address_2),
    .douta(sprite_data45_2)
    );
        
    always_ff @(posedge clk) begin
        if(rst) begin
            sprite_address_2 <= 10'd0;
            {sprite_r_2, sprite_g_2, sprite_b_2} <= 12'h000;
        end else begin
            case (rot2)
                3'b000: begin // 0° rotation (facing up)
                    sprite_address_2 <= (draw_y - p2pos_y) * BLKSIZE + (draw_x - p2pos_x) + 4; // Pre-read
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data90_2[11:0];
                end
                3'b001: begin // 90° rotation (facing right)
                    sprite_address_2 <= ((BLKSIZE - 1 - (draw_x - p2pos_x) - 4) * BLKSIZE) + (draw_y - p2pos_y); // Fixed FINALLY Pre-read
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data90_2[11:0];
                end
                3'b010: begin // 180° rotation (facing down)
                    sprite_address_2 <= (((BLKSIZE - 1 - (draw_y - p2pos_y)) * BLKSIZE) + (BLKSIZE - 1 - (draw_x - p2pos_x))) - 4; // Fixed2 Pre-read
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data90_2[11:0];
                end
                3'b011: begin // 270° rotation (facing left)
                    sprite_address_2 <= ((draw_x - p2pos_x) + 4) * BLKSIZE + (BLKSIZE - 1 - (draw_y - p2pos_y)); // Pre-read
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data90_2[11:0];
                end
                3'b100: begin // 45° rotation (facing up-right) (45° memory)
                    sprite_address_2 <= ((BLKSIZE - 1 - (draw_x - p2pos_x) - 4) * BLKSIZE) + (draw_y - p2pos_y);
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data45_2[11:0];
                end
                3'b101: begin // 135° rotation (facing down-right) (45° memory)
                    sprite_address_2 <= (((BLKSIZE - 1 - (draw_y - p2pos_y)) * BLKSIZE) + (BLKSIZE - 1 - (draw_x - p2pos_x))) - 4;
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data45_2[11:0];
                end
                3'b110: begin // 225° rotation (facing down-left) (45° memory)
                    sprite_address_2 <= ((draw_x - p2pos_x) + 4) * BLKSIZE + (BLKSIZE - 1 - (draw_y - p2pos_y));
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data45_2[11:0];
                end
                3'b111: begin // 315° rotation (facing up-left) (45° memory)
                    sprite_address_2 <= (draw_y - p2pos_y) * BLKSIZE + (draw_x - p2pos_x) + 4;
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= sprite_data45_2[11:0];
                end
                default: begin
                    sprite_address_2 <= 10'd0; // Default case
                    {sprite_r_2, sprite_g_2, sprite_b_2} <= 12'h000;
                end
            endcase
        end
    end
    
      ////////////////
     // Draw Color //
    ////////////////
    
    logic [3:0] bg_r; logic [3:0] bg_g; logic [3:0]bg_b;
    logic [3:0] blk_r; logic [3:0] blk_g; logic [3:0] blk_b;
    logic [3:0] blk_r_2; logic [3:0] blk_g_2; logic [3:0] blk_b_2;
    logic [3:0] bull_r; logic [3:0] bull_g; logic [3:0] bull_b;
    logic [3:0] bull_r_2; logic [3:0] bull_g_2; logic [3:0] bull_b_2;
    logic [3:0] map_r; logic [3:0] map_g; logic [3:0] map_b;
    
    // Background //
    always_comb begin
        case (colorize)
            2'b00: {bg_r, bg_g, bg_b} = 12'h2A1; //green background
            2'b01: {bg_r, bg_g, bg_b} = 12'hA12; //red background
            2'b10: {bg_r, bg_g, bg_b} = 12'h12A; //blue background
            2'b11: {bg_r, bg_g, bg_b} = 12'hF2A; //pink background
        endcase
        if(border) begin
            case (colorize)
                2'b11: {bg_r, bg_g, bg_b} = 12'hF2A; //pink
                default: {bg_r, bg_g, bg_b} = 12'hFFF; //white border
            endcase
        end
    end
    
    // Player //
//    always_comb begin
//        if(block0) begin
//            {blk_r, blk_g, blk_b} = 12'hF0B; //pink block
//        end else begin
//            {blk_r, blk_g, blk_b} = 12'h000; //no block
//        end
//    end
    
    always_comb begin
        if(block0) begin
            {blk_r, blk_g, blk_b} = {sprite_r, sprite_g, sprite_b}; //sprite block
        end else begin
            {blk_r, blk_g, blk_b} = 12'h000; //no block
        end
    end
    
    
    // Player 2 //
    
    always_comb begin
        if(block1) begin
            {blk_r_2, blk_g_2, blk_b_2} = {sprite_r_2, sprite_g_2, sprite_b_2}; //sprite block
        end else begin
            {blk_r_2, blk_g_2, blk_b_2} = 12'h000; //no block
        end
    end
            
    
    // Map //
    always_comb begin
        if(wall) begin
            {map_r, map_g, map_b} = 12'h555; //gray wall
        end else begin
            {map_r, map_g, map_b} = 12'h000; //no wall
        end
    end
    
    // Bullet //
    always_comb begin
        if(bull0) begin
            {bull_r, bull_g, bull_b} = 12'hA00; //black-red bullet
        end else begin
            {bull_r, bull_g, bull_b} = 12'h000; //no bullet
        end
    end
    
    // Bullet 2 //
    always_comb begin
        if(bull1) begin
            {bull_r_2, bull_g_2, bull_b_2} = 12'h00A; //black-blue bullet
        end else begin
            {bull_r_2, bull_g_2, bull_b_2} = 12'h000; //no bullet
        end
    end
    
      ////////////////
     // Draw Order //
    ////////////////
    
    // First player, then bullet (first P1. then P2), then map, then background
    
    always_comb  begin
        if({blk_r, blk_g, blk_b} != 12'h000) begin
            {draw_r, draw_g, draw_b} = {blk_r, blk_g, blk_b};
        end else begin
            if ({bull_r, bull_g, bull_b} != 12'h000) begin
                {draw_r, draw_g, draw_b} = {bull_r, bull_g, bull_b};
            end else begin
                if({blk_r_2, blk_g_2, blk_b_2} != 12'h000) begin
                    {draw_r, draw_g, draw_b} = {blk_r_2, blk_g_2, blk_b_2};
                end else begin
                    if ({bull_r_2, bull_g_2, bull_b_2} != 12'h000) begin
                        {draw_r, draw_g, draw_b} = {bull_r_2, bull_g_2, bull_b_2};
                    end else begin
                        if ({map_r, map_g, map_b} != 12'h000) begin
                            {draw_r, draw_g, draw_b} = {map_r, map_g, map_b};
                        end else begin
                    {draw_r, draw_g, draw_b} = {bg_r, bg_g, bg_b};
                        end
                    end
                end
            end
        end
    end

endmodule