## Why

Establish the core technical architecture for Tank Battalion (Sega SG-1000 clone) in TASM (x86 Real Mode). We need a robust blueprint that handles VGA graphics, memory limits, game loop timing, and inputs efficiently before diving into assembly code implementation. This ensures all foundational systems—rendering, collisions, timing, AI—are cohesive and feasible within the constraints of DOS environments.

## What Changes

- Implement direct VRAM writing (`A000:0000`) in VGA 13h using "Dirty Rectangles" (Erase & Redraw) without double buffering.
- Create dual rendering routines: solid block copy (`REP MOVSW`) for opaque entities and pixel-by-pixel transparency check for overlays (bullets).
- Implement a game loop driven by a Master Metronome synced to Hardware VBlank (70Hz), with independent `COOLDOWN` timers for entity action rates.
- Establish coordinate translation from logical grid (13x12) to visual pixels, snapping entities exactly to grid spaces.
- Create an INT 09h custom keyboard handler to support simultaneous multi-key inputs.
- Define memory layout ensuring all variables, 9KB of sprites, and level data fit comfortably within a single 64KB `.data` segment.
- Implement enemy AI logic with RNG-based decision trees triggered at grid intersections to avoid "ping-pong" jitter.

## Capabilities

### New Capabilities
- `game-loop-timing`: Hardware VBlank metronome and entity cooldown management.
- `vga-graphics-engine`: Erase and redraw routines with solid and transparent handling.
- `grid-collision`: Array-based logical collision and pixel translation.
- `enemy-ai`: RNG intersection pathfinding and targeting overrides.
- `input-handling`: Custom INT 09h keyboard state tracking.

### Modified Capabilities
- 

## Impact

- **Memory**: Establishes the structure of the main `.data` segment (variables, sprites, level arrays).
- **Execution**: Takes over BIOS keyboard interrupts (requires setup/teardown) and hooks into Video hardware (VBlank reading).
- **Development Workflow**: Dictates how future features (HUD, scoring) must be integrated into the loop and memory space.