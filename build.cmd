#!/bin/bash
# ────────────────────────────────────────────────────────────────
#  build.cmd – Universal LaTeX build wrapper
#  Cross-platform entry point for UCCS LaTeX coursework toolchain
# ────────────────────────────────────────────────────────────────
#
#  This script automatically detects your operating system and calls
#  the appropriate build system:
#    • Windows: calls build.bat
#    • Unix/Linux/macOS: calls make
#
#  Usage examples:
#    build.cmd help
#    build.cmd pdf FILE=classes/course/term/assignment.tex
#    build.cmd all
#    build.cmd clean
#
# ────────────────────────────────────────────────────────────────

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect operating system
if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OS" == "Windows_NT" ]]; then
    # We're on Windows (via Git Bash, MSYS2, Cygwin, or similar)
    if [[ -f "$SCRIPT_DIR/build/build.bat" ]]; then
        # Use cmd.exe to run the batch file with proper Windows paths
        cmd.exe //c "$(cygpath -w "$SCRIPT_DIR/build/build.bat")" "$@"
    else
        echo "Error: build.bat not found in $SCRIPT_DIR/build/"
        echo "Please ensure build.bat is in the build/ directory"
        exit 1
    fi
else
    # We're on Unix-like system - use make
    if [[ -f "$SCRIPT_DIR/build/Makefile" ]]; then
        make -f "$SCRIPT_DIR/build/Makefile" "$@"
    else
        echo "Error: Makefile not found in $SCRIPT_DIR/build/"
        echo "Please ensure Makefile is in the build/ directory"
        exit 1
    fi
fi
