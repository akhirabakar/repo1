# Real-time Monitoring Dashboard

A comprehensive monitoring dashboard solution that aggregates logs and test results across all components in real-time, with integrations for Replit, Cursor AI, and GitHub Actions.

## Features

- **Real-time Component Map**: Visualize connections between frontend/backend/database
- **Live Log Tailing**: Stream logs from all services
- **Performance Charts**: API response times, DB query latency
- **Smart Alerts**: Regex-based error detection
- **CI/CD Integration**: Monitor GitHub Actions workflows in real-time
- **Replit Integration via ngrok**: Track code changes and deployments from Replit using secure tunneling
- **Cursor Integration via VSCode Extension**: Monitor AI-assisted code generation through VSCode
- **Multi-Editor Integration**: Orchestrate development across Replit and Cursor AI via GitHub Actions

## Project Requirements

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 18.04+ / Debian 10+ recommended)
- **CPU**: 2+ cores recommended for running multiple services simultaneously
- **Memory**: Minimum 4GB RAM, 8GB+ recommended
- **Disk Space**: At least 500MB free space for the application and logs
- **Network**: Stable internet connection for webhook communication
- **Ports**: Ports 3001 and 8347 must be available

### Software Requirements

- **Node.js**: Version 14.x or higher (v16.x recommended)
- **npm**: Version 6.x or higher (comes with Node.js)
- **Git**: Required for GitHub workflow integration
- **VSCode**: Latest version recommended for Cursor integration via extension
- **ngrok**: For exposing local server to internet (for Replit webhooks)

### External Service Requirements

- **GitHub Account**: With permissions to create webhooks and personal access tokens
- **Replit Account**: With API access and the ability to create webhooks
- **Cursor Editor**: For testing AI-assisted code generation integration
- **ngrok Account**: Free tier works for development, paid account for production use

### Permissions Required

- **Local System**: File read/write access to project directory
- **Network**: Outbound connections to GitHub, Replit, and Cursor services
- **GitHub**: Repository admin access to set up webhooks and workflows
- **Replit**: Project access to add webhooks
- **Environment Variables**: Ability to set and modify .env files

## Architecture

```
graph TD
    A[Frontend] -->|HTTP| B[Monitor]
    C[Backend] -->|WebSocket| B
    D[Database] -->|Logs| B
    B --> E[Browser Dashboard]
    B --> F[Grafana]
    B --> G[Alert Manager]
    H[Replit] -->|ngrok Webhooks| B
    I[VSCode Extension] -->|HTTP| B
    B -->|Repository Dispatch| J[GitHub Actions]
    J -->|Orchestration| H
    J -->|Orchestration| I
```

## Team Access

| Team | Access URL | Credentials | Permissions |
|------|------------|-------------|------------|
| Devs | http://monitor.local:3001 | None (read-only) | View all logs |
| Ops | http://grafana.local:3000 | Admin token | Configure alerts |
| Managers | http://monitor.local:3001/summary | None | High-level stats |

## Installation

### Prerequisites

Before installation, ensure you have:

- Node.js (v14+) installed and accessible from command line
- npm package manager (usually comes with Node.js)
- Git for version control and GitHub integration
- A GitHub account with repository access and rights to create tokens
- A Replit account with at least one project set up
- VSCode installed (for Cursor integration)
- An ngrok account and auth token (for Replit webhook integration)
- Open ports 3001 and 8347 on your development machine
- Sufficient permissions to create and modify files in the installation directory

### Quick Start

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure external service connections:
   ```bash
   cp .env.example .env
   # Edit .env file with your API keys and endpoints
   ```

3. Start the full monitoring dashboard with all integrations:
   ```bash
   # On Windows PowerShell
   .\start-cursor-replit-integration.ps1
   
   # On Windows Command Prompt
   start-cursor-replit-integration.bat
   
   # On Linux/Mac
   chmod +x start-cursor-replit-integration.sh
   ./start-cursor-replit-integration.sh
   ```

4. Visit the dashboard at http://localhost:3001

### Docker Deployment

Deploy the complete monitoring stack with Docker Compose:

```bash
docker-compose up -d
```

This will start:
- Monitor server on port 3001
- Prometheus on port 9090
- Grafana on port 3000

### Additional Requirements for Docker Deployment

If using Docker, you'll also need:
- Docker Engine v19.03.0+
- Docker Compose v1.27.0+
- Minimum of 2GB of free RAM for containers
- Ports 3001, 9090, and 3000 available

## Replit and Cursor Integration

This project features a complete integration between Replit and Cursor AI editors, allowing for seamless collaboration and synchronization between both environments.

### Integration Features

