@echo off
REM ================================================
REM Start Cursor and Replit Integration Script
REM ================================================
REM This script starts both the monitor server with Replit integration
REM and the Cursor AI listener for a complete integration setup.

echo 🚀 Starting Cursor and Replit Integration...

REM Check if npm is installed
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo ❌ npm not found! Please install Node.js and npm.
  exit /b 1
)

REM Create logs directory if it doesn't exist
if not exist logs mkdir logs

REM Get timestamp for log files
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"
set "REPLIT_LOG_FILE=logs\replit_%TIMESTAMP%.log"
set "CURSOR_LOG_FILE=logs\cursor_%TIMESTAMP%.log"

echo 🔄 Starting monitor server with Replit integration and Cursor listener...

REM Start the monitor server with Replit integration
start "Monitor Server with Replit" cmd /c "npm run replit > %REPLIT_LOG_FILE% 2>&1"
echo ✅ Monitor server with Replit integration started. Log file: %REPLIT_LOG_FILE%

REM Start the Cursor AI listener
start "Cursor AI Listener" cmd /c "npm run cursor > %CURSOR_LOG_FILE% 2>&1"
echo ✅ Cursor AI listener started. Log file: %CURSOR_LOG_FILE%

REM Wait a moment for services to initialize
timeout /t 5 /nobreak > nul

REM Try to open the dashboard in the default browser
start http://localhost:3001
echo 🌐 Opening dashboard in browser...

echo.
echo 🎉 Integration environment started!
echo    Monitor Dashboard: http://localhost:3001
echo    Cursor Listener:  http://localhost:8347
echo.
echo 📋 Close the opened terminal windows to stop the services.
echo 🧪 To test the integration, open a new command prompt and run: node test-integrations.js 