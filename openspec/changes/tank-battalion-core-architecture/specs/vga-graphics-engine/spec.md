## ADDED Requirements

### Requirement: Direct VRAM writing in VGA Mode 13h
The system SHALL set video mode 13h (320x200, 256 colors) and render all graphics by writing directly to memory segment A000h.

#### Scenario: Mode 13h initialization
- **WHEN** the game launches
- **THEN** the system SHALL call INT 10h with AX=0013h to enter VGA mode 13h before any rendering

### Requirement: Erase-and-redraw (Dirty Rectangles) rendering
The system SHALL render graphics by erasing a moved entity's sprite at its previous position (writing a black 16x16 block) and drawing it at its new position, without clearing the full screen.

#### Scenario: Tank moves one grid cell right
- **WHEN** a tank moves from grid (5,5) to (6,5)
- **THEN** the system SHALL erase the tank at pixel coordinates (80, 88) by drawing a 16x16 black block, then draw the tank sprite at (96, 88)

### Requirement: Solid sprite rendering with REP MOVSW
Opaque entities (tanks, walls, effigy) SHALL be drawn using fast block-copy string instructions that write all 16 rows of 16 pixels without transparency checks.

#### Scenario: Drawing a wall tile
- **WHEN** `DRAW_SPRITE_SOLID` is called with a wall sprite address
- **THEN** the system SHALL copy 256 bytes (16 rows × 16 pixels) to VRAM using `REP MOVSW`, advancing the screen pointer by 304 bytes (320 - 16) between rows

### Requirement: Transparent sprite rendering for overlays
Overlay entities (bullets) SHALL be drawn using per-pixel transparency, where color index 0 is skipped and does not overwrite existing VRAM content.

#### Scenario: Bullet passes over an enemy tank
- **WHEN** a bullet sprite with color 0 in its corners is drawn over a tank sprite
- **THEN** the system SHALL skip writing color 0 pixels, preserving the tank's pixels underneath

### Requirement: Top border rendering
The system SHALL draw a solid 320x8 green border at the top of the screen (Y=0 to Y=7) once during state initialization, and SHALL NOT overwrite it during normal gameplay rendering.

#### Scenario: Title screen renders top border
- **WHEN** the TITLE_SCREEN state initializes
- **THEN** the system SHALL fill VRAM offsets A000:0000 to A000:09FF with the green color value using `REP STOSB`
