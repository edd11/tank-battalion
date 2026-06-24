@echo off
echo Building Tank Battalion...
echo %date% %time% > ..\build\build.log
echo. >> ..\build\build.log
echo TASM 4.1 compile... >> ..\build\build.log
tasm /zi /m2 main.asm, ..\build\main.obj, ..\build\main.lst >> ..\build\build.log 2>&1
if errorlevel 1 goto error
echo TASM: OK >> ..\build\build.log
echo. >> ..\build\build.log
echo TLINK 7.1 link... >> ..\build\build.log
tlink /v ..\build\main.obj, ..\build\main.exe, ..\build\main.map >> ..\build\build.log 2>&1
if errorlevel 1 goto error
echo TLINK: OK >> ..\build\build.log
echo. >> ..\build\build.log
echo BUILD SUCCESSFUL: ..\build\main.exe
echo BUILD SUCCESSFUL >> ..\build\build.log
goto done
:error
echo.
echo BUILD FAILED - See build\build.log and build\main.lst for details
echo BUILD FAILED >> ..\build\build.log
:done
