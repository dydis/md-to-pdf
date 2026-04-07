@echo off
setlocal enabledelayedexpansion

:: ---------------- CLEANUP OPTION ----------------
if /I "%~1"=="clean" (
    if "%~2"=="" (
        echo Error: Please specify the markdown file so I know where the image folder is.
        echo Usage: %~n0%~x0 clean ^<input_file^>
        exit /b 1
    )
    set "img_dir=%~dp2image"
    if exist "!img_dir!" (
        echo Cleaning up folder: "!img_dir!"...
        rmdir /s /q "!img_dir!"
        echo Cleanup complete.
        exit /b 0
    ) else (
        echo No image folder found at "!img_dir!".
        exit /b 0
    )
)

:: ---------------- CHECK PREREQUISITES ----------------
where pandoc >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Pandoc is not installed or not in PATH
    echo Please install Pandoc from https://pandoc.org/installing.html
    exit /b 1
)

where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Warning: Python is not installed.
    echo Mermaid diagrams won't update automatically.
)

call mmdc --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Warning: Mermaid CLI ^(mmdc^) is not installed.
    echo Run: npm install -g @mermaid-js/mermaid-cli
)

:: ---------------- SETUP PATHS & ARGS ----------------
:: Save the script directory BEFORE shifting arguments
set "SCRIPT_DIR=%~dp0"
set "use_tag=0"
set "input_file="

:arg_loop
if "%~1"=="" goto arg_done
if /I "%~1"=="/tag" (
    set "use_tag=1"
) else (
    set "input_file=%~1"
)
shift
goto arg_loop
:arg_done

if "%input_file%"=="" (
    echo Error: No input file provided.
    echo Usage: %~n0%~x0 ^<input_file^> [/tag]
    exit /b 1
)

echo Processing file: %input_file%

:: ---------------- SETUP DYNAMIC TAG & OUTPUT FILE ----------------
if "!use_tag!"=="1" (
    set "COPY_ID=!RANDOM!-!RANDOM!"
    echo Adding dynamic Copy ID: !COPY_ID!
    
    :: Append COPY_ID to the filename
    for %%I in ("%input_file%") do set "output_file=%%~dpnI_!COPY_ID!.pdf"
    
    set TAG_FANCY=-V header-includes="\usepackage{fancyhdr}"
    set TAG_STYLE=-V header-includes="\pagestyle{fancy}"
    set TAG_HEAD=-V header-includes="\fancyhead{}" -V header-includes="\renewcommand{\headrulewidth}{0pt}"
    set TAG_FOOT=-V header-includes="\fancyfoot[C]{\texttt{ID Copie : !COPY_ID! \quad - \quad Page \thepage}}"
    set TAG_PLAIN=-V header-includes="\fancypagestyle{plain}{\fancyhf{}\renewcommand{\headrulewidth}{0pt}\fancyfoot[C]{\texttt{ID Copie : !COPY_ID! \quad - \quad Page \thepage}}}"
) else (
    :: Standard filename without ID
    for %%I in ("%input_file%") do set "output_file=%%~dpnI.pdf"
    
    set "TAG_FANCY="
    set "TAG_STYLE="
    set "TAG_HEAD="
    set "TAG_FOOT="
    set "TAG_PLAIN="
)

echo Output will be saved to: !output_file!

:: Use SCRIPT_DIR to reliably find resources
set "listings_file=%SCRIPT_DIR%resources\tex\listings-2.tex"
set "generator_script=%SCRIPT_DIR%generate_diagrams.py"
set "lua_filter=%SCRIPT_DIR%mermaid-swap.lua"
set "callout_filter=%SCRIPT_DIR%callout.lua"

if not exist "%listings_file%" (
    echo Error: file not found: %listings_file%
    echo Please ensure the file exists in the resources\tex directory
    exit /b 1
)

:: ---------------- GENERATE DIAGRAMS ----------------
if exist "%generator_script%" (
    echo Running Mermaid Generator...
    python "%generator_script%" "%input_file%"
) else (
    echo Warning: Generator script not found at %generator_script%
)

:: ---------------- CONVERT TO PDF ----------------

:: Extract the directory and the pure filename of the input
for %%I in ("%input_file%") do (
    set "input_dir=%%~dpI"
    set "input_name=%%~nxI"
)

:: Temporarily change into the markdown file's directory
echo Moving into !input_dir! to resolve image paths...
pushd "!input_dir!"

echo Converting with Pandoc ^(XeLaTeX Engine^)...

:: Run pandoc on the local file name, outputting to the absolute output path
pandoc -s "!input_name!" -o "!output_file!" ^
    --pdf-engine=xelatex ^
    -V geometry:margin=0.5in ^
    -V papersize=a4 ^
    -V header-includes="\usepackage{fontawesome5}" ^
    -V header-includes="\usepackage{tcolorbox}" ^
    -V header-includes="\usepackage{float}" ^
    -V header-includes="\floatplacement{figure}{H}" ^
    !TAG_FANCY! ^
    !TAG_STYLE! ^
    !TAG_HEAD! ^
    !TAG_FOOT! ^
    !TAG_PLAIN! ^
    --standalone ^
    --syntax-highlighting=idiomatic ^
    --lua-filter="%lua_filter%" ^
    --lua-filter="%callout_filter%" ^
    -H "%listings_file%"

:: Return to the original directory we started in
popd

if exist "!output_file!" (
    echo Success: Created "!output_file!"
) else (
    echo Failed to convert "%input_file%"
)
