@echo off
REM ────────────────────────────────────────────────────────────────
REM  build.bat – UCCS LaTeX coursework toolchain (Windows)
REM  v2 • 2025-07-04 • Cross-platform compatibility
REM ────────────────────────────────────────────────────────────────
REM
REM  Requirements
REM  ────────────
REM    • tectonic  – preferred zero-config LaTeX engine
REM         -or-
REM    • latexmk   – fallback engine (watch mode, etc.)
REM    • cmd       – Windows command prompt
REM
REM  Key targets
REM  ───────────────────────────────────────
REM    pdf         build.bat pdf FILE=<tex>      → compile one document
REM    all         build.bat all                 → compile every .tex in classes/
REM    watch       build.bat watch FILE=<tex>    → live-reload (latexmk only)
REM    clean       build.bat clean               → delete aux files
REM    distclean   build.bat distclean           → clean + delete PDFs
REM    newdoc      build.bat newdoc [...]        → scaffold homework/report
REM    newhw       build.bat newhw  [...]        → shorthand wrapper for homework
REM    newreport   build.bat newreport [...]     → shorthand wrapper for report
REM    help        build.bat help                → show this help
REM
REM ────────────────────────────────────────────────────────────────

setlocal enabledelayedexpansion

REM ──────────────────────────────
REM  0.  Engine auto-detection
REM ──────────────────────────────
set ENGINE=
for %%i in (tectonic.exe tectonic) do (
    where /q %%i >nul 2>&1 && set ENGINE=tectonic && goto :engine_found
)
for %%i in (xelatex.exe xelatex) do (
    where /q %%i >nul 2>&1 && set ENGINE=xelatex && goto :engine_found
)
for %%i in (latexmk.exe latexmk) do (
    where /q %%i >nul 2>&1 && set ENGINE=latexmk && goto :engine_found
)

:engine_found
if "%ENGINE%"=="" (
    echo Error: No LaTeX engine found. Please install tectonic, xelatex, or latexmk.
    exit /b 1
)

REM ──────────────────────────────
REM  1.  Command parsing
REM ──────────────────────────────
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=help

if "%COMMAND%"=="help" goto :help
if "%COMMAND%"=="pdf" goto :pdf
if "%COMMAND%"=="all" goto :all
if "%COMMAND%"=="watch" goto :watch
if "%COMMAND%"=="clean" goto :clean
if "%COMMAND%"=="distclean" goto :distclean
if "%COMMAND%"=="newdoc" goto :newdoc
if "%COMMAND%"=="newhw" goto :newhw
if "%COMMAND%"=="newreport" goto :newreport

echo Error: Unknown command "%COMMAND%"
goto :help

REM ──────────────────────────────
REM  2.  Help target
REM ──────────────────────────────
:help
echo.
echo   UCCS LaTeX Build System (Windows)
echo.
echo   Available commands:
echo     pdf         Compile one .tex file (usage: build.bat pdf FILE=path\to\doc.tex)
echo     all         Compile every .tex file under classes\
echo     watch       Live-reload compilation (requires latexmk)
echo     clean       Delete auxiliary build artifacts (keeps PDFs)
echo     distclean   Clean + delete generated PDFs
echo     newdoc      Interactive homework/report scaffold
echo     newhw       Shorthand wrapper for homework
echo     newreport   Shorthand wrapper for report
echo     help        Show this help
echo.
echo   Detected LaTeX engine: %ENGINE%
echo.
exit /b 0

REM ──────────────────────────────
REM  3.  Single-file compile
REM ──────────────────────────────
:pdf
REM Parse FILE= parameter
set FILE_ARG=
for %%i in (%*) do (
    set arg=%%i
    if "!arg:~0,5!"=="FILE=" (
        set FILE_ARG=!arg:~5!
    )
)

if "%FILE_ARG%"=="" (
    echo Error: Usage: build.bat pdf FILE=classes\^<course^>\^<term^>\^<name^>.tex
    exit /b 1
)

echo Compiling %FILE_ARG% with %ENGINE%...

if "%ENGINE%"=="tectonic" (
    tectonic -X compile --synctex -Z shell-escape "%FILE_ARG%"
) else if "%ENGINE%"=="xelatex" (
    xelatex -interaction=nonstopmode -synctex=1 -shell-escape "%FILE_ARG%"
) else (
    latexmk -pdf -shell-escape -interaction=nonstopmode "%FILE_ARG%"
)

if errorlevel 1 (
    echo Error: Compilation failed
    exit /b 1
)

REM Open the resulting PDF
set PDF_FILE=%FILE_ARG:.tex=.pdf%
if exist "%PDF_FILE%" (
    start "" "%PDF_FILE%"
)

exit /b 0

REM ──────────────────────────────
REM  4.  Compile everything
REM ──────────────────────────────
:all
echo 🔄  Building ALL coursework PDFs...

if not exist "classes" (
    echo Error: classes directory not found
    exit /b 1
)

for /r "classes" %%f in (*.tex) do (
    echo —— %%f
    if "%ENGINE%"=="tectonic" (
        tectonic -X compile --synctex -Z shell-escape "%%f"
    ) else if "%ENGINE%"=="xelatex" (
        xelatex -interaction=nonstopmode -synctex=1 -shell-escape "%%f"
    ) else (
        latexmk -pdf -shell-escape -interaction=nonstopmode "%%f"
    )
    
    if errorlevel 1 (
        echo Error: Compilation failed for %%f
        exit /b 1
    )
)

echo ✅  All documents compiled.
exit /b 0

REM ──────────────────────────────
REM  5.  Watch mode
REM ──────────────────────────────
:watch
if not "%ENGINE%"=="latexmk" (
    echo Error: watch target requires latexmk
    exit /b 1
)

REM Parse FILE= parameter
set FILE_ARG=
for %%i in (%*) do (
    set arg=%%i
    if "!arg:~0,5!"=="FILE=" (
        set FILE_ARG=!arg:~5!
    )
)

if "%FILE_ARG%"=="" (
    echo Error: Usage: build.bat watch FILE=path\to\doc.tex
    exit /b 1
)

latexmk -pdf -pvc -shell-escape -interaction=nonstopmode "%FILE_ARG%"
exit /b 0

REM ──────────────────────────────
REM  6.  Clean artifacts
REM ──────────────────────────────
:clean
echo 🧹  Cleaning auxiliary files...

for /r %%f in (*.aux *.fdb_latexmk *.fls *.log *.synctex.gz *.out *.bbl *.blg *.bcf *.run.xml) do (
    if exist "%%f" del "%%f"
)

echo ✅  Clean done.
exit /b 0

:distclean
call :clean
echo 🧹  Removing PDFs...

for /r "classes" %%f in (*.pdf) do (
    if exist "%%f" del "%%f"
)

echo ✅  distclean done.
exit /b 0

REM ──────────────────────────────
REM  7.  Template scaffolding
REM ──────────────────────────────
:newdoc
echo Running newdoc scaffold...
if exist "scripts\newdoc.bat" (
    call "scripts\newdoc.bat" %*
) else if exist "scripts\newdoc.sh" (
    REM Try to run the bash version if available
    where /q bash >nul 2>&1 && bash "scripts\newdoc.sh" %*
) else (
    echo Error: newdoc script not found
    exit /b 1
)
exit /b 0

:newhw
call :newdoc TYPE=homework %*
exit /b 0

:newreport
call :newdoc TYPE=report %*
exit /b 0
