@echo off
setlocal

if "%~1"=="" (
    echo Usage: UartHyperCmd.bat ^<command^> [target]
    echo.
    echo Commands:
    echo   clear    [target]  - Clear screen ^(target: port label filter^)
    echo   reset    [target]  - Reset recording
    echo   open     [target]  - Connect serial port^(s^)
    echo   close    [target]  - Disconnect serial port^(s^)
    echo   openFile ^<path^>   - Open a log file in a new window
    echo   tile               - Tile all windows
    echo.
    echo Examples:
    echo   UartHyperCmd.bat clear
    echo   UartHyperCmd.bat clear COM6
    echo   UartHyperCmd.bat reset
    echo   UartHyperCmd.bat open
    echo   UartHyperCmd.bat open COM6
    echo   UartHyperCmd.bat close COM6
    echo   UartHyperCmd.bat openFile D:\logs\test.log
    echo   UartHyperCmd.bat tile
    echo.
    echo NOTE: calling this script from another .bat REQUIRES call:
    echo   call UartHyperCmd.bat close COM6
    echo Without call, cmd.exe transfers control and the caller script ends
    echo right after this script finishes ^(no line after it will run^).
    exit /b 1
)

set "CMD=%~1"
set "TARGET=%~2"

for /f %%A in ('powershell -NoProfile -Command "[int64]((Get-Date)-[datetime]'1970-01-01').TotalMilliseconds"') do set "TS=%%A"

REM Write the command JSON via PowerShell as UTF-8 (no BOM):
REM  - a plain `echo {...}` would encode a non-ASCII path in the console codepage
REM    while the app reads it as UTF-8 -> the path gets corrupted
REM  - values are passed through environment variables so cmd does not re-parse
REM    them (paths containing & ^ quotes etc. stay intact)
set "UH_CMD=%CMD%"
set "UH_TS=%TS%"
set "UH_TARGET=%TARGET%"
powershell -NoProfile -Command "$o=[ordered]@{cmd=$env:UH_CMD;ts=[int64]$env:UH_TS}; if ($env:UH_TARGET) { $o['target']=$env:UH_TARGET }; [IO.File]::WriteAllText((Join-Path $env:TEMP 'UartHyper-cmd.json'), ($o|ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))"

echo Command sent: %CMD% %TARGET%
