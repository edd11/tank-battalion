## Context

The Tank Battalion project targets DOS/x86 real mode and requires Turbo Assembler (TASM) for compilation. Currently, TASM must be manually installed and configured on each developer's DOSBox environment. The `build.sh` script generates a temporary DOSBox config on each run.

By embedding the TASM toolchain in the repo and providing a permanent DOSBox config, we eliminate all manual setup steps. The user runs `./build.sh` and gets a compiled `.exe`.

The TASM toolchain (zajo/TASM) provides pre-built binaries ready for DOSBox use. The repo root is ~2MB, acceptable for inclusion.

## Goals / Non-Goals

**Goals:**
- Bundle TASM 4.1, TLINK 7.1, and MAKE 4.0 in `tools/tasm/`
- Provide `dosbox.conf` at repo root with correct mounts and PATH
- Update `build.sh` to use the permanent config
- Ensure `Makefile` works both inside and outside DOSBox
- Ignore compiled artifacts in `.gitignore`

**Non-Goals:**
- Building TASM from source (binaries are pre-built and committed directly)
- Supporting Windows native compilation (only via DOSBox)
- Adding sound, graphics, or game logic features

## Decisions

### 1. Copy binaries directly (not git submodule)
**Rationale:** A submodule adds an extra `git submodule update --init` step for every clone. Direct copy ensures `git clone` + `./build.sh` is all that's needed. The toolchain binaries are static (Borland tools from the 1990s) and will never need updating.

### 2. Single drive (C:) with tools under repo root
**Rationale:** DOSBox mounts the repo root as `C:`. With TASM at `C:\tools\tasm\bin`, everything lives under one mount point. No need for a D: drive. Simpler config, fewer moving parts.

### 3. Permanent `dosbox.conf` at repo root
**Rationale:** The current approach of generating `/tmp/tank_build.conf` on each run is fragile and doesn't survive across sessions for interactive use. A committed config lets developers run DOSBox manually with `dosbox -conf dosbox.conf` for debugging.

```ini
[autoexec]
mount c .
c:
path %PATH%;c:\tools\tasm\bin
cd src
echo.
echo TASM Turbo Assembler Environment Ready.
echo Type 'tasm main.asm, ..\build\main.obj' to assemble, or 'make' to use Makefile.
echo.
```

### 4. `build.sh` invokes DOSBox with committed config
**Rationale:** Instead of generating a temp config, `build.sh` launches `dosbox -conf dosbox.conf` with build commands. This keeps the build logic in one place.

### 5. `Makefile` paths point to `tools\tasm\bin`
**Rationale:** The Makefile is usable both inside DOSBox (via `make`) and as reference for manual compilation. Paths use DOS-style backslashes consistent with DOSBox conventions.

## Risks / Trade-offs

- **[Risk] Repository grows by ~2MB** → Mitigation: Acceptable trade-off for zero-setup builds. Binary toolchain is smaller than typical npm `node_modules`.
- **[Risk] TASM license compliance** → The tools are abandonware from Borland and publicly distributed on GitHub. No commercial redistribution concerns.
- **[Risk] `dosbox` command may differ across systems** → `build.sh` currently uses `dosbox-staging`. The config file itself is portable; only the launcher command differs across DOSBox forks.

## Open Questions

- Should `build.sh` assume `dosbox-staging` or `dosbox` (standard DOSBox)? The current system has `dosbox-staging` — we'll keep that but can document alternatives.
