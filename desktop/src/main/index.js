const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');
const systemInfo = require('./system');

let panelWindow;
let launcherWindow;

// Configuration
const PANEL_HEIGHT = 40;

function createPanel() {
  const primaryDisplay = screen.getPrimaryDisplay();
  const { width } = primaryDisplay.workAreaSize;

  panelWindow = new BrowserWindow({
    width: width,
    height: PANEL_HEIGHT,
    x: 0,
    y: 0,
    frame: false,
    transparent: false,
    resizable: false,
    movable: false,
    skipTaskbar: true,
    alwaysOnTop: true,
    type: 'toolbar', // Important for X11 panel behavior
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  panelWindow.loadFile(path.join(__dirname, '../renderer/panel.html'));
  
  // Ensure panel stays on top
  panelWindow.setAlwaysOnTop(true, 'screen-saver');
  
  // Prevent closing
  panelWindow.on('close', (event) => {
    event.preventDefault();
  });

  if (process.env.NODE_ENV === 'development') {
    panelWindow.webContents.openDevTools({ mode: 'detach' });
  }
}

function createLauncher() {
  const primaryDisplay = screen.getPrimaryDisplay();
  const { width, height } = primaryDisplay.workAreaSize;

  launcherWindow = new BrowserWindow({
    width: 600,
    height: 400,
    x: Math.floor((width - 600) / 2),
    y: Math.floor((height - 400) / 2),
    frame: false,
    transparent: true,
    show: false,
    skipTaskbar: true,
    resizable: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  launcherWindow.loadFile(path.join(__dirname, '../renderer/launcher.html'));

  // Hide when losing focus
  launcherWindow.on('blur', () => {
    launcherWindow.hide();
  });
}

// IPC Handlers
ipcMain.handle('get-system-info', async () => {
  return await systemInfo.getSystemInfo();
});

ipcMain.handle('toggle-launcher', () => {
  if (launcherWindow.isVisible()) {
    launcherWindow.hide();
  } else {
    launcherWindow.show();
    launcherWindow.focus();
  }
});

ipcMain.handle('launch-app', async (event, command) => {
  const { exec } = require('child_process');
  exec(command, (error) => {
    if (error) {
      console.error(`Failed to launch ${command}:`, error);
    }
  });
  launcherWindow.hide();
});

ipcMain.handle('shutdown', () => {
  const { exec } = require('child_process');
  exec('systemctl poweroff');
});

ipcMain.handle('reboot', () => {
  const { exec } = require('child_process');
  exec('systemctl reboot');
});

ipcMain.handle('logout', () => {
  app.quit();
});

// App lifecycle
app.whenReady().then(() => {
  createPanel();
  createLauncher();

  // Update system info periodically
  setInterval(() => {
    if (panelWindow && !panelWindow.isDestroyed()) {
      systemInfo.getSystemInfo().then(info => {
        panelWindow.webContents.send('system-info-update', info);
      });
    }
  }, 2000);
});

app.on('window-all-closed', (event) => {
  // Prevent app from quitting when windows are closed
  event.preventDefault();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createPanel();
    createLauncher();
  }
});

// Handle errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
});
