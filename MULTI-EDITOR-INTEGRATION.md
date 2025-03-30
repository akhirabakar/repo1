# Multi-Editor Integration: Replit and Cursor

This document provides detailed information about the integration between Replit and Cursor AI editors in this project, explaining how the synchronization works and how to troubleshoot common issues.

## Overview

The multi-editor integration enables:

1. **Bi-directional synchronization** between Replit and Cursor environments
2. **Event tracking** for all actions in both environments
3. **Automated workflows** via GitHub Actions
4. **Health monitoring** to ensure the integration remains functional

## How It Works

### Architecture

```
┌─────────────┐         ┌───────────────┐         ┌─────────────┐
│             │         │               │         │             │
│   Replit    │◄────────┤ GitHub Actions│◄────────┤   Cursor    │
│  Environment│         │   Workflow    │         │ Environment │
│             │──────►  │               │  ◄──────│             │
└─────────────┘         └───────────────┘         └─────────────┘
       ▲                        ▲                        ▲
       │                        │                        │
       │                        │                        │
       ▼                        ▼                        ▼
┌─────────────┐         ┌───────────────┐         ┌─────────────┐
│   Replit    │         │   Monitor     │         │   Cursor    │
│  Webhook    │◄────────┤   Dashboard   │◄────────┤  Listener   │
│  Handler    │         │               │         │             │
└─────────────┘         └───────────────┘         └─────────────┘
```

### Components

1. **GitHub Actions Workflow**:
   - Located in `.github/workflows/multi-editor-integration.yml`
   - Processes events from both environments
   - Executes synchronization logic
   - Performs scheduled health checks

2. **Replit Webhook Handler**:
   - Located in `replit-webhook-handler.js`
   - Receives events from Replit via ngrok
   - Forwards events to the monitor and GitHub Actions

3. **Cursor Listener**:
   - Located in `cursor-ai-listener.js`
   - Listens for Cursor AI events
   - Also supports VSCode extension integration
   - Forwards events to the monitor and GitHub Actions

4. **Monitor Dashboard**:
   - Located in `monitor-server.js`
   - Visualizes the status of all integrations
   - Displays real-time events and logs

## Setting Up the Integration

### Step 1: Configure Environment Variables

Create or edit your `.env` file with the following settings:

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

# Ngrok Configuration
ENABLE_NGROK=true
NGROK_AUTH_TOKEN=your_ngrok_auth_token

# Server Configuration
PORT=3001
NODE_ENV=development
```

### Step 2: Start the Integration Services

#### On Windows:

```powershell
# Using PowerShell
.\start-cursor-replit-integration.ps1

