@echo off
setlocal
cd /d %~dp0

echo [1/4] Checking AI Functions JavaScript...
call npm --prefix functions_ai run check
if errorlevel 1 goto :fail

echo [2/4] Deploying Firestore rules...
call firebase deploy --only firestore:rules
if errorlevel 1 goto :fail

echo [3/4] Deploying AI-only Functions codebase...
call firebase deploy --only functions:ai
if errorlevel 1 goto :fail

echo [4/4] Building and deploying Flutter Web...
call flutter build web
if errorlevel 1 goto :fail
call firebase deploy --only hosting
if errorlevel 1 goto :fail

echo.
echo ORQUBE 8-29 AI Multichain deployment completed.
goto :eof

:fail
echo.
echo Deployment stopped because a command failed.
exit /b 1
