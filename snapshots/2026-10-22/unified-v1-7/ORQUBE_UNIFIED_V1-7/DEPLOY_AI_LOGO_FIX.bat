@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\DEPLOY_AI_LOGO_FIX.ps1"
echo.
pause
