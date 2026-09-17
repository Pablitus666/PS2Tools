@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo PS2Tools - Launcher Portable
echo ============================================

where dotnet >nul 2>&1 || (
    echo ERROR: .NET SDK no encontrado.
    exit /b 1
)

if not exist "icon.ico" (
    echo ERROR: icon.ico no existe.
    exit /b 1
)

if not exist "PS2Tools.Payload.zip" (
    echo ERROR: PS2Tools.Payload.zip no existe.
    exit /b 1
)

if not exist "PowerShell.Payload.zip" (
    echo ERROR: PowerShell.Payload.zip no existe.
    exit /b 1
)

echo [1/2] Verificando payloads...
for %%F in ("PS2Tools.Payload.zip" "PowerShell.Payload.zip") do (
    if not exist "%%~F" (
        echo ERROR: No se encontro %%~F
        exit /b 1
    )
)

echo [2/2] Publicando EXE...
if exist bin rmdir /s /q bin
if exist obj rmdir /s /q obj

dotnet publish PS2ToolsLauncher.csproj -c Release -r win-x64 --self-contained true || exit /b 1

echo.
echo BUILD COMPLETE
echo EXE:
echo %CD%\bin\Release\net8.0-windows\win-x64\publish\PS2Tools.exe