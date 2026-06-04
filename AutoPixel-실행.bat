@echo off
rem ============================================================
rem  AutoPixel launcher
rem  Finds the installed AutoHotkey v2 interpreter and runs
rem  AutoPixel.ahk. Just double-click this file.
rem  (self-contained: works even if you move this folder)
rem ============================================================
setlocal
set "SCRIPT=%~dp0AutoPixel.ahk"
set "FOUND="

rem 1) known paths first
for %%P in (
 "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
 "C:\Program Files\AutoHotkey\AutoHotkey64.exe"
 "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"
 "C:\Program Files\AutoHotkey\AutoHotkey32.exe"
) do if not defined FOUND if exist "%%~P" set "FOUND=%%~P"

rem 2) recursive search under install dir
if not defined FOUND for /f "delims=" %%I in ('where /r "C:\Program Files\AutoHotkey" AutoHotkey64.exe 2^>nul') do if not defined FOUND set "FOUND=%%I"

if defined FOUND (
 start "" "%FOUND%" "%SCRIPT%"
) else (
 rem 3) last resort: run via file association
 start "" "%SCRIPT%"
)
endlocal
