## 1. Add TASM toolchain files

- [x] 1.1 Clone zajo/TASM repo and copy contents into `tools/tasm/` (BIN/, INCLUDE/, LIB/, DOC/, EXAMPLES/)
- [x] 1.2 Verify `tools/tasm/bin/` contains TASM.EXE, TLINK.EXE, MAKE.EXE

## 2. DOSBox configuration

- [x] 2.1 Create `dosbox.conf` at repo root with `[autoexec]` section mounting repo as C: and adding C:\tools\tasm\bin to PATH
- [x] 2.2 Add startup echo message confirming environment is ready
- [x] 2.3 Verify `dosbox -conf dosbox.conf` starts with correct mounts and PATH

## 3. Build script updates

- [x] 3.1 Rewrite `build.sh` to use the committed `dosbox.conf` instead of generating a temporary config
- [x] 3.2 Ensure build.sh invokes TASM and TLINK from the PATH set in dosbox.conf
- [x] 3.3 Update `Makefile` to use DOS-style paths compatible with the new environment

## 4. Repository hygiene

- [x] 4.1 Update `.gitignore` to exclude `build/*.obj`, `build/*.exe`, `build/*.map` (but keep build/ directory)
- [x] 4.2 Verify `git status` shows only source files after a build

## 5. Verification

- [ ] 5.1 Run `./build.sh` and confirm `build/main.exe` is produced successfully (requires DOSBox GUI — run locally)
- [ ] 5.2 Verify the produced .exe runs correctly in DOSBox (requires DOSBox GUI — run locally)
- [ ] 5.3 Commit all new files to the repository
