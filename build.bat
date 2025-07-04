@echo off
REM ────────────────────────────────────────────────────────────────
REM  build.bat – Windows LaTeX build wrapper
REM  Windows-specific entry point for UCCS LaTeX coursework toolchain
REM ────────────────────────────────────────────────────────────────
REM
REM  This script calls the Windows build system (build.bat in build/ dir)
REM
REM  Usage examples:
REM    build.bat help
REM    build.bat pdf FILE=classes/course/term/assignment.tex
REM    build.bat all
REM    build.bat clean
REM
REM ────────────────────────────────────────────────────────────────

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Call the Windows build script
if exist "%SCRIPT_DIR%build\build.bat" (
    call "%SCRIPT_DIR%build\build.bat" %*
) else (
    echo Error: build.bat not found in %SCRIPT_DIR%build\
    echo Please ensure build.bat is in the build/ directory
    exit /b 1
)

exit /b %errorlevel%
