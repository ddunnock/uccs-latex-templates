@echo off
REM ────────────────────────────────────────────────────────────────
REM  build.cmd – Universal LaTeX build wrapper
REM  Cross-platform entry point for UCCS LaTeX coursework toolchain
REM ────────────────────────────────────────────────────────────────
REM
REM  This script automatically detects your operating system and calls
REM  the appropriate build system:
REM    • Windows: calls build.bat
REM    • Unix/Linux/macOS: calls make
REM
REM  Usage examples:
REM    build.cmd help
REM    build.cmd pdf FILE=classes/course/term/assignment.tex
REM    build.cmd all
REM    build.cmd clean
REM
REM ────────────────────────────────────────────────────────────────

REM Check if we're on Windows
if "%OS%"=="Windows_NT" (
    REM We're on Windows - use build.bat
    if exist "%~dp0build.bat" (
        call "%~dp0build.bat" %*
    ) else (
        echo Error: build.bat not found in %~dp0
        echo Please ensure build.bat is in the same directory as build.cmd
        exit /b 1
    )
) else (
    REM We're on Unix-like system - use make
    REM Note: This branch typically won't execute on Windows, but provides
    REM compatibility if somehow running in a Unix-like environment
    if exist "%~dp0Makefile" (
        make -f "%~dp0Makefile" %*
    ) else (
        echo Error: Makefile not found in %~dp0
        echo Please ensure Makefile is in the same directory as build.cmd
        exit /b 1
    )
)

exit /b %errorlevel%
