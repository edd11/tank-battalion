## ADDED Requirements

### Requirement: Master metronome synced to VBlank
The system SHALL use the VGA Vertical Retrace signal (port 3DAh) as a master clock pulse. Every game logic tick SHALL wait for the retrace period before executing.

#### Scenario: Game loop waits for retrace
- **WHEN** the game loop reaches the render phase
- **THEN** the system SHALL poll port 3DAh bit 3 until a 1→0→1 transition is detected, marking one frame complete

### Requirement: Entity cooldown timers
Each moving entity (Player, Enemies, Bullets) SHALL have a cooldown counter decremented every metronome tick. An entity SHALL only act (move, shoot) when its cooldown reaches zero, at which point it resets to its configured speed value.

#### Scenario: Player moves on cooldown expiry
- **WHEN** the metronome ticks and player cooldown reaches 0
- **THEN** the system SHALL read input, attempt movement, and reset the player cooldown to PLAYER_SPEED

#### Scenario: Fast enemy moves more frequently
- **WHEN** a Fast enemy has GAME_SPEED_FAST set to 3 and a Normal enemy has GAME_SPEED_NORMAL set to 6
- **THEN** the Fast enemy SHALL act twice as often as the Normal enemy

### Requirement: Game Feel variables in isolated data block
All speed, delay, and rate-of-fire values SHALL be defined as initialized word variables at the top of the `.data` segment, clearly delimited by comments, to enable tuning without modifying logic.

#### Scenario: Developer adjusts player speed
- **WHEN** the developer changes `PLAYER_SPEED dw 4` to `PLAYER_SPEED dw 2`
- **THEN** the player tank SHALL move twice as frequently with no other code changes required
