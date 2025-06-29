@echo off
echo Dwarf Fortress Graphics Analyzer
echo ==============================
echo.

if "%1"=="" (
    echo Usage: analyze_graphics.bat [option]
    echo Options:
    echo   all       - Run all analysis
    echo   images    - Analyze image files
    echo   palettes  - Analyze palette files
    echo   sprites   - Analyze sprite sheets
    echo   graphics  - Analyze graphics configuration files
    goto :eof
)

if "%1"=="all" (
    echo Running all analysis...
    python graphics_analyzer.py --mode all
    goto :eof
)

if "%1"=="images" (
    echo Analyzing image files...
    python read_graphics_chunks.py
    goto :eof
)

if "%1"=="palettes" (
    echo Analyzing palette files...
    python analyze_palette.py
    goto :eof
)

if "%1"=="sprites" (
    echo Analyzing sprite sheets...
    python analyze_sprites.py
    goto :eof
)

if "%1"=="graphics" (
    echo Analyzing graphics configuration files...
    python graphics_analyzer.py --mode graphics
    goto :eof
)

echo Unknown option: %1
echo Run analyze_graphics.bat without arguments to see available options.