# Or using Command Prompt
start-cursor-replit-integration.bat
```

#### On Linux/Mac:

```bash
chmod +x start-cursor-replit-integration.sh
./start-cursor-replit-integration.sh
```

### Step 3: Configure Replit Webhook

1. Start the integration services (Step 2)
2. Look for the ngrok URL in the console output or monitor dashboard
3. In your Replit project:
   - Go to your project settings
   - Navigate to "Webhooks" section
   - Add a new webhook with the ngrok URL + `/api/replit-events` path
   - Select events: Deploy, Run, Debug

### Step 4: Configure Cursor Integration

#### Option A: Direct Cursor AI Integration
If you have Cursor AI API access:
1. Set the `CURSOR_AI_API_KEY` and `CURSOR_AI_PROJECT_IDS` in your `.env` file
2. Restart the integration services

#### Option B: VSCode Extension Integration
If you don't have Cursor AI API access:
1. Set `CURSOR_ENABLE_VSCODE=true` in your `.env` file
2. Install the VSCode extension:

On Windows:
```powershell
$extensionDir = "$env:USERPROFILE\.vscode\extensions\cursor-monitor"
New-Item -ItemType Directory -Force -Path $extensionDir
Copy-Item "vscode-monitor-extension.js" "$extensionDir\extension.js"
```

On Linux/Mac:
```bash
mkdir -p ~/.vscode/extensions/cursor-monitor
cp vscode-monitor-extension.js ~/.vscode/extensions/cursor-monitor/extension.js
```

### Step 5: Test the Integration

Run the integration test script:

```bash
node test-integrations.js
```

This will:
- Check health of all components
- Test Replit integration
- Test Cursor integration
- Simulate the GitHub Actions workflow

## Event Types

### Replit Events

| Event | Description | Actions Triggered |
|-------|-------------|-------------------|
| `deploy` | Code deployed in Replit | Update GitHub, sync to Cursor |
| `run` | Project run in Replit | Log execution, capture output |
| `debug` | Debug session started | Log debug activity |

### Cursor Events

| Event | Description | Actions Triggered |
|-------|-------------|-------------------|
| `edit` | File edited in Cursor | Sync to GitHub and Replit |
| `generate` | AI-generated code | Log the generated code, sync to Replit |
| `selection` | Code selected | Track selection patterns |
| `fileOpen` | File opened | Track file access patterns |

## GitHub Actions Workflow

The GitHub Actions workflow is triggered by:

1. **Push events** to main/master branches
2. **Pull request events** to main/master branches
3. **Repository dispatch events** from Replit or Cursor
4. **Scheduled runs** every 6 hours for health checks

The workflow performs:

1. Processing of events from both environments
2. Logging events to a history file
3. Deployment to Replit when changes come from Cursor
4. Synchronization to Cursor when changes come from Replit
5. Regular health checks during scheduled runs

## Troubleshooting

### Replit Integration Issues

1. **Replit webhook isn't receiving events**
   - Check if ngrok is running and the URL is correctly configured
   - Verify the Replit API key in your `.env` file
   - Check the logs in `logs/replit_*.log`

2. **Ngrok tunnel disconnects**
   - Ensure your ngrok auth token is valid
   - Check for any connection issues with ngrok service
   - Restart the integration services

### Cursor Integration Issues

1. **Cursor events aren't being captured**
   - If using direct API, verify your Cursor API key
   - If using VSCode extension, check if the extension is correctly installed
   - Check the logs in `logs/cursor_*.log`

2. **VSCode extension not working**
   - Ensure the extension is installed in the correct directory
   - Restart VSCode after installation
   - Check VSCode's extension log for errors

### GitHub Workflow Issues

1. **GitHub workflow not triggering**
   - Verify your GitHub token has sufficient permissions
   - Check if the repository dispatch events are being sent correctly
   - Check GitHub Actions logs in your repository

2. **Synchronization failing**
   - Check if both environments are accessible
   - Verify that the correct repository variables are set
   - Check for any conflicts or permission issues

## Advanced Configuration

### Configuring Event Handling Rules

You can customize how events are processed by modifying:

1. **Replit Webhook Handler**: `replit-webhook-handler.js`
2. **Cursor Listener**: `cursor-ai-listener.js`
3. **GitHub Workflow**: `.github/workflows/multi-editor-integration.yml`

### Custom Synchronization Logic

To implement custom synchronization rules:

1. Edit the relevant step in `.github/workflows/multi-editor-integration.yml`:
   - For Replit events: `Process Replit Events` step
   - For Cursor events: `Process Cursor AI Events` step

2. Add your custom logic using JavaScript node scripts or shell commands.

### Adding More Editors

To extend the integration to more editors:

1. Create a new webhook handler or listener similar to existing ones
2. Update the GitHub workflow to process events from the new editor
3. Add deployment/synchronization steps in the workflow

## Monitoring and Metrics

The integration provides the following monitoring features:

1. **Real-time event visualization** in the monitor dashboard
2. **Integration health indicators** for each component
3. **Event logs** stored in the `logs/` directory
4. **Event history** in `logs/integration-events.log`

## Contributing

To contribute to the multi-editor integration:

1. Ensure all new event types are properly documented
2. Add comprehensive error handling for robustness
3. Include tests for any new functionality
4. Update this documentation with any changes to the integration process 