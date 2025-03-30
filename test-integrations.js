/**
 * Integration Test Script
 * 
 * This script tests all integrations for the monitoring dashboard:
 * - GitHub Actions
 * - Replit (via ngrok)
 * - Cursor (via VSCode extension)
 */

const fetch = require('node-fetch');
const dotenv = require('dotenv');
const axios = require('axios');
const fs = require('fs');

// Load environment variables
dotenv.config();

// Dashboard URL
const DASHBOARD_URL = `http://localhost:${process.env.PORT || 3001}`;

// Configuration
const MONITOR_URL = process.env.MONITOR_URL || 'http://localhost:3001';
const CURSOR_LISTENER_URL = process.env.CURSOR_LISTENER_URL || 'http://localhost:8347';
const REPLIT_API_KEY = process.env.REPLIT_API_KEY;
const CURSOR_API_KEY = process.env.CURSOR_AI_API_KEY;

console.log('🧪 Testing All Integrations');
console.log('===========================');

// Logging function
const log = (message, level = 'info') => {
  const timestamp = new Date().toISOString();
  const prefix = {
    info: '📋',
    warn: '⚠️',
    error: '❌',
    success: '✅'
  }[level] || '📋';
  
  console.log(`${prefix} [${timestamp}] ${message}`);
};

// Ensure the logs directory exists
try {
  if (!fs.existsSync('./logs')) {
    fs.mkdirSync('./logs');
  }
} catch (err) {
  log(`Failed to create logs directory: ${err.message}`, 'error');
}

async function testIntegrations() {
  try {
    // 1. Test dashboard connectivity
    console.log('\n🔍 Testing dashboard connectivity...');
    const statusRes = await fetch(`${DASHBOARD_URL}/status`);
    
    if (statusRes.ok) {
      const statusData = await statusRes.json();
      console.log('✅ Dashboard is running');
      console.log(`   Components detected: ${Object.keys(statusData.components).join(', ')}`);
    } else {
      throw new Error(`Dashboard not running at ${DASHBOARD_URL}`);
    }

    // 2. Test GitHub Actions Integration
    console.log('\n🔍 Testing GitHub Actions integration...');
    const githubRes = await fetch(`${DASHBOARD_URL}/api/github-events/test`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (githubRes.ok) {
      const githubData = await githubRes.json();
      console.log('✅ GitHub Actions integration test successful');
      console.log(`   Event: ${githubData.event?.event || 'workflow_run'} - ${githubData.event?.action || 'completed'}`);
    } else {
      console.error('❌ GitHub Actions integration test failed');
    }

    // 3. Test Replit Integration
    console.log('\n🔍 Testing Replit integration (ngrok)...');
    // Check if ngrok is enabled
    const isNgrokEnabled = process.env.ENABLE_NGROK === 'true';
    if (isNgrokEnabled) {
      console.log('   ngrok is enabled - checking for webhook URL');
      
      // Get the updated components to check for webhook URL
      const componentsRes = await fetch(`${DASHBOARD_URL}/status`);
      const componentsData = await componentsRes.json();
      
      if (componentsData.components.replit?.webhookUrl) {
        console.log(`   Found webhook URL: ${componentsData.components.replit.webhookUrl}`);
      } else {
        console.warn('⚠️ No ngrok webhook URL found yet - ngrok might still be starting');
      }
    } else {
      console.warn('⚠️ ngrok is not enabled in .env file (ENABLE_NGROK=true)');
    }
    
    // Test the Replit event endpoint
    const replitRes = await fetch(`${DASHBOARD_URL}/api/replit-events/test`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (replitRes.ok) {
      const replitData = await replitRes.json();
      console.log('✅ Replit integration test successful');
      console.log(`   Event: ${replitData.event?.event || 'deploy'} on workspace ${replitData.event?.workspace?.name || 'test'}`);
    } else {
      console.error('❌ Replit integration test failed');
    }

    // 4. Test Cursor Integration (VSCode)
    console.log('\n🔍 Testing Cursor integration (VSCode extension)...');
    const isCursorVSCodeEnabled = process.env.CURSOR_ENABLE_VSCODE === 'true';
    
    if (isCursorVSCodeEnabled) {
      console.log('   VSCode extension integration is enabled');
    } else {
      console.warn('⚠️ VSCode extension integration is not enabled in .env file (CURSOR_ENABLE_VSCODE=true)');
    }
    
    // Test the VSCode event endpoint directly on the cursor listener
    const vscodeRes = await fetch(`${CURSOR_LISTENER_URL}/api/vscode-events/test`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (vscodeRes.ok) {
      const vscodeData = await vscodeRes.json();
      console.log('✅ Cursor/VSCode integration test successful');
      console.log(`   Event: ${vscodeData.event?.event || 'test'} on file ${vscodeData.event?.file || 'test-file.js'}`);
    } else {
      console.error('❌ Cursor/VSCode integration test failed');
    }

    // 5. Summary
    console.log('\n📋 Integration Test Summary');
    console.log('===========================');
    console.log('GitHub Actions: ' + (githubRes.ok ? '✅ Connected' : '❌ Failed'));
    console.log('Replit (ngrok): ' + (replitRes.ok ? '✅ Connected' : '❌ Failed'));
    console.log('Cursor (VSCode): ' + (vscodeRes.ok ? '✅ Connected' : '❌ Failed'));
    
    console.log('\n🌐 Dashboard URL: ' + DASHBOARD_URL);
    console.log('Open this URL in your browser to see the dashboard');

  } catch (error) {
    console.error('\n❌ Error during integration tests:', error.message);
    console.error('Make sure the dashboard is running with: npm run start:all');
    process.exit(1);
  }
}

// Run the tests
testIntegrations(); 