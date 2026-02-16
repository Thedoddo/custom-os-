const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');

// Import system integration modules
const launcher = require('./system/launcher');
const wineManager = require('./system/wine-manager');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    fullscreen: true,
    frame: false,
    backgroundColor: '#1a1a1a',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'renderer', 'index.html'));

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Initialize app
app.whenReady().then(() => {
  console.log('CustomOS Desktop Environment starting...');
  
  // Initialize system modules
  launcher.init();
  wineManager.init();
  
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  // On Linux, don't quit when windows are closed
  // This is a desktop environment, not a regular app
  // if (process.platform !== 'linux') {
  //   app.quit();
  // }
});

// IPC Handlers for renderer process

// Get all installed applications
ipcMain.handle('get-applications', async () => {
  return await launcher.getAllApplications();
});

// Launch an application
ipcMain.handle('launch-app', async (event, appPath, appType) => {
  try {
    await launcher.launchApplication(appPath, appType);
    return { success: true };
  } catch (error) {
    console.error('Failed to launch app:', error);
    return { success: false, error: error.message };
  }
});

// Get recent applications
ipcMain.handle('get-recent-apps', async () => {
  return await launcher.getRecentApplications();
});

// Search applications
ipcMain.handle('search-apps', async (event, query) => {
  return await launcher.searchApplications(query);
});

// System power controls
ipcMain.handle('system-shutdown', async () => {
  spawn('systemctl', ['poweroff']);
});

ipcMain.handle('system-reboot', async () => {
  spawn('systemctl', ['reboot']);
});

ipcMain.handle('system-logout', async () => {
  app.quit();
});

// Wine-specific handlers
ipcMain.handle('get-wine-apps', async () => {
  return await wineManager.getInstalledWineApps();
});

ipcMain.handle('configure-wine-app', async (event, appPath, config) => {
  return await wineManager.configureApp(appPath, config);
});

// File manager integration
ipcMain.handle('open-file-manager', async (event, path) => {
  spawn('xdg-open', [path || process.env.HOME]);
});

// Notifications
ipcMain.handle('show-notification', (event, title, body) => {
  const { Notification } = require('electron');
  new Notification({ title, body }).show();
});

console.log('CustomOS Desktop Environment initialized');
