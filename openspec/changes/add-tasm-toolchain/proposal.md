## Why

The project currently assumes TASM and TLINK are globally available in the DOSBox environment, requiring manual installation by each developer. By bundling the TASM toolchain directly in the repository and providing a pre-configured DOSBox autoexec, anyone can clone and build with zero setup — just run DOSBox.

## What Changes

- Add `tools/tasm/` directory containing Borland Turbo Assembler 4.1, Turbo Link 7.1, and Borland Make 4.0 binaries (copied from zajo/TASM).
- Create `dosbox.conf` with autoexec that mounts the repo root as `C:`, adds `C:\tools\tasm\bin` to PATH, and sets the working directory to `C:\src`.
- Update `build.sh` to use the committed `dosbox.conf` instead of generating a temporary config.
- Update `Makefile` to remove reliance on external PATH configuration (use `tools\tasm\bin` directly).
- Add `.gitignore` entry for build artifacts (`*.obj`, `*.exe`, `*.map`) while preserving the `build/` directory structure.

## Capabilities

### New Capabilities
- `tasm-toolchain`: Self-contained Turbo Assembler build environment within the repository, pre-configured for DOSBox compilation.

### Modified Capabilities
<!-- No existing specs to modify -->

## Impact

- **Repository size**: Adds ~2MB of binary toolchain files in `tools/tasm/`.
- **Build process**: `build.sh` becomes a single-step build (no manual TASM setup needed). The `Makefile` continues to work both inside and outside DOSBox.
- **Developer onboarding**: New contributors can build the project by installing DOSBox and running `./build.sh` — nothing else required.
