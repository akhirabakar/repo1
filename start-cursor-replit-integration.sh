#!/bin/bash
# ================================================
# Start Cursor and Replit Integration Script
# ================================================
# This script starts both the monitor server with Replit integration
# and the Cursor AI listener for a complete integration setup.

set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "\e[96m🚀 Starting Cursor and Replit Integration...\e[0m"

# Make sure we have a .env file
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo -e "\e[93m⚠️ .env file not found. Creating a sample .env file...\e[0m"
    cat > "$SCRIPT_DIR/.env" << EOL
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
EOL
    echo -e "\e[92m✅ Sample .env file created. Please edit it with your actual values.\e[0m"
    echo -e "\e[93m   Press any key to continue with the default configuration...\e[0m"
    read -n 1 -s
fi

# Create logs directory if it doesn't exist
if [ ! -d "$SCRIPT_DIR/logs" ]; then
    echo -e "\e[94m📁 Creating logs directory...\e[0m"
    mkdir -p "$SCRIPT_DIR/logs"
    echo -e "\e[92m✅ Logs directory created.\e[0m"
fi

# Check for existing processes
MONITOR_PORT=3001
CURSOR_PORT=8347

if command -v lsof &> /dev/null; then
    MONITOR_PROCESS=$(lsof -i:$MONITOR_PORT -t 2>/dev/null)
    CURSOR_PROCESS=$(lsof -i:$CURSOR_PORT -t 2>/dev/null)
    
    if [ -n "$MONITOR_PROCESS" ]; then
        echo -e "\e[93m⚠️ Another process (PID: $MONITOR_PROCESS) is already using port $MONITOR_PORT. The monitor server may not start correctly.\e[0m"
    fi
    
    if [ -n "$CURSOR_PROCESS" ]; then
        echo -e "\e[93m⚠️ Another process (PID: $CURSOR_PROCESS) is already using port $CURSOR_PORT. The Cursor listener may not start correctly.\e[0m"
    fi
fi

# Check if npm is installed
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "\e[92m✅ npm version $NPM_VERSION found.\e[0m"
else
    echo -e "\e[91m❌ npm not found! Please install Node.js and npm.\e[0m"
    exit 1
fi

# Check if node_modules directory exists
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    echo -e "\e[94m📦 Installing dependencies...\e[0m"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "\e[91m❌ Failed to install dependencies.\e[0m"
        exit 1
    fi
    echo -e "\e[92m✅ Dependencies installed successfully.\e[0m"
fi

# Start both services concurrently
echo -e "\e[96m🔄 Starting monitor server with Replit integration and Cursor listener...\e[0m"

# Create a timestamp for log files
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
REPLIT_LOG_FILE="$SCRIPT_DIR/logs/replit_$TIMESTAMP.log"
CURSOR_LOG_FILE="$SCRIPT_DIR/logs/cursor_$TIMESTAMP.log"

# Start the monitor server with Replit integration in the background
npm run replit > "$REPLIT_LOG_FILE" 2>&1 &
REPLIT_PID=$!
echo -e "\e[92m✅ Monitor server with Replit integration started. PID: $REPLIT_PID, Log file: $REPLIT_LOG_FILE\e[0m"

# Start the Cursor AI listener in the background
npm run cursor > "$CURSOR_LOG_FILE" 2>&1 &
CURSOR_PID=$!
echo -e "\e[92m✅ Cursor AI listener started. PID: $CURSOR_PID, Log file: $CURSOR_LOG_FILE\e[0m"

# Save PIDs for cleanup
echo "$REPLIT_PID" > "$SCRIPT_DIR/logs/replit.pid"
echo "$CURSOR_PID" > "$SCRIPT_DIR/logs/cursor.pid"

# Wait a moment for services to initialize
sleep 5

# Try to open the dashboard in the default browser
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:3001" &> /dev/null
    echo -e "\e[96m🌐 Opening dashboard in browser...\e[0m"
elif command -v open &> /dev/null; then
    open "http://localhost:3001" &> /dev/null
    echo -e "\e[96m🌐 Opening dashboard in browser...\e[0m"
else
    echo -e "\e[93m⚠️ Could not open browser automatically. Please navigate to http://localhost:3001\e[0m"
fi

echo ""
echo -e "\e[92m🎉 Integration environment started!\e[0m"
echo -e "\e[96m   Monitor Dashboard: http://localhost:3001\e[0m"
echo -e "\e[96m   Cursor Listener:  http://localhost:8347\e[0m"
echo ""
echo -e "\e[93m📋 To stop the services, run: ./stop-cursor-replit-integration.sh\e[0m"
echo -e "\e[95m🧪 To test the integration, run: node test-integrations.js\e[0m"

# Create a stop script for easy cleanup
cat > "$SCRIPT_DIR/stop-cursor-replit-integration.sh" << 'EOL'
#!/bin/bash
# Stop script for Cursor and Replit integration

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "\e[96m🛑 Stopping Cursor and Replit Integration Services...\e[0m"

if [ -f "$SCRIPT_DIR/logs/replit.pid" ]; then
    REPLIT_PID=$(cat "$SCRIPT_DIR/logs/replit.pid")
    if ps -p $REPLIT_PID > /dev/null; then
        kill $REPLIT_PID
        echo -e "\e[92m✅ Monitor server with Replit integration stopped.\e[0m"
    else
        echo -e "\e[93m⚠️ Monitor server with Replit integration already stopped.\e[0m"
    fi
    rm "$SCRIPT_DIR/logs/replit.pid"
fi

if [ -f "$SCRIPT_DIR/logs/cursor.pid" ]; then
    CURSOR_PID=$(cat "$SCRIPT_DIR/logs/cursor.pid")
    if ps -p $CURSOR_PID > /dev/null; then
        kill $CURSOR_PID
        echo -e "\e[92m✅ Cursor AI listener stopped.\e[0m"
    else
        echo -e "\e[93m⚠️ Cursor AI listener already stopped.\e[0m"
    fi
    rm "$SCRIPT_DIR/logs/cursor.pid"
fi

echo -e "\e[92m🎉 All services stopped successfully!\e[0m"
EOL

chmod +x "$SCRIPT_DIR/stop-cursor-replit-integration.sh"

# Keep the script running to manage the background processes
trap "echo -e '\e[96m\nShutting down services...\e[0m'; '$SCRIPT_DIR/stop-cursor-replit-integration.sh'; exit 0" SIGINT SIGTERM

# Display the logs in real-time
echo -e "\e[96m📋 Displaying logs (press Ctrl+C to stop services):\e[0m"
echo -e "\e[93m===================== REPLIT LOG =====================\e[0m"
tail -f "$REPLIT_LOG_FILE" &
TAIL_REPLIT_PID=$!

echo -e "\e[94m===================== CURSOR LOG =====================\e[0m"
tail -f "$CURSOR_LOG_FILE" &
TAIL_CURSOR_PID=$!

# Wait for user to exit
wait $TAIL_REPLIT_PID $TAIL_CURSOR_PID 