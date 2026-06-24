## ADDED Requirements

### Requirement: Logical 13x12 grid array
The system SHALL maintain a 156-byte `MAP_ARRAY` representing the game field as 13 columns × 12 rows. Each byte SHALL encode the tile's state.

#### Scenario: Reading a cell
- **WHEN** the game logic needs to check grid coordinates (Col=5, Row=7)
- **THEN** the system SHALL compute the array index as `(Row * 13) + Col` and read `MAP_ARRAY[index]`

### Requirement: Pixel-to-grid coordinate translation
Entity positions SHALL be stored as pixel coordinates. When performing collision checks, the system SHALL translate pixel coordinates to grid coordinates using bit-shift division by 16 and subtraction of the 8-pixel top border offset for Y.

#### Scenario: Pixel coordinate to grid conversion
- **WHEN** a tank is at pixel (X=80, Y=88)
- **THEN** the system SHALL compute `GridX = 80 SHR 4 = 5` and `GridY = (88 - 8) SHR 4 = 5`

### Requirement: Grid-snapping movement
Entities SHALL move exclusively by snapping directly between adjacent grid cells. Movement SHALL update the pixel coordinate to `GridCoord * 16 + Offset` in a single step.

#### Scenario: Tank moves right
- **WHEN** a tank at grid (5,5) successfully moves right
- **THEN** the system SHALL update the tank's grid position to (6,5) and its pixel position to (96, 88) in a single operation

### Requirement: O(1) collision detection
The system SHALL resolve all movement collisions by checking the single destination grid cell in `MAP_ARRAY` before allowing a move. If the cell contains a solid entity (`01`, `80`) or another tank (`02`), the move SHALL be denied.

#### Scenario: Tank blocked by wall
- **WHEN** a tank at grid (5,5) attempts to move right and `MAP_ARRAY[(5*13)+6]` contains `01`
- **THEN** the system SHALL deny the move and SHALL NOT update the tank's position

### Requirement: Map state values
The `MAP_ARRAY` SHALL use the following state encoding:
- `00`: Empty space
- `01`: Solid wall
- `02`: Tank (dynamic, written/erased as tanks move)
- `80`: Crumbling wall (invulnerable to damage, pending timer-based removal)

#### Scenario: Wall transitions to crumbling state
- **WHEN** a bullet hits a solid wall at grid (3,4)
- **THEN** the system SHALL set `MAP_ARRAY[(4*13)+3]` to `80` and start the wall's crumble timer
