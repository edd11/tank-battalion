# Tank Battalion

A recreation of the classic Sega SG-1000 game **Tank Battalion**, written in x86 real-mode assembly for DOS. Runs in VGA Mode 13h (320x200, 256 colors).

## Requirements

- [DOSBox Staging](https://www.dosbox-staging.org/) (or any DOSBox variant)
- The TASM 4.1 + TLINK 7.1 toolchain is included in `tools/tasm/`

## Quick Start

### Build

```bash
./build.sh
```

This compiles `src/main.asm` with Turbo Assembler 4.1 inside DOSBox and produces `build/MAIN.EXE`.

### Run

```bash
./run.sh
```

Launches the compiled game in DOSBox.

## Controls

| Key | Action |
|-----|--------|
| Arrow Keys | Move tank (Up/Down/Left/Right) |
| Space | Shoot |
| Enter | Pause / Start game |
| Esc | Quit to title |

## Gameplay

- **Objective:** Destroy all enemy tanks on each level while protecting your effigy.
- **Lives:** You start with 3 lives. Earn an extra life every 20,000 points.
- **Enemies:** Up to 4 enemies on screen at once. Types include Normal, Fast, Heavy (takes multiple hits), and Rainbow.
- **Walls:** Destructible walls block movement and bullets. Shooting a wall damages it until it crumbles.
- **Effigy:** Located at the bottom-center of the map. If an enemy destroys it, the game is over.

### HUD

- **HI-SCORE** — Highest score achieved
- **SCORE** — Current score
- **LEVEL** — Current level (1-8)
- **LIVES** — Remaining lives (shown as tank icons)
- **ENEMIES** — Remaining enemies on the level (shown as enemy icons)

## Project Structure

```
.
├── build.sh          # Build script (launches DOSBox with TASM)
├── run.sh            # Run script (launches game in DOSBox)
├── dosbox.conf       # DOSBox configuration (mounts, PATH)
├── Makefile          # Alternative DOS make build
├── src/
│   ├── main.asm      # Main game source (assembly)
│   └── build.bat     # DOS batch build script
├── build/            # Build output directory
│   └── MAIN.EXE      # Compiled executable
└── tools/tasm/       # TASM 4.1 + TLINK 7.1 toolchain
```

## Architecture

- **Language:** x86 real-mode assembly (Turbo Assembler 4.1)
- **Graphics:** VGA Mode 13h (320x200, 256 colors), double-buffered via page flipping
- **Sprites:** 16x16 pixel software-rendered sprites (player, enemies, bullets, walls)
- **Map:** 13x12 grid with 8 levels
- **Memory:** Explicit segment layout — `_DATA` segment for game state and assets, `_TEXT` segment for code, `STACK` segment for stack, all grouped in `DGROUP`
- **Input:** Custom INT 09h keyboard interrupt handler
- **Timing:** VBLANK-synchronized game loop via VGA status register polling

## Building Manually (inside DOSBox)

```bat
cd src
build.bat
```

## License

This project is an educational recreation. All rights belong to their respective owners.
