# ================================================
# Start Cursor and Replit Integration Script
# ================================================
# This script starts both the monitor server with Replit integration
# and the Cursor AI listener for a complete integration setup.

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "🚀 Starting Cursor and Replit Integration..." -ForegroundColor Cyan

# Make sure we have a .env file
if (-not (Test-Path "$scriptPath\.env")) {
    Write-Host "⚠️ .env file not found. Creating a sample .env file..." -ForegroundColor Yellow
    @"
# GitHub Integration
GITHUB_TOKEN=your_github_personal_access_token
GITHUB_REPOS=your_username/your_repo

# Replit Integration with ngrok
REPLIT_API_KEY=your_replit_api_key
REPLIT_WORKSPACE_IDS=workspace_id1,workspace_id2

# Cursor Integration via VSCode Extension
CURSOR_ENABLE_VSCODE=true
CURSOR_AI_API_KEY=your_cursor_api_key
CURSOR_AI_PROJECT_IDS=project_id1,project_id2

# Ngrok Configuration for Replit webhooks
ENABLE_NGROK=true
NGROK_AUTH_TOKEN=your_ngrok_auth_token

# Server Configuration
PORT=3001
NODE_ENV=development
"@ | Out-File -FilePath "$scriptPath\.env" -Encoding utf8
    Write-Host "✅ Sample .env file created. Please edit it with your actual values." -ForegroundColor Green
    Write-Host "   Press any key to continue with the default configuration..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Create logs directory if it doesn't exist
if (-not (Test-Path "$scriptPath\logs")) {
    Write-Host "📁 Creating logs directory..." -ForegroundColor Blue
    New-Item -ItemType Directory -Force -Path "$scriptPath\logs" | Out-Null
    Write-Host "✅ Logs directory created." -ForegroundColor Green
}

# Check for existing processes
$monitorPort = 3001
$cursorPort = 8347

$monitorProcess = Get-NetTCPConnection -LocalPort $monitorPort -ErrorAction SilentlyContinue | Select-Object -First 1
$cursorProcess = Get-NetTCPConnection -LocalPort $cursorPort -ErrorAction SilentlyContinue | Select-Object -First 1

if ($monitorProcess) {
    Write-Host "⚠️ Another process is already using port $monitorPort. The monitor server may not start correctly." -ForegroundColor Yellow
}

if ($cursorProcess) {
    Write-Host "⚠️ Another process is already using port $cursorPort. The Cursor listener may not start correctly." -ForegroundColor Yellow
}

# Check if npm is installed
try {
    $npmVersion = npm --version
    Write-Host "✅ npm version $npmVersion found." -ForegroundColor Green
} catch {
    Write-Host "❌ npm not found! Please install Node.js and npm." -ForegroundColor Red
    exit 1
}

# Check if node_modules directory exists
if (-not (Test-Path "$scriptPath\node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Blue
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies." -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Dependencies installed successfully." -ForegroundColor Green
}

# Start both services concurrently
Write-Host "🔄 Starting monitor server with Replit integration and Cursor listener..." -ForegroundColor Cyan

# Create a timestamp for log files
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$replitLogFile = "$scriptPath\logs\replit_$timestamp.log"
$cursorLogFile = "$scriptPath\logs\cursor_$timestamp.log"

# Start the monitor server with Replit integration
Start-Process -FilePath "powershell" -ArgumentList "-Command `"npm run replit | Tee-Object -FilePath '$replitLogFile'`"" -WindowStyle Normal
Write-Host "✅ Monitor server with Replit integration started. Log file: $replitLogFile" -ForegroundColor Green

# Start the Cursor AI listener
Start-Process -FilePath "powershell" -ArgumentList "-Command `"npm run cursor | Tee-Object -FilePath '$cursorLogFile'`"" -WindowStyle Normal
Write-Host "✅ Cursor AI listener started. Log file: $cursorLogFile" -ForegroundColor Green

# Wait a moment for services to initialize
Start-Sleep -Seconds 5

# Try to open the dashboard in the default browser
try {
    Start-Process "http://localhost:3001"
    Write-Host "🌐 Opening dashboard in browser..." -ForegroundColor Cyan
} catch {
    Write-Host "⚠️ Could not open browser automatically. Please navigate to http://localhost:3001" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Integration environment started!" -ForegroundColor Green
Write-Host "   Monitor Dashboard: http://localhost:3001" -ForegroundColor Cyan
Write-Host "   Cursor Listener:  http://localhost:8347" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Press Ctrl+C in the individual terminal windows to stop the services." -ForegroundColor Yellow
Write-Host "🧪 To test the integration, run: node test-integrations.js" -ForegroundColor Magenta 