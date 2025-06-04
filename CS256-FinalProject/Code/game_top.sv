`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: King Abdullah University of Science and Technology
// Engineer: Abril Alvarado
//           Dante Serrano Kobylyansky
// 
// Create Date: 11/05/2024 06:19:48 PM
// Design Name: Tank Game
// Module Name: game_top
// Project Name: CS 256 Final Project
// Target Devices: Nexys A7
// Tool Versions: Vivado v2020.2 (64-bit)
// Description: 
// 
// Dependencies: vga_out, game_fsm, collision_checker, drawcon, top_keyboard, song_player, seg7decimal
// 
// Revision:Final
// Revision 0.01 - File Created
// Additional Comments: This was fun
// 
//////////////////////////////////////////////////////////////////////////////////

module game_top(

      ////////////
     // INPUTS //
    ////////////
    
    input clk,
    input CPU_RESETN,
    input BTNC,
    input BTNU,
    input BTNL,
    input BTNR,
    input BTND,
    input [15:0] SW,
    input PS2_CLK,
    input PS2_DATA,
    
      /////////////
     // OUTPUTS //
    /////////////
    
    output logic [15:0] LED,
    output logic [3:0] pix_r,
    output logic [3:0] pix_g,
    output logic [3:0] pix_b,
    output hsync,
    output vsync,
    output AUD_PWM,
    output AUD_SD,
    output [6:0] SEG,
    output [7:0] AN,
    output DP
    );
    
      ///////////
     // RESET //
    ///////////
    
    wire rst; assign rst = !CPU_RESETN; // CPU_RESETN button on board is active low
    
      ////////////
     // CLOCKS //
    ////////////
    
    // Instantiate the clock divider and connect its output to the vga_out clock input using a wire.
    wire pixclk; //83.45588 MHz (should be 83.46 MHz)
    wire slow_clk; // 4.72656 MHz
    logic gclk;
    logic [15:0] game_clkdiv_counter; // 16 bit counter
    
    clk_wiz_0 clk_instance_vga_and_slow_clk(
    // Clock out ports
    .clk_out1(pixclk),
    .clk_out2(slow_clk),
    // Clock in ports
    .clk_in1(clk));
    
    always_ff @(posedge slow_clk) begin
        if (rst) begin
            game_clkdiv_counter <= 16'b0;
            gclk <= 1'b0;
        end else begin
            if (game_clkdiv_counter == 39387) begin // Half the division factor 39387
                game_clkdiv_counter <= 16'b0;
                gclk <= ~gclk; // Toggle the game clock
            end else begin
                game_clkdiv_counter <= game_clkdiv_counter + 1;
            end
        end
    end
    
      /////////
     // VGA //
    /////////
    
    logic [3:0] draw_r;
    logic [3:0] draw_g;
    logic [3:0] draw_b;
    logic [10:0] curr_x;
    logic [9:0] curr_y;
    
    // and instantiate your vga_out module inside it
    vga_out vga_out0(
    .clk(pixclk),
    .rst(rst),
    .draw_r(draw_r),
    .draw_g(draw_g),
    .draw_b(draw_b),
    .pix_r(pix_r),
    .pix_g(pix_g),
    .pix_b(pix_b),
    .hsync(hsync),
    .vsync(vsync),
    .curr_x(curr_x),
    .curr_y(curr_y)
    );
    
      /////////////////////////////////
     // Game Variable Instantiation //
    /////////////////////////////////
    
    // Pre-set loosing and winning positions for players
    localparam LOOSEX = 11'd352;
    localparam LOOSEY = 10'd608;
    localparam WINX = 11'd656;
    localparam WINY = 10'd448;
    
    // Player 1 Parameters //
    localparam P1SPEED = 4;
    localparam P1SPEEDD = 3; //diagonal speed to reduce "diagonal acceleration" 2*sqrt(2) is approximately 3
    localparam P1SIZE = 32;
    localparam P1BULLSIZE = 2;
    localparam STARTP1X = 11'd64;
    localparam STARTP1Y = 10'd64;
    localparam P1BULLSPEED = 10;
    localparam P1BULLSPEEDD = 7; //diagonal speed to reduce "diagonal acceleration" 5*sqrt(2) is approximately 7
    
    localparam COINP1X = 11'd416;
    localparam COINP1Y = 10'd640;
    localparam TIEP1X = 11'd384;
    localparam TIEP1Y = 10'd576;
    localparam SECRETP1X = 11'd1279;
    localparam SECRETP1Y = 10'd799;
    
    // Player 2 Parameters //
    localparam P2SPEED = 4;
    localparam P2SPEEDD = 3; //diagonal speed to reduce "diagonal acceleration" 2*sqrt(2) is approximately 3
    localparam P2SIZE = 32;
    localparam P2BULLSIZE = 2;
    localparam STARTP2X = 11'd1184;
    localparam STARTP2Y = 10'd704;
    localparam P2BULLSPEED = 10;
    localparam P2BULLSPEEDD = 7; //diagonal speed to reduce "diagonal acceleration" 5*sqrt(2) is approximately 7
    
    localparam COINP2X = 11'd544;
    localparam COINP2Y = 10'd640;
    localparam TIEP2X = 11'd896;
    localparam TIEP2Y = 10'd576;
    localparam SECRETP2X = 11'd1279;
    localparam SECRETP2Y = 10'd799;
    
    // Player 1 Signals //
    logic [10:0] p1pos_x;
    logic [9:0] p1pos_y;
    logic [10:0] try_p1pos_x;
    logic [9:0] try_p1pos_y;
    logic [4:0] p1button_state;
    logic [4:0] p1button_state_previous;
    logic [4:0] p1button_state_kb; 
    assign p1button_state[4:0] = {BTNU, BTND, BTNL, BTNR, BTNC} | {p1button_state_kb[4:0]};
    logic [2:0] p1_rot;
    logic [10:0] p1bullpos_x;
    logic [9:0] p1bullpos_y;
    logic [10:0] try_p1bullpos_x;
    logic [9:0] try_p1bullpos_y;
    logic [2:0] p1_bullrot;
    logic p1bull; // bullet visibility toggle (also used for reload logic)
    logic p1collision;
    logic p1bullcollision;
    logic p1terraincollision;
    
    // Player 2 Signals //
    logic [10:0] p2pos_x;
    logic [9:0] p2pos_y;
    logic [10:0] try_p2pos_x;
    logic [9:0] try_p2pos_y;
    logic [4:0] p2button_state;
    logic [4:0] p2button_state_previous;
    logic [4:0] p2button_state_kb; 
    assign p2button_state[4:0] = {SW[15:11]} | {p2button_state_kb[4:0]};
    logic [2:0] p2_rot;
    logic [10:0] p2bullpos_x;
    logic [9:0] p2bullpos_y;
    logic [10:0] try_p2bullpos_x;
    logic [9:0] try_p2bullpos_y;
    logic [2:0] p2_bullrot;
    logic p2bull; // bullet visibility toggle (also used for reload logic)
    logic p2collision;
    logic p2bullcollision;
    logic p2terraincoll;
    
    // Interactions //
    logic p1_bullet_impact_p2; //
    logic p2_bullet_impact_p1; //
    logic pplayer_collision; //
    
    // Map array: A 40 by 25 grid of 32px blocks flattened into 1000 bits
    logic [999:0] map0;
    
      ////////////////////////
     // Game State Control //
    ////////////////////////
    
    // FSM Signals //
    logic insert_coin_screen;
    logic game_running;
    logic p1_wins_screen;
    logic p2_wins_screen;
    logic tie_screen;
    logic secret_screen;
    logic game_start;
    logic game_initialized;
    
    logic p1_win_condition;
    logic p2_win_condition;
    logic tie_condition;

    // Instantiate FSM //
    game_fsm fsm (
        // Inputs //
        .clk(clk),
        .rst(rst),
        .coin_inserted(SW[0]), // Simulate coin insertion with switch 0
        .p1_wins(p1_win_condition),
        .p2_wins(p2_win_condition),
        .tie_game(SW[2] | tie_condition), // Simulate tie with switch 1
        .replay(SW[1]),
        .secret(SW[4]),
        .game_initialized(game_initialized),
        // Outputs //
        .insert_coin_screen(insert_coin_screen),
        .game_running(game_running),
        .p1_wins_screen(p1_wins_screen),
        .p2_wins_screen(p2_wins_screen),
        .tie_screen(tie_screen),
        .secret_screen(secret_screen),
        .game_start(game_start)
    );

      //////////////////////
     // Collision Checks //
    //////////////////////
    
    //// Terrain Collision ////
    
    // Collision Map could in theory be different from the drawn map, i.e. "invisible" wallks
    
    // A rare bug can occur when moving into walls. The collision check with fail, causing the player to get
    // kicked back. However, if the player times correctly the key presses, he can change his movement for the next
    // cycle to parallel to the wall, causing the position logic to incorrectly kick him parallel to the wall indefinitely,
    // as long as the player presses the direction key (even overflowing and looping arround the screen). This is a "frame-
    // perfect" trick that has been patched :) This is why we need 
    
    // Player 1 //
    collision_checker #(
    .ENTITY_SIZE(P1SIZE) // Player size
    ) p1collision_checker (
    .pos_x(try_p1pos_x),
    .pos_y(try_p1pos_y),
    .map(map0),  // Map array
    .collision(p1terraincollision)  // Collision output
    );
    
    // Player 1 Bullet //
    collision_checker #(
    .ENTITY_SIZE(P1BULLSIZE) // Player size
    ) p1bullcollision_checker (
    .pos_x(try_p1bullpos_x),
    .pos_y(try_p1bullpos_y),
    .map(map0),  // Map array
    .collision(p1bullcollision)  // Collision output
    );
    
    // Player 2 //
    collision_checker #(
    .ENTITY_SIZE(P2SIZE) // Player size
    ) p2collision_checker (
    .pos_x(try_p2pos_x),
    .pos_y(try_p2pos_y),
    .map(map0),  // Map array
    .collision(p2terraincoll)  // Collision output
    );
    
    // Player 2 Bullet //
    collision_checker #(
    .ENTITY_SIZE(P2BULLSIZE) // Player size
    ) p2bullcollision_checker (
    .pos_x(try_p2bullpos_x),
    .pos_y(try_p2bullpos_y),
    .map(map0),  // Map array
    .collision(p2bullcollision)  // Collision output
    );
    
    //// Bullet Impact ////
    
    // Needs to be synchronous as it is used for state change transition
    always_ff @(posedge gclk) begin
        if (rst) begin
            p1_bullet_impact_p2 <= 0;
            p2_bullet_impact_p1 <= 0;
            p1_win_condition <= 0;
            p2_win_condition <= 0;
        end else begin
            // Player 1 bullet impacting Player 2 //
            p1_bullet_impact_p2 <= (p1bull && // Bullet is active
                                   p1bullpos_x + P1BULLSIZE > p2pos_x && // Right edge of bullet crosses left edge of P2
                                   p1bullpos_x < p2pos_x + P2SIZE && // Left edge of bullet crosses right edge of P2
                                   p1bullpos_y + P1BULLSIZE > p2pos_y && // Bottom edge of bullet crosses top edge of P2
                                   p1bullpos_y < p2pos_y + P2SIZE); // Top edge of bullet crosses bottom edge of P2
        
            // Player 2 bullet impacting Player 1 //
            p2_bullet_impact_p1 <= (p2bull && // Bullet is active
                                   p2bullpos_x + P2BULLSIZE > p1pos_x && // Right edge of bullet crosses left edge of P1
                                   p2bullpos_x < p1pos_x + P1SIZE && // Left edge of bullet crosses right edge of P1
                                   p2bullpos_y + P2BULLSIZE > p1pos_y && // Bottom edge of bullet crosses top edge of P1
                                   p2bullpos_y < p1pos_y + P1SIZE); // Top edge of bullet crosses bottom edge of P1
                                   
            p1_win_condition <= p1_bullet_impact_p2;
            p2_win_condition <= p2_bullet_impact_p1;
        end
    end
    
    //// Player-Player Collision ////
    
    always_comb begin
        pplayer_collision = (try_p1pos_x + P1SIZE > try_p2pos_x && // Right edge of P1 crosses left edge of P2
                             try_p1pos_x < try_p2pos_x + P2SIZE && // Left edge of P1 crosses right edge of P2
                             try_p1pos_y + P1SIZE > try_p2pos_y && // Bottom edge of P1 crosses top edge of P2
                             try_p1pos_y < try_p2pos_y + P2SIZE); // Top edge of P1 crosses bottom edge of P2
    end
    
    //// Player Collision Assignment //
    
    assign p2collision = pplayer_collision | p2terraincoll;
    assign p1collision = pplayer_collision | p1terraincollision;
    
    
        ////////////////////////
       ////////////////////////
      //// Position Logic ////
     ////////////////////////
    ////////////////////////
    
      ////////////////////////////////
     // Game Start Reset Positions //
    ////////////////////////////////
    
    always_ff @(posedge gclk) begin
        if( rst | !game_start) begin
            game_initialized <= 0;
        end else begin
            game_initialized <=1;
        end
    end
            
    
      //////////////
     // Player 1 //
    //////////////
    
    // Decide what to do under each button-press combination
    always_ff @(posedge gclk) begin
        if (rst | game_start) begin //  | BTNC for resetting position
            // Reset positions
            p1button_state_previous <= 5'b00000;
            p1pos_x <= STARTP1X;
            p1pos_y <= STARTP1Y;
            try_p1pos_x <= STARTP1X;
            try_p1pos_y <= STARTP1Y;
            p1_rot <= 3'b000;
            p1bullpos_x <= 11'd0;
            p1bullpos_y <= 10'd0;
            try_p1bullpos_x <= 11'd0;
            try_p1bullpos_y <= 10'd0;
            p1_bullrot <= 3'b000;
            p1bull <= 0;
            //p1collision <= 0;
            //p1bullcollision <= 0;
            //p1terraincollision <= 0;
            //p1_bullet_impact_p2 <= 0;
        end else begin
            if (game_running) begin
                p1button_state_previous <= p1button_state;
                case (p1button_state) // {BTNU, BTND, BTNL, BTNR, BTNC}
                    5'b10000: begin // Try Move up
                        p1_rot <= 3'b000;
                        try_p1pos_y <= p1pos_y - P1SPEED;
                    end
                    5'b00010: begin // Try Move right
                        p1_rot <= 3'b001;
                        try_p1pos_x <= p1pos_x + P1SPEED;
                    end
                    5'b01000: begin // Try Move down
                        p1_rot <= 3'b010;
                        try_p1pos_y <= p1pos_y + P1SPEED;
                    end
                    5'b00100: begin // Try Move left
                        p1_rot <= 3'b011;
                        try_p1pos_x <= p1pos_x - P1SPEED;
                    end
                    5'b10010: begin // Try Move up-right
                        p1_rot <= 3'b100;
                        try_p1pos_x <= p1pos_x + P1SPEEDD;
                        try_p1pos_y <= p1pos_y - P1SPEEDD;
                    end
                    5'b01010: begin // Try Move down-right
                        p1_rot <= 3'b101;
                        try_p1pos_x <= p1pos_x + P1SPEEDD;
                        try_p1pos_y <= p1pos_y + P1SPEEDD;
                    end
                    5'b01100: begin // Try Move down-left
                        p1_rot <= 3'b110;
                        try_p1pos_x <= p1pos_x - P1SPEEDD;
                        try_p1pos_y <= p1pos_y + P1SPEEDD;
                    end
                    5'b10100: begin // Try Move up-left
                        p1_rot <= 3'b111;
                        try_p1pos_x <= p1pos_x - P1SPEEDD;
                        try_p1pos_y <= p1pos_y - P1SPEEDD;
                    end
                    default: begin
                        // Don't change anything
                        p1_rot <= p1_rot;
                        try_p1pos_x <= p1pos_x;
                        try_p1pos_y <= p1pos_y;
                    end
                endcase
                case (p1button_state_previous) // {BTNU, BTND, BTNL, BTNR, BTNC}
                    5'b10000: begin // Move up
                        if (!p1collision) begin // check for collision event
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_y <= p1pos_y + 2 * P1SPEED; // Kick back down
                            try_p1pos_y <= p1pos_y + 2 * P1SPEED;
                        end
                    end
                    5'b00010: begin // Move right
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                        end else begin
                            p1pos_x <= p1pos_x - 2 * P1SPEED; // Kick back left
                            try_p1pos_x <= p1pos_x - 2 * P1SPEED;
                        end
                    end
                    5'b01000: begin // Move down
                        if (!p1collision) begin // check for collision event
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_y <= p1pos_y - 2 * P1SPEED; // Kick back up
                            try_p1pos_y <= p1pos_y - 2 * P1SPEED;
                        end
                    end
                    5'b00100: begin // Move left
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                        end else begin
                            p1pos_x <= p1pos_x + 2 * P1SPEED; // Kick back right
                            try_p1pos_x <= p1pos_x + 2 * P1SPEED;
                        end
                    end
                    5'b10010: begin // Move up-right
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_x <= p1pos_x - 2 * P1SPEEDD;
                            p1pos_y <= p1pos_y + 2 * P1SPEEDD;
                            try_p1pos_x <= p1pos_x - 2 * P1SPEEDD;
                            try_p1pos_y <= p1pos_y + 2 * P1SPEEDD;
                        end
                    end
                    5'b01010: begin // Move down-right
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_x <= p1pos_x - 2 * P1SPEEDD;
                            p1pos_y <= p1pos_y - 2 * P1SPEEDD;
                            try_p1pos_x <= p1pos_x - 2 * P1SPEEDD;
                            try_p1pos_y <= p1pos_y - 2 * P1SPEEDD;
                        end
                    end
                    5'b01100: begin // Move down-left
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_x <= p1pos_x + 2 * P1SPEEDD;
                            p1pos_y <= p1pos_y - 2 * P1SPEEDD;
                            try_p1pos_x <= p1pos_x + 2 * P1SPEEDD;
                            try_p1pos_y <= p1pos_y - 2 * P1SPEEDD;
                        end
                    end
                    5'b10100: begin // Move up-left
                        if (!p1collision) begin // check for collision event
                            p1pos_x <= try_p1pos_x;
                            p1pos_y <= try_p1pos_y;
                        end else begin
                            p1pos_x <= p1pos_x + 2 * P1SPEEDD;
                            p1pos_y <= p1pos_y + 2 * P1SPEEDD;
                            try_p1pos_x <= p1pos_x + 2 * P1SPEEDD;
                            try_p1pos_y <= p1pos_y + 2 * P1SPEEDD;
                        end
                    end
                    default: begin
                        // No movement
                        p1pos_x <= p1pos_x;
                        p1pos_y <= p1pos_y;
                    end
                endcase
                if( p1button_state[0] && !p1bull) begin // if fire key is pressed and no bullet is visible, spawn new bullet
                    p1_bullrot <= p1_rot;
                    p1bull <= 1;
                    case (p1_rot) // assign bullet spawn position to the end of the barrel based on player direction
                        3'b000: begin // 0° rotation (facing up)
                            p1bullpos_x <= p1pos_x + (P1SIZE >> 1);
                            p1bullpos_y <= p1pos_y;
                            try_p1bullpos_x <= p1pos_x + (P1SIZE >> 1);
                            try_p1bullpos_y <= p1pos_y;
                        end
                        3'b001: begin // 90° rotation (facing right)
                            p1bullpos_x <= p1pos_x + P1SIZE;
                            p1bullpos_y <= p1pos_y + (P1SIZE >> 1);
                            try_p1bullpos_x <= p1pos_x + P1SIZE;
                            try_p1bullpos_y <= p1pos_y + (P1SIZE >> 1);
                        end
                        3'b010: begin // 180° rotation (facing down)
                            p1bullpos_x <= p1pos_x + (P1SIZE >> 1);
                            p1bullpos_y <= p1pos_y + P1SIZE;
                            try_p1bullpos_x <= p1pos_x + (P1SIZE >> 1);
                            try_p1bullpos_y <= p1pos_y + P1SIZE;
                        end
                        3'b011: begin // 270° rotation (facing left)
                            p1bullpos_x <= p1pos_x;
                            p1bullpos_y <= p1pos_y + (P1SIZE >> 1);
                            try_p1bullpos_x <= p1pos_x;
                            try_p1bullpos_y <= p1pos_y + (P1SIZE >> 1);
                        end
                        3'b100: begin // 45° rotation (facing up-right) (45° memory)
                            p1bullpos_x <= p1pos_x + P1SIZE;
                            p1bullpos_y <= p1pos_y;
                            try_p1bullpos_x <= p1pos_x + P1SIZE;
                            try_p1bullpos_y <= p1pos_y;
                        end
                        3'b101: begin // 135° rotation (facing down-right)
                            p1bullpos_x <= p1pos_x + P1SIZE;
                            p1bullpos_y <= p1pos_y + P1SIZE;
                            try_p1bullpos_x <= p1pos_x + P1SIZE;
                            try_p1bullpos_y <= p1pos_y + P1SIZE;
                        end
                        3'b110: begin // 225° rotation (facing down-left)
                            p1bullpos_x <= p1pos_x;
                            p1bullpos_y <= p1pos_y + P1SIZE;
                            try_p1bullpos_x <= p1pos_x;
                            try_p1bullpos_y <= p1pos_y + P1SIZE;
                        end
                        3'b111: begin // 315° rotation (facing up-left)
                            p1bullpos_x <= p1pos_x;
                            p1bullpos_y <= p1pos_y;
                            try_p1bullpos_x <= p1pos_x;
                            try_p1bullpos_y <= p1pos_y;
                        end
                        default: begin
                            p1_bullrot <= p1_bullrot;
                            p1bullpos_x <= 11'd0;
                            p1bullpos_y <= 10'd0;
                            try_p1bullpos_x <= 11'd0;
                            try_p1bullpos_y <= 10'd0;
                        end
                    endcase
                end else begin // if bullet is visible
                    if (p1bullcollision | p1_bullet_impact_p2) begin // if bullet has not collided
                        p1bull <= 0;
                        p1_bullrot <= 3'b000;
                        p1bullpos_x <= 11'd0;
                        p1bullpos_y <= 10'd0;
                        try_p1bullpos_x <= 11'd0;
                        try_p1bullpos_y <= 10'd0;
                    end else begin // else move to tried position if collision was not detected.
                        p1bull <= p1bull;
                        p1_bullrot <= p1_bullrot;
                        p1bullpos_x <= try_p1bullpos_x;
                        p1bullpos_y <= try_p1bullpos_y;
                        case (p1_bullrot) // assign bullet movement
                            3'b000: begin // 0° rotation (facing up)
                                try_p1bullpos_x <= p1bullpos_x;
                                try_p1bullpos_y <= p1bullpos_y - P1BULLSPEED;
                            end
                            3'b001: begin // 90° rotation (facing right)
                                try_p1bullpos_x <= p1bullpos_x + P1BULLSPEED;
                                try_p1bullpos_y <= p1bullpos_y;
                            end
                            3'b010: begin // 180° rotation (facing down)
                                try_p1bullpos_x <= p1bullpos_x;
                                try_p1bullpos_y <= p1bullpos_y + P1BULLSPEED;
                            end
                            3'b011: begin // 270° rotation (facing left)
                                try_p1bullpos_x <= p1bullpos_x - P1BULLSPEED;
                                try_p1bullpos_y <= p1bullpos_y;
                            end
                            3'b100: begin // 45° rotation (facing up-right) (45° memory)
                                try_p1bullpos_x <= p1bullpos_x + P1BULLSPEEDD;
                                try_p1bullpos_y <= p1bullpos_y - P1BULLSPEEDD;
                            end
                            3'b101: begin // 135° rotation (facing down-right)
                                try_p1bullpos_x <= p1bullpos_x + P1BULLSPEEDD;
                                try_p1bullpos_y <= p1bullpos_y + P1BULLSPEEDD;
                            end
                            3'b110: begin // 225° rotation (facing down-left)
                                try_p1bullpos_x <= p1bullpos_x - P1BULLSPEEDD;
                                try_p1bullpos_y <= p1bullpos_y + P1BULLSPEEDD;
                            end
                            3'b111: begin // 315° rotation (facing up-left)
                                try_p1bullpos_x <= p1bullpos_x - P1BULLSPEEDD;
                                try_p1bullpos_y <= p1bullpos_y - P1BULLSPEEDD;
                            end
                            default: begin
                            end
                        endcase
                    end
                end
            end else begin
                p1bullpos_x <= 11'd0;
                p1bullpos_y <= 10'd0;
                try_p1bullpos_x <= 11'd0;
                try_p1bullpos_y <= 10'd0;
                p1_bullrot <= 3'b000;
                p1bull <= 0;
                if (insert_coin_screen) begin
                    p1pos_x <= COINP1X;
                    p1pos_y <= COINP1Y;
                    try_p1pos_x <= COINP1X;
                    try_p1pos_y <= COINP1Y;
                    p1_rot <= 3'b001; // facing right
                end else begin
                    if (tie_screen) begin
                        p1pos_x <= TIEP1X;
                        p1pos_y <= TIEP1Y;
                        try_p1pos_x <= TIEP1X;
                        try_p1pos_y <= TIEP1Y;
                        p1_rot <= 3'b000; // facing up
                    end else begin
                        if (p1_wins_screen) begin
                            p1pos_x <= WINX;
                            p1pos_y <= WINY;
                            try_p1pos_x <= WINX;
                            try_p1pos_y <= WINY;
                            p1_rot <= 3'b000; // facing up
                        end else begin
                            if (p2_wins_screen) begin
                                p1pos_x <= LOOSEX;
                                p1pos_y <= LOOSEY;
                                try_p1pos_x <= LOOSEX;
                                try_p1pos_y <= LOOSEY;
                                p1_rot <= 3'b010; // facing down
                            end else begin
                                if (secret_screen) begin
                                    p1pos_x <= SECRETP1X;
                                    p1pos_y <= SECRETP1Y;
                                    try_p1pos_x <= SECRETP1X;
                                    try_p1pos_y <= SECRETP1Y;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
      //////////////
     // Player 2 //
    //////////////
    
    // Decide what to do under each button-press combination
    always_ff @(posedge gclk) begin
        if (rst | game_start) begin //  | BTNC for resetting position
            // Reset positions
            p2button_state_previous <= 5'b00000;
            p2pos_x <= STARTP2X;
            p2pos_y <= STARTP2Y;
            try_p2pos_x <= STARTP2X;
            try_p2pos_y <= STARTP2Y;
            p2_rot <= 3'b000;
            p2bullpos_x <= 11'd0;
            p2bullpos_y <= 10'd0;
            try_p2bullpos_x <= 11'd0;
            try_p2bullpos_y <= 10'd0;
            p2_bullrot <= 3'b000;
            p2bull <= 0;
            //p1collision <= 0;
            //p1bullcollision <= 0;
            //p1terraincollision <= 0;
            //p2_bullet_impact_p1 <= 0;
        end else begin
            if (game_running) begin
                p2button_state_previous <= p2button_state;
                case (p2button_state) // {BTNU, BTND, BTNL, BTNR, BTNC}
                    5'b10000: begin // Try Move up
                        p2_rot <= 3'b000;
                        try_p2pos_y <= p2pos_y - P2SPEED;
                    end
                    5'b00010: begin // Try Move right
                        p2_rot <= 3'b001;
                        try_p2pos_x <= p2pos_x + P2SPEED;
                    end
                    5'b01000: begin // Try Move down
                        p2_rot <= 3'b010;
                        try_p2pos_y <= p2pos_y + P2SPEED;
                    end
                    5'b00100: begin // Try Move left
                        p2_rot <= 3'b011;
                        try_p2pos_x <= p2pos_x - P2SPEED;
                    end
                    5'b10010: begin // Try Move up-right
                        p2_rot <= 3'b100;
                        try_p2pos_x <= p2pos_x + P2SPEEDD;
                        try_p2pos_y <= p2pos_y - P2SPEEDD;
                    end
                    5'b01010: begin // Try Move down-right
                        p2_rot <= 3'b101;
                        try_p2pos_x <= p2pos_x + P2SPEEDD;
                        try_p2pos_y <= p2pos_y + P2SPEEDD;
                    end
                    5'b01100: begin // Try Move down-left
                        p2_rot <= 3'b110;
                        try_p2pos_x <= p2pos_x - P2SPEEDD;
                        try_p2pos_y <= p2pos_y + P2SPEEDD;
                    end
                    5'b10100: begin // Try Move up-left
                        p2_rot <= 3'b111;
                        try_p2pos_x <= p2pos_x - P2SPEEDD;
                        try_p2pos_y <= p2pos_y - P2SPEEDD;
                    end
                    default: begin
                        // Don't change anything
                        p2_rot <= p2_rot;
                        try_p2pos_x <= p2pos_x;
                        try_p2pos_y <= p2pos_y;
                    end
                endcase
                case (p2button_state_previous) // {BTNU, BTND, BTNL, BTNR, BTNC}
                    5'b10000: begin // Move up
                        if (!p2collision) begin // check for collision event
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_y <= p2pos_y + 2 * P2SPEED; // Kick back down
                            try_p2pos_y <= p2pos_y + 2 * P2SPEED;
                        end
                    end
                    5'b00010: begin // Move right
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                        end else begin
                            p2pos_x <= p2pos_x - 2 * P2SPEED; // Kick back left
                            try_p2pos_x <= p2pos_x - 2 * P2SPEED;
                        end
                    end
                    5'b01000: begin // Move down
                        if (!p2collision) begin // check for collision event
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_y <= p2pos_y - 2 * P2SPEED; // Kick back up
                            try_p2pos_y <= p2pos_y - 2 * P2SPEED;
                        end
                    end
                    5'b00100: begin // Move left
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                        end else begin
                            p2pos_x <= p2pos_x + 2 * P2SPEED; // Kick back right
                            try_p2pos_x <= p2pos_x + 2 * P2SPEED;
                        end
                    end
                    5'b10010: begin // Move up-right
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_x <= p2pos_x - 2 * P2SPEEDD;
                            p2pos_y <= p2pos_y + 2 * P2SPEEDD;
                            try_p2pos_x <= p2pos_x - 2 * P2SPEEDD;
                            try_p2pos_y <= p2pos_y + 2 * P2SPEEDD;
                        end
                    end
                    5'b01010: begin // Move down-right
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_x <= p2pos_x - 2 * P2SPEEDD;
                            p2pos_y <= p2pos_y - 2 * P2SPEEDD;
                            try_p2pos_x <= p2pos_x - 2 * P2SPEEDD;
                            try_p2pos_y <= p2pos_y - 2 * P2SPEEDD;
                        end
                    end
                    5'b01100: begin // Move down-left
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_x <= p2pos_x + 2 * P2SPEEDD;
                            p2pos_y <= p2pos_y - 2 * P2SPEEDD;
                            try_p2pos_x <= p2pos_x + 2 * P2SPEEDD;
                            try_p2pos_y <= p2pos_y - 2 * P2SPEEDD;
                        end
                    end
                    5'b10100: begin // Move up-left
                        if (!p2collision) begin // check for collision event
                            p2pos_x <= try_p2pos_x;
                            p2pos_y <= try_p2pos_y;
                        end else begin
                            p2pos_x <= p2pos_x + 2 * P2SPEEDD;
                            p2pos_y <= p2pos_y + 2 * P2SPEEDD;
                            try_p2pos_x <= p2pos_x + 2 * P2SPEEDD;
                            try_p2pos_y <= p2pos_y + 2 * P2SPEEDD;
                        end
                    end
                    default: begin
                        // No movement
                        p2pos_x <= p2pos_x;
                        p2pos_y <= p2pos_y;
                    end
                endcase
                if( p2button_state[0] && !p2bull) begin // if fire key is pressed and no bullet is visible, spawn new bullet
                    p2_bullrot <= p2_rot;
                    p2bull <= 1;
                    case (p2_rot) // assign bullet spawn position to the end of the barrel based on player direction
                        3'b000: begin // 0° rotation (facing up)
                            p2bullpos_x <= p2pos_x + (P2SIZE >> 1);
                            p2bullpos_y <= p2pos_y;
                            try_p2bullpos_x <= p2pos_x + (P2SIZE >> 1);
                            try_p2bullpos_y <= p2pos_y;
                        end
                        3'b001: begin // 90° rotation (facing right)
                            p2bullpos_x <= p2pos_x + P2SIZE;
                            p2bullpos_y <= p2pos_y + (P2SIZE >> 1);
                            try_p2bullpos_x <= p2pos_x + P2SIZE;
                            try_p2bullpos_y <= p2pos_y + (P2SIZE >> 1);
                        end
                        3'b010: begin // 180° rotation (facing down)
                            p2bullpos_x <= p2pos_x + (P2SIZE >> 1);
                            p2bullpos_y <= p2pos_y + P2SIZE;
                            try_p2bullpos_x <= p2pos_x + (P2SIZE >> 1);
                            try_p2bullpos_y <= p2pos_y + P2SIZE;
                        end
                        3'b011: begin // 270° rotation (facing left)
                            p2bullpos_x <= p2pos_x;
                            p2bullpos_y <= p2pos_y + (P2SIZE >> 1);
                            try_p2bullpos_x <= p2pos_x;
                            try_p2bullpos_y <= p2pos_y + (P2SIZE >> 1);
                        end
                        3'b100: begin // 45° rotation (facing up-right) (45° memory)
                            p2bullpos_x <= p2pos_x + P2SIZE;
                            p2bullpos_y <= p2pos_y;
                            try_p2bullpos_x <= p2pos_x + P2SIZE;
                            try_p2bullpos_y <= p2pos_y;
                        end
                        3'b101: begin // 135° rotation (facing down-right)
                            p2bullpos_x <= p2pos_x + P2SIZE;
                            p2bullpos_y <= p2pos_y + P2SIZE;
                            try_p2bullpos_x <= p2pos_x + P2SIZE;
                            try_p2bullpos_y <= p2pos_y + P2SIZE;
                        end
                        3'b110: begin // 225° rotation (facing down-left)
                            p2bullpos_x <= p2pos_x;
                            p2bullpos_y <= p2pos_y + P2SIZE;
                            try_p2bullpos_x <= p2pos_x;
                            try_p2bullpos_y <= p2pos_y + P2SIZE;
                        end
                        3'b111: begin // 315° rotation (facing up-left)
                            p2bullpos_x <= p2pos_x;
                            p2bullpos_y <= p2pos_y;
                            try_p2bullpos_x <= p2pos_x;
                            try_p2bullpos_y <= p2pos_y;
                        end
                        default: begin
                            p2_bullrot <= p2_bullrot;
                            p2bullpos_x <= 11'd0;
                            p2bullpos_y <= 10'd0;
                            try_p2bullpos_x <= 11'd0;
                            try_p2bullpos_y <= 10'd0;
                        end
                    endcase
                end else begin // if bullet is visible
                    if (p2bullcollision | p2_bullet_impact_p1) begin // if bullet has not collided
                        p2bull <= 0;
                        p2_bullrot <= 3'b000;
                        p2bullpos_x <= 11'd0;
                        p2bullpos_y <= 10'd0;
                        try_p2bullpos_x <= 11'd0;
                        try_p2bullpos_y <= 10'd0;
                    end else begin // else move to tried position if collision was not detected.
                        p2bull <= p2bull;
                        p2_bullrot <= p2_bullrot;
                        p2bullpos_x <= try_p2bullpos_x;
                        p2bullpos_y <= try_p2bullpos_y;
                        case (p2_bullrot) // assign bullet movement
                            3'b000: begin // 0° rotation (facing up)
                                try_p2bullpos_x <= p2bullpos_x;
                                try_p2bullpos_y <= p2bullpos_y - P2BULLSPEED;
                            end
                            3'b001: begin // 90° rotation (facing right)
                                try_p2bullpos_x <= p2bullpos_x + P2BULLSPEED;
                                try_p2bullpos_y <= p2bullpos_y;
                            end
                            3'b010: begin // 180° rotation (facing down)
                                try_p2bullpos_x <= p2bullpos_x;
                                try_p2bullpos_y <= p2bullpos_y + P2BULLSPEED;
                            end
                            3'b011: begin // 270° rotation (facing left)
                                try_p2bullpos_x <= p2bullpos_x - P2BULLSPEED;
                                try_p2bullpos_y <= p2bullpos_y;
                            end
                            3'b100: begin // 45° rotation (facing up-right) (45° memory)
                                try_p2bullpos_x <= p2bullpos_x + P2BULLSPEEDD;
                                try_p2bullpos_y <= p2bullpos_y - P2BULLSPEEDD;
                            end
                            3'b101: begin // 135° rotation (facing down-right)
                                try_p2bullpos_x <= p2bullpos_x + P2BULLSPEEDD;
                                try_p2bullpos_y <= p2bullpos_y + P2BULLSPEEDD;
                            end
                            3'b110: begin // 225° rotation (facing down-left)
                                try_p2bullpos_x <= p2bullpos_x - P2BULLSPEEDD;
                                try_p2bullpos_y <= p2bullpos_y + P2BULLSPEEDD;
                            end
                            3'b111: begin // 315° rotation (facing up-left)
                                try_p2bullpos_x <= p2bullpos_x - P2BULLSPEEDD;
                                try_p2bullpos_y <= p2bullpos_y - P2BULLSPEEDD;
                            end
                            default: begin
                            end
                        endcase
                    end
                end
            end else begin
                p2bullpos_x <= 11'd0;
                p2bullpos_y <= 10'd0;
                try_p2bullpos_x <= 11'd0;
                try_p2bullpos_y <= 10'd0;
                p2_bullrot <= 3'b000;
                p2bull <= 0;
                if (insert_coin_screen) begin
                    p2pos_x <= COINP2X;
                    p2pos_y <= COINP2Y;
                    try_p2pos_x <= COINP2X;
                    try_p2pos_y <= COINP2Y;
                    p2_rot <= 3'b011; // facing left
                end else begin
                    if (tie_screen) begin
                        p2pos_x <= TIEP2X;
                        p2pos_y <= TIEP2Y;
                        try_p2pos_x <= TIEP2X;
                        try_p2pos_y <= TIEP2Y;
                        p2_rot <= 3'b000; // facing up
                    end else begin
                        if (p1_wins_screen) begin
                            p2pos_x <= LOOSEX;
                            p2pos_y <= LOOSEY;
                            try_p2pos_x <= LOOSEX;
                            try_p2pos_y <= LOOSEY;
                            p2_rot <= 3'b010; // facing down
                        end else begin
                            if (p2_wins_screen) begin
                                p2pos_x <= WINX;
                                p2pos_y <= WINY;
                                try_p2pos_x <= WINX;
                                try_p2pos_y <= WINY;
                                p2_rot <= 3'b000; // facing up
                            end else begin
                                if (secret_screen) begin
                                    p2pos_x <= SECRETP2X;
                                    p2pos_y <= SECRETP2Y;
                                    try_p2pos_x <= SECRETP2X;
                                    try_p2pos_y <= SECRETP2Y;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
      ////////////////
     // Map Select //
    ////////////////
    
    always_comb begin
        // Default value
        map0 = {
            40'b0000000000000000000110000000000000000000,
            40'b0000000000000000000110000000000000000000,
            40'b0000000000000000000000000000000000000000,
            40'b0000000001000000000000000000000000000000,
            40'b0000000001000000000000000000000010000000,
            40'b0000000000000000000000000000000010000000,
            40'b0000000000000011100000011100000010000000,
            40'b0000000000000010000000000100000010000000,
            40'b0000000000000010000000000100000011110000,
            40'b0000000000000000000000000000000000000000,
            40'b0000000000000000000000000000000000000000,
            40'b0000000000110000000000000000000000000000,
            40'b0000000000110000000000000000110000000000,
            40'b0000000000000000000000000000110000000000,
            40'b0000000000000000000000000000000000000000,
            40'b0000000000000000000000000000000000000000,
            40'b0000111100000010000000000100000000000000,
            40'b0000000100000010000000000100000000000000,
            40'b0000000100000011100000011100000000000000,
            40'b0000000100000000000000000000000000000000,
            40'b0000000100000000000000000000001000000000,
            40'b0000000000000000000000000000001000000000,
            40'b0000000000000000000000000000000000000000,
            40'b0000000000000000000110000000000000000000,
            40'b0000000000000000000110000000000000000000
        };
        if (game_running) begin
            // Display "Game Map" screen
            //LED[0] = 1;
            //LED[15:1] = 15'd0;
            map0 = {
                40'b0000000000000000000110000000000000000000,
                40'b0000000000000000000110000000000000000000,
                40'b0000000000000000000000000000000000000000,
                40'b0000000001000000000000000000000000000000,
                40'b0000000001000000000000000000000010000000,
                40'b0000000000000000000000000000000010000000,
                40'b0000000000000011100000011100000010000000,
                40'b0000000000000010000000000100000010000000,
                40'b0000000000000010000000000100000011110000,
                40'b0000000000000000000000000000000000000000,
                40'b0000000000000000000000000000000000000000,
                40'b0000000000110000000000000000000000000000,
                40'b0000000000110000000000000000110000000000,
                40'b0000000000000000000000000000110000000000,
                40'b0000000000000000000000000000000000000000,
                40'b0000000000000000000000000000000000000000,
                40'b0000111100000010000000000100000000000000,
                40'b0000000100000010000000000100000000000000,
                40'b0000000100000011100000011100000000000000,
                40'b0000000100000000000000000000000000000000,
                40'b0000000100000000000000000000001000000000,
                40'b0000000000000000000000000000001000000000,
                40'b0000000000000000000000000000000000000000,
                40'b0000000000000000000110000000000000000000,
                40'b0000000000000000000110000000000000000000
            };    
        end else if (insert_coin_screen) begin
            // Display "Insert Coin" screen
            //LED[1] = 1;
            //{LED[15:2],LED[0]} = 15'd0;
            map0 = {
                40'b1111111111111111111111111111111111111111,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000100101110111101110000000000001,
                40'b1000000000110100100100100010000000000001,
                40'b1000000000111100100100100010000011100001,
                40'b1000000000101100100100100010000100010001,
                40'b1000000000100101110111101110001001001001,
                40'b1000000000000000000000000000001010101001,
                40'b1000000000000000000000000000001010101001,
                40'b1000100101011101110100101110001001001001,
                40'b1000100011000101000110100100000100010001,
                40'b1000100111001101110111100100000011100001,
                40'b1000100101000100010101100100000000000001,
                40'b1001110011011101110100101110000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1000000000000000000000000000000000000001,
                40'b1111111111111111111111111111111111111111
            };

        end else if (p1_wins_screen) begin
            // Display "Player 1 Wins" screen
            //LED[2] = 1;
            //{LED[15:3],LED[1:0]} = 15'd0;
            map0 = {
                40'b1111111111111111111111111111111111111111,
                40'b1010101010101010011111100101010101010101,
                40'b1101010101010101011111101010101010101011,
                40'b1010101010101010000110000101010101010101,
                40'b1101000000000000001111000000000000001011,
                40'b1010001111000000010001100000001001000101,
                40'b1100001001000000111011110000001111000011,
                40'b1000000000000001111001111000000000000001,
                40'b1100001001000010111011110100001001000011,
                40'b1000001001000001111111111000001001000001,
                40'b1100000000000000110000110000000000000011,
                40'b1000000000000000000000000000000000000001,
                40'b1101101111010001011101000100111100001011,
                40'b1001101000011001001001101100010000001001,
                40'b1100001000011101001001111100010001111011,
                40'b1001101111010111001001010100010101001001,
                40'b1101100001010011001001010100011001001011,
                40'b1001101111010001011101000100010001111001,
                40'b1100000000000000000000000000000000000011,
                40'b1010000000000000000000000000000000000101,
                40'b1101000000000000000000000000000000001011,
                40'b1010101010101010101001010101010101010101,
                40'b1101010101010101010110101010101010101011,
                40'b1010101010101010101001010101010101010101,
                40'b1111111111111111111111111111111111111111
            };
        end else if (p2_wins_screen) begin
            // Display "Player 2 Wins" screen
            //LED[3] = 1;
            //{LED[15:4],LED[2:0]} = 15'd0;
            map0 = {
                40'b1111111111111111111111111111111111111111,
                40'b1010101010101010011111100101010101010101,
                40'b1101010101010101011111101010101010101011,
                40'b1010101010101010000110000101010101010101,
                40'b1101000000000000001111000000000000001011,
                40'b1010001111000000010001100000001001000101,
                40'b1100001001000000111011110000001111000011,
                40'b1000000000000001111001111000000000000001,
                40'b1100001001000010111011110100001001000011,
                40'b1000001001000001111111111000001001000001,
                40'b1100000000000000110000110000000000000011,
                40'b1000000000000000000000000000000000000001,
                40'b1101101111010001011101000100111100001011,
                40'b1001101000011001001001101100000100001001,
                40'b1100001000011101001001111100011001111011,
                40'b1001101111010111001001010100100001001001,
                40'b1101100001010011001001010100100101001011,
                40'b1001101111010001011101000100011001111001,
                40'b1100000000000000000000000000000000000011,
                40'b1010000000000000000000000000000000000101,
                40'b1101000000000000000000000000000000001011,
                40'b1010101010101010101001010101010101010101,
                40'b1101010101010101010110101010101010101011,
                40'b1010101010101010101001010101010101010101,
                40'b1111111111111111111111111111111111111111
            };
        end else if (tie_screen) begin
            // Display "Tie" screen
            //LED[4] = 1;
            //{LED[15:5],LED[3:0]} = 15'd0;
            map0 = {
                40'b1111111111111111111111111111111111111111,
                40'b1010101010101101010001010101010101010101,
                40'b1101010101010010100100101010101010101011,
                40'b1010101010101101001010010101010101010101,
                40'b1101000000000000010001000000000000001011,
                40'b1010001111000000100000100000011110000101,
                40'b1100001001000001000000010000010010000011,
                40'b1000000000000010000000001000000000000001,
                40'b1100001001000010000000001000010010000011,
                40'b1000001001000010000100001000010010000001,
                40'b1100000000000001001010010000000000000011,
                40'b1000000000000000110001100000000000000001,
                40'b1100000000000000000000000000000000000011,
                40'b1000000000000000000000000000000000000001,
                40'b1100000000111110011111100001100000000011,
                40'b1000000000111110011111100001100000000001,
                40'b1100000000000110000110000001100000000011,
                40'b1000000000001110000110000001100000000001,
                40'b1100000000000110011111100111111000000011,
                40'b1010000000111110011111100111111000000101,
                40'b1101000000000000000000000000000000001011,
                40'b1010101010101010101001010101010101010101,
                40'b1101010101010101010110101010101010101011,
                40'b1010101010101010101001010101010101010101,
                40'b1111111111111111111111111111111111111111
            };
        end else if (secret_screen) begin
            //LED[5] = 1;
            //{LED[15:6],LED[4:0]} = 15'd0;
            map0 = {
                40'b1110111110001111111111111111111111111111,
                40'b1100011101111111111111111111111111111111,
                40'b1000001101111010011110000111110000000011,
                40'b1101011101111001101101111011101111111011,
                40'b1111111100011011101101111011011111111011,
                40'b1111011101101011101101111010111111111011,
                40'b1111011101101001101101110010111111111011,
                40'b1111101101101010011100001110111111111011,
                40'b1111101111111111111101111111000011001011,
                40'b1111110111111111111101111111111010101011,
                40'b1111111001111111111101111111110111111011,
                40'b1111111110111111111101111111101110101011,
                40'b1111111110111111111101111111101110101011,
                40'b1111111110111111111111111111101111111011,
                40'b1111111101111111110111101110110000000011,
                40'b1111111100111111101111101110111111111111,
                40'b1111111001111111100111001100100011011011,
                40'b1111111100111111101010101010110101011011,
                40'b1111111011011111101011001100111011011011,
                40'b1111110111101111111111111111111111000011,
                40'b1111110111101111111111111111111111011011,
                40'b1111110111101111111111111111111111011011,
                40'b1111110111101111111111111111111111011011,
                40'b1111111011011111111111111111111111111111,
                40'b1111111100111111111111111111111111111111
            };
        end
    end
    
      ////////////////////
     // Draw Condition //
    ////////////////////
    logic [1:0] colorize;
    always_comb begin
        colorize = 2'b00;
        if(p1_wins_screen) begin
            colorize = 2'b01;
        end else begin
            if (p2_wins_screen) begin
                colorize = 2'b10;
            end else begin
                if (secret_screen) begin
                    colorize = 2'b11;
                end
            end
        end
    end
    
    drawcon drawcon0(
    .clk(pixclk),
    .rst(rst),
    .draw_x(curr_x),
    .draw_y(curr_y),
    .draw_r(draw_r),
    .draw_g(draw_g),
    .draw_b(draw_b),
    // Player 1
    .rot1(p1_rot),
    .p1pos_x(p1pos_x),
    .p1pos_y(p1pos_y),
    .p1bullpos_x(p1bullpos_x),
    .p1bullpos_y(p1bullpos_y),
    // Player 2
    .rot2(p2_rot),
    .p2bullpos_x(p2bullpos_x),
    .p2bullpos_y(p2bullpos_y),
    .p2pos_x(p2pos_x),
    .p2pos_y(p2pos_y),
    // Map Input
    .map0(map0),
    .colorize(colorize)
    );
    
      //////////////////////
     // Keyboard Control //
    //////////////////////
    
    top_keyboard keyboard0(
    .rst(rst),
    .clk(clk),
    .PS2_CLK(PS2_CLK),
    .PS2_DATA(PS2_DATA),
    .p1button_state_kb(p1button_state_kb),
    .p2button_state_kb(p2button_state_kb)
    );
    
    // Debug
    assign LED[15:11] = p1button_state_kb[4:0];
    
       ////////////////////
      // Music Playback //
     ////////////////////
     
     logic [1:0] music_track;
     
     always_comb begin
         music_track = 2'd0;
         if (game_running) begin
            music_track = 2'd1;
         end else begin
            if (secret_screen) begin
                music_track = 2'd2;
            end
         end
     end
     
     song_player music (
     .clk(clk),
     .reset(game_start|rst|insert_coin_screen), // only play music during the game state
     .music_track(music_track),
     .AUD_PWM(AUD_PWM),
     .AUD_SD(AUD_SD)
    );
    
      ///////////////////////
     // 7 Segment Display //
    ///////////////////////
    
    logic [31:0] display7segnum;
    assign display7segnum[31:0] = {4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,{3'b0,game_start},{3'b0,game_running}};
    
    // Game Timer //
    
    // Parameters
//    localparam TOTAL_SECONDS = 120; // 2 minutes = 120 seconds

//    // Timer registers
//    logic [6:0] elapsed_seconds;  // Tracks elapsed seconds (0-119)
//    logic [3:0] minutes;          // Minutes (0-2)
//    logic [5:0] seconds;          // Seconds (0-59)
//    logic [5:0] tick_counter;    // Counts ticks (0-59 for 60Hz clock)
//    logic tick_1hz;              // 1Hz enable signal
    
//    // Generate 1Hz signal from 60Hz gclk
//    always_ff @(posedge gclk) begin
//        if (!rst) begin
//            tick_counter <= 6'd0;
//            tick_1hz <= 1'b0;
//        end else if (tick_counter == 6'd59) begin
//            tick_counter <= 6'd0;
//            tick_1hz <= 1'b1; // Generate 1Hz pulse
//        end else begin
//            tick_counter <= tick_counter + 1;
//            tick_1hz <= 1'b0;
//        end
//    end
    
//    // Reset and count-up logic
//    always_ff @(posedge gclk) begin
//        if (!rst) begin
//            elapsed_seconds <= 7'd0; // Reset to 0 seconds
//        end else if (!game_running) begin
//            elapsed_seconds <= 7'd0; // Reset to 0 seconds when not running
//        end else if (tick_1hz && elapsed_seconds < TOTAL_SECONDS) begin
//            elapsed_seconds <= elapsed_seconds + 1; // Increment seconds at 1Hz
//        end
//    end

//    // Convert elapsed seconds to minutes and seconds
//    always_comb begin
//        minutes = elapsed_seconds / 60;    // Calculate minutes
//        seconds = elapsed_seconds % 60;    // Calculate remaining seconds
//    end

//    // Combine digits for seven-segment display
//    always_comb begin
//        if (game_running) begin
//            display7segnum = {
//                4'd0,                // Unused digits
//                4'd0,                // Unused digits
//                minutes[3:0],             // Minutes digit
//                4'(seconds / 10),      // Tens digit of seconds
//                4'(seconds % 10),      // Units digit of seconds
//                4'd0,                // Unused digits
//                4'd0,                // Unused digits
//                4'd0                 // Unused digits
//            };
//        end else begin
//            display7segnum = 32'd0;
//        end
//    end
    
    seg7decimal sevenSeg (
    .x(display7segnum),
    .clk(clk),
    .seg(SEG[6:0]),
    .an(AN[7:0]),
    .dp(DP)
    );
    
endmodule