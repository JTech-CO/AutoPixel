@echo off
title AutoPixel DIAGNOSTIC
echo ==================================================
echo   AutoPixel  DIAGNOSTIC
echo ==================================================
echo.
echo Folder = %~dp0
if exist "%~dp0AutoPixel.ahk" (echo   [OK]    AutoPixel.ahk found) else (echo   [ERROR] AutoPixel.ahk NOT found in this folder)
echo.
echo --- Check known interpreter paths ---
set "FOUND="
for %%P in (
 "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
 "C:\Program Files\AutoHotkey\AutoHotkey64.exe"
 "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe"
 "C:\Program Files\AutoHotkey\AutoHotkey32.exe"
) do (
 if exist "%%~P" (echo   [FOUND] %%~P & if not defined FOUND set "FOUND=%%~P") else (echo   [ none] %%~P)
)
echo.
echo --- Full recursive search under install dir ---
where /r "C:\Program Files\AutoHotkey" AutoHotkey*.exe 2>nul
echo.

if defined FOUND (
 echo Launching directly with:
 echo    %FOUND%
 echo ( If the AutoPixel panel appears, it WORKS. Keep this window open. )
 echo.
 "%FOUND%" "%~dp0AutoPixel.ahk"
 echo.
 echo AHK process ended.  errorlevel = %errorlevel%
) else (
 echo No interpreter found in the standard paths. Trying file association...
 start "" "%~dp0AutoPixel.ahk"
)

echo.
pause
