## Context

Tank Battalion is an Sega SG-1000 game being cloned as an x86 Real Mode DOS executable using TASM. It runs in VGA Mode 13h (320x200, 256 colors). Hardware constraints include 16-bit real mode addressing (64KB segment limits) and direct hardware access (VRAM, keyboard, VGA ports). The Game Design Document (`Tank_Battalion_GDD.md`) specifies the visual layout, entity behaviors, and scoring mechanics.

## Goals / Non-Goals

**Goals:**
- Build a flicker-free rendering pipeline using Dirty Rectangles (erase & redraw) directly to A000:0000.
- Implement a Master Metronome synced to VBlank driving all game logic at consistent speed.
- Define entity movement as grid-snapping (logical 13x12 grid → visual 16x16 tiles) with cooldown timers.
- Create a custom INT 09h keyboard handler for simultaneous multi-key detection.
- Keep entire `.data` segment footprint safely under 64KB.
- Provide clear "Game Feel" variables (cooldown values) at the top of the `.data` segment.

**Non-Goals:**
- Double buffering (rejected—adds segment complexity and unnecessary memory cost).
- Smooth pixel-by-pixel interpolation (movement snaps directly grid-to-grid).
- Full custom tile-map engine; only 8 pre-defined level layouts are stored.
- Sound or music.
- Title screen animations beyond static text and flashing prompts.

## Decisions

### 1. Erase-and-Redraw (Dirty Rectangles) over Double Buffering
**Rationale:** A full 64,000-byte back buffer barely fits in one segment and leaves only 1,536 bytes for game variables. Erase-and-redraw adds zero RAM overhead code and is a historically accurate technique for grid-based DOS games. VBlank synchronization prevents tearing.

### 2. VBlank Metronome + Independent Entity Cooldowns
**Rationale:** Reading port 3DAh for Vertical Retrace provides a reliable 70Hz clock that is decoupled from CPU speed (unlike NOP-loop delays). Each entity has a `COOLDOWN` variable decremented every metronome tick; when it reaches zero, the entity may act. This allows per-type speed tuning (PLAYER_SPEED ≠ ENEMY_SPEED ≠ BULLET_SPEED) via simple `.data` constants.

**Alternatives considered:** 
- INT 1Ah (BIOS tick) at ~18.2 Hz—too coarse for smooth gameplay.
- NOP-loop—completely CPU-dependent; game runs at different speeds inside DOSBox depending on cycle settings.

### 3. Binary Grid Collision (Array Lookup) over Pixel Bounding Boxes
**Rationale:** Entities snap 16px at a time, perfectly aligned with the grid. Collision checks are a single `MAP_ARRAY[Y*13+X]` lookup—no `DIV`, no bounding-box overlap math. This keeps collision detection O(1) per entity per frame.

### 4. Dual Renderers (SOLID vs TRANS)
**Rationale:** Opaque entities (tanks, walls, effigy) use `REP MOVSW` for maximum throughput. Overlays (bullets) that must not erase background sprites use a per-pixel transparency check (`CMP AL, 0 / JE skip`). Bullet-on-tank visual overlap requires transparency; everything else benefits from speed.

### 5. Custom INT 09h Keyboard Handler
**Rationale:** DOS INT 16h buffers keystrokes sequentially and does not support holding one key while pressing another seamlessly (required for simultaneous movement + shooting). A custom handler reads raw scan codes from port 60h and maintains a boolean state array (`KEY_UP`, `KEY_DOWN`, etc.) checked inline during player logic.

**Alternatives considered:** Polling port 60h directly in the game loop—no acknowledgment to the PIC would lock the keyboard after the first keypress.

### 6. Level Layouts Stored as Raw Byte Arrays
**Rationale:** With 56KB free after sprites and variables, the naive approach (8 arrays × 156 bytes = 1,248 bytes) is negligible. Avoids bit-packing complexity and complex decompression logic. Loading a level is a single `REP MOVSB` from the archive into the live `MAP_ARRAY`.

### 7. Map State Values Encoding
```
00 = Empty
01 = Solid Wall
80 = Crumbling Wall (invulnerable, pending removal)
```
**Rationale:** Using bit 7 (`80h`) as a flag allows a single `TEST` instruction to distinguish solid vs crumbling walls without expanding array size. The crumble timer is stored in a parallel array or unified `WALL_TIMERS` list.

### 8. RNG via Simple LCG + BIOS Tick Seed
**Rationale:** A linear congruential generator (seed = `seed * 5 + 3`, byte-sized) provides sufficient randomness for AI direction choices (30%, 50%). Seeded once from the BIOS tick counter (INT 1Ah) at game start to avoid deterministic patterns.

## Risks / Trade-offs

- **[Risk] Erase-and-redraw may produce visible flickering if the game loop falls behind VBlank.** → **Mitigation:** Entity count is bounded (4 enemies max, 1 player, ~8 bullets). Total pixels updated per frame is small, and `REP MOVSW` for solid sprites is fast enough to complete within a single retrace period.
- **[Risk] Custom INT 09h handler must be restored before exit or DOSBox keyboard becomes unresponsive.** → **Mitigation:** Save `OLD_INT09` on init, add exit handler that restores it. Test exit by running, pressing Esc, killing via Ctrl+C, and crashing to confirm behavior in all cases.
- **[Risk] 64KB segment boundary could be exceeded if sprite count grows beyond initial estimate (9KB).** → **Mitigation:** All sprites use consistent 16x16 (256 bytes). Monitor total `.data` size during build with TASM's listing output. Reserve a second segment if needed.
- **[Trade-off] Grid-snapping removes smooth pixel movement, trading visual fluidity for implementation simplicity.** → Accepted per conversation; "Game Feel" is controlled by cooldown timing, not interpolation.
