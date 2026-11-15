@echo off
setlocal
title Lunar Base Rewind - Local Launcher
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\windows\run-game.ps1" %*
if errorlevel 1 (
  echo.
  echo The game could not start. Read the error above and logs\launcher-*.log.
  pause
  exit /b 1
)
exit /b 0
