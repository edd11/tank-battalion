## 1. Project Scaffold and Memory Layout

- [x] 1.1 Create project directory structure (build/, src/)
- [x] 1.2 Write Makefile with TASM compilation targets
- [x] 1.3 Create main.asm with `.MODEL small`, `.STACK`, and `.DATA` / `.CODE` segment boilerplate
- [x] 1.4 Define all "Game Feel" variables as initialized dw values in the `.data` segment
- [x] 1.5 Define the MAP_ARRAY (156 bytes) and all entity state arrays (player, 4 enemies, 8 bullets)
- [x] 1.6 Allocate sprite data arrays (16x16 solid black, walls, tanks, bullets, effigy)

## 2. VGA Mode 13h Initialization and Rendering

- [x] 2.1 Implement SET_VIDEO_MODE routine (INT 10h, AX=0013h)
- [x] 2.2 Implement DRAW_TOP_BORDER routine (REP STOSB, 2560 bytes at A000:0000)
- [x] 2.3 Implement DRAW_SPRITE_SOLID routine (REP MOVSW, 16 rows with 304-byte stride)
- [x] 2.4 Implement DRAW_SPRITE_TRANS routine (per-pixel CMP AL,0 with JE skip)
- [x] 2.5 Implement ERASE_SPRITE routine (calls DRAW_SPRITE_SOLID with black sprite)
- [x] 2.6 Define initial test sprite data (solid color blocks) for visual verification

## 3. Game Loop and Timing

- [x] 3.1 Implement WAIT_VBLANK routine (polling port 3DAh bit 3 for 1->0->1 transition)
- [x] 3.2 Implement master game loop skeleton (VBlank wait -> Logic -> Render -> repeat)
- [x] 3.3 Implement entity cooldown decrement for all timers each tick
- [x] 3.4 Add state machine scaffolding (TITLE_SCREEN, GAMEPLAY, GAME_OVER constants)

## 4. Keyboard Input

- [x] 4.1 Save original INT 09h vector to OLD_INT09
- [x] 4.2 Implement CUSTOM_INT09_HANDLER (read port 60h, distinguish press/release, set boolean array)
- [x] 4.3 Implement PIC acknowledgment (OUT 20h, 20h) and IRET
- [x] 4.4 Install custom handler and KEY_UP/DOWN/LEFT/RIGHT/SPACE state variables in `.data`
- [x] 4.5 Implement exit/restore routine to recover original INT 09h on game exit
- [x] 4.6 Test simultaneous key presses (movement + shooting) in a simple input display loop

## 5. Grid Collision System

- [x] 5.1 Implement grid-to-pixel coordinate translation (PIXEL_X = GRID_X * 16, PIXEL_Y = GRID_Y * 16 + 8)
- [x] 5.2 Implement pixel-to-grid coordinate translation (GRID_X = PIXEL_X SHR 4, GRID_Y = (PIXEL_Y - 8) SHR 4)
- [x] 5.3 Implement MAP_ARRAY index calculation: INDEX = (ROW * 13) + COL
- [x] 5.4 Implement wall collision check (read MAP_ARRAY at destination; deny move if non-zero)
- [x] 5.5 Write MAP_ARRAY reader/writer macros for access from anywhere in code
- [x] 5.6 Implement tank position tracking in MAP_ARRAY (write 02 on enter, write 00 on exit)

## 6. Player Entity

- [x] 6.1 Define player initialization (start position, direction, lives, powerup level)
- [x] 6.2 Implement player movement logic (read KEY_*, translate direction, check grid collision)
- [x] 6.3 Implement player shooting logic (check powerup level for max bullets, spawn bullet entity)
- [x] 6.4 Integrate player rendering (erase old position, redraw new position on cooldown)

## 7. Enemy AI and Spawning

- [x] 7.1 Implement LCG random number generator (seed * 5 + 3 mod 256)
- [x] 7.2 Seed RNG from BIOS tick counter low byte at game start
- [x] 7.3 Implement AI direction evaluation (check all 4 adjacent cells for vacancy)
- [x] 7.4 Implement intersection detection and momentum bias (80% keep direction if path clear)
- [x] 7.5 Implement direction priority testing (Down->Right->Left->Up with configurable RNG thresholds)
- [x] 7.6 Implement effigy alignment override (50% chance for Heavy/Fast tanks to target effigy)
- [x] 7.7 Implement fallback force-move to highest-priority available direction
- [x] 7.8 Implement enemy spawn manager (select type by difficulty level, place at spawn points)
- [x] 7.9 Implement enemy rendering and cooldown integration

## 8. Bullet System

- [x] 8.1 Define bullet entity structure (active flag, X, Y, direction, owner, cooldown)
- [x] 8.2 Implement bullet spawn routine (check owner's max bullets, initialize new bullet)
- [x] 8.3 Implement bullet movement (calculate target grid cell, move if empty)
- [x] 8.4 Implement bullet-wall collision (hit solid wall -> set MAP_ARRAY to 80, deactivate bullet)
- [x] 8.5 Implement bullet-tank collision (hit tank -> damage HP, deactivate bullet; skip enemy bullets through enemies)
- [x] 8.6 Implement bullet-effigy collision (hit effigy -> trigger GAME_OVER)
- [x] 8.7 Implement bullet-bullet collision (iterate BULLET_ACTIVE array, deactivate both if same target cell)
- [x] 8.8 Implement bullet border deactivation (deactivate if target outside 0..12 / 0..11)
- [x] 8.9 Implement bullet rendering using DRAW_SPRITE_TRANS for visual overlap

## 9. Wall Crumble System

- [x] 9.1 Define wall timer array or cooldown tracker for crumbling walls
- [x] 9.2 Implement wall hit handler (01 -> 80, start countdown, draw crumbling sprite)
- [x] 9.3 Implement wall crumble timer decrement each metronome tick
- [x] 9.4 Implement wall removal on timer expiry (80 -> 00, erase sprite, draw floor)

## 10. HUD System

- [x] 10.1 Define 8x8 bitmap font data (characters 0-9, A-Z for labels)
- [x] 10.2 Implement DRAW_CHAR routine (8x8 version of DRAW_SPRITE_TRANS)
- [x] 10.3 Implement PRINT_STRING routine (iterate null-terminated string, draw each char)
- [x] 10.4 Implement ITOA routine (integer to ASCII conversion for score display)
- [x] 10.5 Draw static HUD labels (HI-SCORE, SCORE, LEVEL, LIVES, ENEMIES) during state init
- [x] 10.6 Implement dynamic HUD updates (score, lives icons, enemy icons, level number)

## 11. State Machine and Level Loading

- [x] 11.1 Define 8 level layout arrays (156 bytes each) in .data segment
- [x] 11.2 Implement level loading routine (REP MOVSB from level data archive to MAP_ARRAY)
- [x] 11.3 Implement TITLE_SCREEN state (draw top border, static HUD, flash "PRESS START", wait for input)
- [x] 11.4 Implement GAMEPLAY state initialization (load level, reset player, spawn enemies)
- [x] 11.5 Implement GAME_OVER state (check hi-score, display "GAME OVER", return to title)

## 12. Integration and Polish

- [x] 12.1 Wire all systems into the master game loop with correct execution order
- [x] 12.2 Implement game exit routine (restore video mode to 03h, restore INT 09h, terminate)
- [ ] 12.3 Test full game loop: title → level → gameplay → game over → title
- [ ] 12.4 Tune Game Feel variables (speeds, delays, shot cadence) for playable experience
- [ ] 12.5 Test in DOSBox on Windows 10/11 target environment
