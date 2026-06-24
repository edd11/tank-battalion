## ADDED Requirements

### Requirement: TASM binaries included in repository
The repository SHALL include a complete copy of Borland Turbo Assembler 4.1, Turbo Link 7.1, and Borland Make 4.0 in `tools/tasm/`, with at minimum the `BIN/` directory containing the executable binaries.

#### Scenario: Binaries are present after fresh clone
- **WHEN** a developer clones the repository
- **THEN** the directory `tools/tasm/bin/` exists and contains `TASM.EXE`, `TLINK.EXE`, and `MAKE.EXE`

### Requirement: DOSBox autoexec configuration
A `dosbox.conf` file SHALL exist at the repo root with an `[autoexec]` section that mounts the repository root as drive `C:`, adds `C:\tools\tasm\bin` to the DOS PATH, and changes the working directory to `C:\src`.

#### Scenario: DOSBox starts with correct configuration
- **WHEN** DOSBox is launched with `dosbox -conf dosbox.conf`
- **THEN** drive `C:` is mounted at the repository root, `TASM` is invocable from any directory, and the prompt is at `C:\src`

### Requirement: Build script uses committed configuration
The `build.sh` script SHALL use the committed `dosbox.conf` file and SHALL NOT generate a temporary configuration. It SHALL compile `src/main.asm` using the local `tools/tasm/bin/tasm.exe` and link with `tools/tasm/bin/tlink.exe`.

#### Scenario: Build script compiles successfully
- **WHEN** `./build.sh` is executed
- **THEN** `build/main.exe` is produced using TASM and TLINK from `tools/tasm/bin/`

### Requirement: Build artifacts excluded from version control
The `.gitignore` file SHALL exclude compiled artifacts (`*.obj`, `*.exe`, `*.map`) while preserving directory structure. Pre-built TASM binaries in `tools/tasm/` SHALL be committed.

#### Scenario: Build artifacts are ignored
- **WHEN** a successful build produces `build/main.obj`, `build/main.exe`, `build/main.map`
- **THEN** `git status` does not show these files as untracked
