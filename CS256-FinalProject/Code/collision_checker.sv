`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/24/2024 03:34:45 AM
// Design Name: Collision Checker
// Module Name: collision_checker
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


module collision_checker #(
    parameter MAP_WIDTH = 40,
    parameter MAP_HEIGHT = 25,
    parameter SCREEN_WIDTH = 1280,
    parameter SCREEN_HEIGHT = 800,
    parameter BORDER_SIZE = 16,
    parameter ENTITY_SIZE = 32
)(
    input logic [10:0] pos_x,      // x-coordinate to check
    input logic [9:0] pos_y,       // y-coordinate to check
    input logic [999:0] map, // Collision map (40x25 grid)
    output logic collision        // Collision flag
);

logic [5:0] map_x;
logic [4:0] map_y;
logic [9:0] flat_index;
logic wall, wall_nw, wall_ne, wall_sw, wall_se;
logic border;

// Convert Map coordinates to Screen coordinates
always_comb begin
    wall = 1'b0; // default
    wall_nw = 0; // default
    wall_ne = 0; // default
    wall_sw = 0; // default
    wall_se = 0; // default
    
    // North-West Corner
    map_x = 6'd0; // default
    map_y = 5'd0; // default
    flat_index = 10'd0; // default
    map_x = pos_x >> 5; // Divide by 32
    map_y = pos_y >> 5; // Divide by 32
    flat_index = (map_y * 40) + map_x; // Calculate the flat index
    wall_nw = map[flat_index]; // Check if we should place a wall
    
    // North-East Corner
    map_x = 6'd0; // default
    map_y = 5'd0; // default
    flat_index = 10'd0; // default
    map_x = (pos_x + ENTITY_SIZE - 1) >> 5; // Divide by 32
    map_y = pos_y >> 5; // Divide by 32
    flat_index = (map_y * 40) + map_x; // Calculate the flat index
    wall_ne = map[flat_index]; // Check if we should place a wall
    
    // South-West Corner
    map_x = 6'd0; // default
    map_y = 5'd0; // default
    flat_index = 10'd0; // default
    map_x = pos_x >> 5; // Divide by 32
    map_y = (pos_y + ENTITY_SIZE - 1) >> 5; // Divide by 32
    flat_index = (map_y * 40) + map_x; // Calculate the flat index
    wall_sw = map[flat_index]; // Check if we should place a wall
    
    // South-East Corner
    map_x = 6'd0; // default
    map_y = 5'd0; // default
    flat_index = 10'd0; // default
    map_x = (pos_x + ENTITY_SIZE - 1) >> 5; // Divide by 32
    map_y = (pos_y + ENTITY_SIZE - 1) >> 5; // Divide by 32
    flat_index = (map_y * 40) + map_x; // Calculate the flat index
    wall_se = map[flat_index]; // Check if we should place a wall
    
    wall = wall_nw | wall_ne | wall_sw | wall_se; // Wall collision event indicator
    
    // Screen boundary collision
    if (pos_x < BORDER_SIZE || pos_x >= (SCREEN_WIDTH - BORDER_SIZE - ENTITY_SIZE) ||
        pos_y < BORDER_SIZE || pos_y >= (SCREEN_HEIGHT - BORDER_SIZE - ENTITY_SIZE))
    begin
        border = 1'b1;
    end else begin
        border = 1'b0;
    end
    
    collision = border | wall; 
end             
endmodule