- **Bi-directional Sync**: Changes made in either environment are synchronized to the other
- **Event Logging**: All events from both editors are logged and can be viewed in the dashboard
- **GitHub Workflow Integration**: Automated actions are triggered based on events from either editor
- **Health Monitoring**: Regular checks ensure both environments are communicating properly

### Setting Up the Integration

1. Configure your `.env` file with the appropriate credentials:
   ```
   # GitHub Integration
   GITHUB_TOKEN=your_github_personal_access_token
   GITHUB_REPOS=your_username/your_repo
   
   # Replit Integration
   REPLIT_API_KEY=your_replit_api_key
   REPLIT_WORKSPACE_IDS=workspace_id1,workspace_id2
   
   # Cursor Integration
   CURSOR_AI_API_KEY=your_cursor_api_key
   CURSOR_AI_PROJECT_IDS=project_id1,project_id2
   CURSOR_ENABLE_VSCODE=true
   
   # Ngrok Configuration for Replit webhooks
   ENABLE_NGROK=true
   NGROK_AUTH_TOKEN=your_ngrok_auth_token
   ```

2. Start both the Replit integration and Cursor listener using the provided scripts:
   ```bash
   # On Windows PowerShell
   .\start-cursor-replit-integration.ps1
   
   # On Windows Command Prompt
   start-cursor-replit-integration.bat
   
   # On Linux/Mac
   chmod +x start-cursor-replit-integration.sh
   ./start-cursor-replit-integration.sh
   ```

3. Test the integration by running:
   ```bash
   node test-integrations.js
   ```

4. Set up GitHub Actions workflow:
   - The project includes a `.github/workflows/multi-editor-integration.yml` file
   - This workflow handles events from both Replit and Cursor
   - It automatically synchronizes changes between the two environments
   - It runs health checks every 6 hours to ensure the integration is working

### Detailed Integration Documentation

For comprehensive documentation about the Multi-Editor integration, refer to the [MULTI-EDITOR-INTEGRATION.md](./MULTI-EDITOR-INTEGRATION.md) file, which covers:

- Detailed architecture explanation
- Component descriptions
- Event handling
- Step-by-step setup guide
- Troubleshooting procedures
- Advanced configuration options

### Integration Files Overview

The integration is built using several components:

| File | Description |
|------|-------------|
| `.github/workflows/multi-editor-integration.yml` | GitHub Actions workflow that orchestrates communication between editors |
| `start-cursor-replit-integration.ps1` | PowerShell script to start both Replit and Cursor services (Windows) |
| `start-cursor-replit-integration.sh` | Bash script to start both Replit and Cursor services (Linux/Mac) |
| `start-cursor-replit-integration.bat` | Batch script to start both Replit and Cursor services (Windows CMD) |
| `test-integrations.js` | JavaScript utility to test all integrations |
| `replit-webhook-handler.js` | Handler for Replit webhook events |
| `cursor-ai-listener.js` | Listener for Cursor AI events |
| `logs/integration-events.log` | Log file containing all integration events |

### Troubleshooting the Integration

If you encounter issues with the integration:

1. Check the logs in the `logs` directory:
   ```bash
   # View all integration events
   cat logs/integration-events.log
   
   # View Replit logs
   cat logs/replit_*.log
   
   # View Cursor logs
   cat logs/cursor_*.log
   ```

2. Verify that both services are running:
   ```bash
   # For Windows
   Get-NetTCPConnection -LocalPort 3001, 8347 | Format-Table -Property LocalAddress, LocalPort, State
   
   # For Linux/Mac
   lsof -i :3001,8347
   ```

3. Test each component individually:
   ```bash
   # Test Replit integration
   curl -X POST http://localhost:3001/api/replit-events/test
   
   # Test Cursor integration
   curl -X POST http://localhost:8347/api/cursor-events/test
   ```

4. Restart the integration services:
   ```bash
   # On Windows
   # Using PowerShell
   Stop-Process -Name "node" -Force  # Caution: stops all Node.js processes
   .\start-cursor-replit-integration.ps1
   
   # On Linux/Mac
   ./stop-cursor-replit-integration.sh
   ./start-cursor-replit-integration.sh
   ```

5. Check the GitHub Actions workflow status:
   - Go to your GitHub repository > Actions tab
   - Look for any failed runs of the "Multi-Editor Integration Workflow"
   - Check the logs for error messages

## External Service Integration

### GitHub Actions Integration

1. In your GitHub repository, go to Settings > Webhooks
2. Add a new webhook:
   - Payload URL: `http://your-monitor-url:3001/api/github-events`
   - Content type: `application/json`
   - Secret: Your GitHub token
   - Select events: Workflow runs, Deployments, Issues
