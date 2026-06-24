## ADDED Requirements

### Requirement: Custom INT 09h keyboard handler
The system SHALL install a custom interrupt handler for INT 09h that reads raw keyboard scan codes from port 60h and maintains a boolean state array for game-relevant keys.

#### Scenario: Handler installation on game start
- **WHEN** the game initializes
- **THEN** the system SHALL save the original INT 09h vector to `OLD_INT09`, install the custom handler, and set all key state variables to 0

#### Scenario: Handler teardown on game exit
- **WHEN** the game exits (clean exit or error)
- **THEN** the system SHALL restore the original INT 09h vector from `OLD_INT09` to prevent keyboard lockup

### Requirement: Key press and release tracking
The handler SHALL distinguish key press (scan code < 80h) from key release (scan code >= 80h) and SHALL set the corresponding state variable to 1 on press or 0 on release.

#### Scenario: Player presses and releases Up arrow
- **WHEN** the Up arrow is pressed (scan code 48h received from port 60h)
- **THEN** the system SHALL set `KEY_UP` to 1
- **WHEN** the Up arrow is released (scan code C8h received from port 60h)
- **THEN** the system SHALL set `KEY_UP` to 0

### Requirement: PIC acknowledgment
The handler SHALL send End of Interrupt (EOI) to the Programmable Interrupt Controller (port 20h, value 20h) before returning, to allow subsequent interrupts.

#### Scenario: Handler acknowledges interrupt
- **WHEN** the custom INT 09h handler finishes processing a key event
- **THEN** the system SHALL write 20h to port 20h before executing IRET

### Requirement: Instantaneous multi-key polling
The game logic SHALL read from the boolean state array directly, without waiting for BIOS keyboard buffer interrupts. This SHALL allow simultaneous movement and shooting.

#### Scenario: Player holds Up and presses Space simultaneously
- **WHEN** the player logic executes and reads `KEY_UP = 1` and `KEY_SPACE = 1`
- **THEN** the system SHALL process both movement (Up) and shooting in the same tick
