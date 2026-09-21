@echo off
setlocal

echo ========================================
echo        FALCON OS BUILD SYSTEM
echo ========================================
echo.

REM ------------------------------------------------
REM Clean old build files
REM ------------------------------------------------

if exist boot.bin del /q boot.bin
if exist kernel.o del /q kernel.o
if exist kernel.elf del /q kernel.elf
if exist kernel.bin del /q kernel.bin
if exist falcon-os.img del /q falcon-os.img

echo [1/5] Assembling bootloader...
nasm -f bin boot.asm -o boot.bin

if errorlevel 1 (
    echo.
    echo ERROR: Bootloader assembly failed.
    pause
    exit /b 1
)

echo Bootloader OK.
echo.

REM ------------------------------------------------
REM Assemble kernel
REM ------------------------------------------------

echo [2/5] Assembling kernel...
nasm -f elf64 kernel.asm -o kernel.o

if errorlevel 1 (
    echo.
    echo ERROR: Kernel assembly failed.
    pause
    exit /b 1
)

echo Kernel assembly OK.
echo.

REM ------------------------------------------------
REM Link kernel
REM ------------------------------------------------

echo [3/5] Linking kernel...
ld -T linker.ld -o kernel.elf kernel.o

if errorlevel 1 (
    echo.
    echo ERROR: Kernel linking failed.
    pause
    exit /b 1
)

echo Kernel linking OK.
echo.

REM ------------------------------------------------
REM Convert ELF kernel to raw binary
REM ------------------------------------------------

echo [4/5] Creating kernel binary...
objcopy -O binary kernel.elf kernel.bin

if errorlevel 1 (
    echo.
    echo ERROR: Kernel binary creation failed.
    pause
    exit /b 1
)

echo Kernel binary OK.
echo.

REM ------------------------------------------------
REM Create disk image
REM ------------------------------------------------

echo [5/5] Creating Falcon OS disk image...

copy /b boot.bin+kernel.bin falcon-os.img >nul

if errorlevel 1 (
    echo.
    echo ERROR: Disk image creation failed.
    pause
    exit /b 1
)

echo.
echo ========================================
echo       FALCON OS BUILD SUCCESSFUL!
echo ========================================
echo.
echo Files created:
echo   boot.bin
echo   kernel.o
echo   kernel.elf
echo   kernel.bin
echo   falcon-os.img
echo.

pause