3. Update your `.env` file with GitHub authentication:
   ```
   GITHUB_TOKEN=your_personal_access_token
   GITHUB_REPOS=owner/repo1,owner/repo2
   ```

### Replit Integration with ngrok

1. Create an ngrok account and get your auth token from the [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)
2. Add ngrok configuration to your `.env` file:
   ```
   # Replit Integration with ngrok
   REPLIT_API_KEY=your_replit_api_key
   REPLIT_WORKSPACE_IDS=workspace_id1,workspace_id2
   
   # Ngrok Configuration for Replit webhook
   ENABLE_NGROK=true
   NGROK_AUTH_TOKEN=your_ngrok_auth_token
   ```
3. Start the dashboard with ngrok enabled:
   ```bash
   npm run replit
   ```
4. Once the dashboard is running, the ngrok URL will be displayed in the Replit component card
5. Configure Replit webhook in your project settings:
   - Go to your Replit project > Tools > Webhooks
   - Add a new webhook using the ngrok URL from the dashboard
   - Events: Deploy, Run, Debug

### Cursor Integration via VSCode Extension

1. Set up the VSCode extension for Cursor integration:
   ```bash
   # Enable VSCode integration in .env file:
   CURSOR_ENABLE_VSCODE=true
   
   # For Windows (PowerShell):
   mkdir -Force "$env:USERPROFILE\.vscode\extensions\cursor-monitor"
   Copy-Item "vscode-monitor-extension.js" "$env:USERPROFILE\.vscode\extensions\cursor-monitor\extension.js"
   
   # For Linux/Mac:
   mkdir -p ~/.vscode/extensions/cursor-monitor
   cp vscode-monitor-extension.js ~/.vscode/extensions/cursor-monitor/extension.js
   ```
2. Create a package.json file for the extension:
   ```json
   {
     "name": "cursor-monitor",
     "displayName": "Cursor Monitor",
     "description": "VSCode integration for the monitoring dashboard",
     "version": "0.0.1",
     "engines": {"vscode": "^1.60.0"},
     "main": "./extension.js",
     "activationEvents": ["*"],
     "contributes": {
       "commands": [{
         "command": "vscode-monitor.test",
         "title": "Test Cursor Monitor Connection"
       }]
     },
     "dependencies": {
       "node-fetch": "^2.6.7"
     }
   }
   ```
3. Start the monitoring server:
   ```bash
   npm run start
   ```
4. Open VSCode and use Ctrl+Shift+P (or Cmd+Shift+P on Mac) to run "Test Cursor Monitor Connection"

## Testing the Integrations

Test all integrations with a single command:

```bash
# Run the comprehensive test script
node test-integrations.js

# For Windows
.\test-integrations.ps1

# For Linux/Mac
./test-integrations.sh
```

Or test individual integrations:

```bash
# Test GitHub Actions integration
npm run workflow

# Test Replit integration
curl -X POST http://localhost:3001/api/replit-events/test

# Test Cursor integration via VSCode
curl -X POST http://localhost:8347/api/vscode-events/test
```

## Troubleshooting

### Integration Issues

1. **GitHub webhook not receiving events**
   - Check your repository webhook settings and event types
   - Ensure your monitor server is publicly accessible or use ngrok for testing

2. **Replit events not appearing**
   - Verify ngrok is running properly - check the dashboard for the webhook URL
   - Confirm your ngrok auth token is valid in the .env file
   - Make sure the webhook is correctly configured in your Replit project

3. **Cursor VSCode extension not connecting**
   - Verify the extension is installed in the correct VSCode extensions directory
   - Check VSCode's Developer Tools (Help > Toggle Developer Tools) for errors
   - Ensure the monitoring server is running at the expected URL (http://localhost:3001)

4. **Port conflicts (EADDRINUSE errors)**
   - If you encounter "address already in use" errors when starting services:
     - For cursor-ai-listener conflicts on port 3002, modify cursor-ai-listener.js to use port 8347 instead
     - Update all related port references in: start-cursor-listener.ps1, vscode-monitor-extension.js, test-vscode-extension.js, test-vscode-integration.ps1
     - Run tests with the updated port: `curl -X POST http://localhost:8347/api/vscode-events/test`
   - For detailed steps on resolving port conflicts, see [SETUP-INTEGRATIONS.md](./SETUP-INTEGRATIONS.md)

For more detailed setup instructions, see [SETUP-INTEGRATIONS.md](./SETUP-INTEGRATIONS.md).

## Development

For development with auto-reload:

```bash
npm run dev
```# repo1
