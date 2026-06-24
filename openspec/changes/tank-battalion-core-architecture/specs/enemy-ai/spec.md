## ADDED Requirements

### Requirement: AI decision triggered at movement opportunities
Each enemy tank SHALL evaluate its movement direction only when its cooldown reaches zero. The evaluation SHALL consider available grid directions, alignment with the effigy, and alignment with the player.

#### Scenario: Enemy cooldown expires at an intersection
- **WHEN** an enemy tank's cooldown reaches 0 and it has 3 valid movement directions
- **THEN** the system SHALL execute the full AI decision tree to select a direction before moving

### Requirement: Momentum bias to prevent ping-pong
An enemy tank with a clear path in its current movement direction SHALL have an 80% chance to continue straight and a 20% chance to evaluate turning, preventing jittering in corridors.

#### Scenario: Enemy in a straight corridor
- **WHEN** an enemy is moving right and the cell to the right is empty
- **THEN** the system SHALL generate an RNG value; if below 205 (80%), it SHALL continue right without evaluating alternatives

### Requirement: Effigy targeting override
When an enemy tank is aligned on the same row or column as the effigy, and the enemy type is Heavy (Yellow) or Fast (Red), the system SHALL offer a 50% chance to override the standard decision and move toward the effigy.

#### Scenario: Heavy tank aligned with effigy
- **WHEN** a Heavy tank shares the same Y coordinate as the effigy and its cooldown expires
- **THEN** the system SHALL generate an RNG value; if below 128 (50%), the tank SHALL move toward the effigy

### Requirement: Direction evaluation priority
When evaluating movement options, the AI SHALL test directions in this priority order: Down, Right, Left, Up. For each available direction, the system SHALL check a percentage chance (scaled by difficulty/tank type). If all checks fail, the entity SHALL fall back to the highest-priority available direction.

#### Scenario: T-junction with Down and Left available
- **WHEN** an enemy at a T-junction can move Down or Left
- **THEN** the system SHALL test Down first (30% chance), then test Left (30% chance), and if both fail, SHALL force-move Down

### Requirement: Pseudo-random number generator
The system SHALL implement a byte-sized Linear Congruential Generator (LCG) for RNG, following the formula `seed = (seed * 5 + 3) mod 256`. The seed SHALL be initialized from the BIOS tick counter low byte on game start.

#### Scenario: RNG produces values for AI
- **WHEN** the AI needs a random determination (e.g., 30% chance)
- **THEN** the system SHALL call the LCG, compare the result against a threshold (e.g., 76 for 30%), and branch accordingly
