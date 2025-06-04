# CS256 Final Project – FPGA Tank Game

This repository contains the final project for **CS 256: Digital Design and Computer Architecture** at KAUST. The project is a two-player competitive tank game implemented in **SystemVerilog** and designed for the **Nexys A7 FPGA board**. The game includes sprite-based graphics, keyboard controls, real-time collision detection, game state transitions, and music synthesis.

## Game Overview

Inspired by the classic Atari 2600 game *Combat*, this project features:
- Two-player tank battles on a VGA display
- Player and bullet collision detection
- Keyboard controls via PS/2 interface
- Multiple game states (insert coin, win, tie, secret)
- Built-in music using sawtooth synthesis

## Core Features

### VGA Output  
Renders 1280×800 display at 60 Hz using custom timing logic with `vga_out.sv`.

### Drawing Engine  
Handles map rendering, sprite drawing, and layer prioritization with support for rotation.

### Collision Detection  
- `collision_checker.sv`: Detects environment collisions.
- In-module logic handles bullet and player collisions.

### Game State FSM  
Manages transitions like insert coin → game → win screens using `game_fsm.sv`.

### Audio Subsystem  
Generates real-time game music with:
- `song_player.sv`
- `song_reader.sv`
- `sawtooth_synth.sv`

### Controls  
Full PS/2 keyboard support with debounced inputs. Players can move, shoot, and interact using keyboard and board switches.

## Testing

Simulation testbenches validate:
- VGA sync signal timing
- Sprite rendering logic
- Audio waveform generation
- Collision and FSM behavior

Hardware testing was done directly on the Nexys A7 FPGA board with a VGA monitor and PS/2 keyboard.

## Module Files

- `Code/game_top.sv` – Main integration module
- `Code/vga_out.sv` – VGA signal generation
- `Code/drawcon.sv` – Pixel-level drawing logic
- `Code/collision_checker.sv` – Terrain/entity collision
- `Code/game_fsm.sv` – Game state machine
- `Code/song_player.sv`, `song_reader.sv`, `sawtooth_synth.sv` – Music system
- `Code/top_keyboard.v`, `PS2Receiver.v` – Keyboard interface
- Other `/matlab_helpers/` – Scripts to convert map and sprite data

## Report

A full technical report with diagrams, figures, and simulation results is included as `CS_256_Project_Report_Abril.pdf`.

