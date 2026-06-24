@echo off
echo Building Tank Battalion...
echo.
tasm main.asm, ..\build\main.obj
if errorlevel 1 goto error
tlink ..\build\main.obj, ..\build\main.exe, ..\build\main.map
if errorlevel 1 goto error
echo.
echo BUILD SUCCESSFUL: ..\build\main.exe
goto done
:error
echo.
echo BUILD FAILED
:done
