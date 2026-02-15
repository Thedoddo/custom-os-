const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1920,
    height: 1080,
    frame: process.platform !== 'linux', // Use native frame on Linux for system integration
    transparent: false,
    backgroundColor: '#0a0a0a',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  // Load the app
  if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    // In production, load from the dist-vite folder at the app root
    const indexPath = app.isPackaged 
      ? path.join(process.resourcesPath, 'app.asar', 'dist-vite', 'index.html')
      : path.join(__dirname, '../../dist-vite/index.html');
    mainWindow.loadFile(indexPath);
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// IPC handlers for desktop functionality
ipcMain.handle('minimize-window', () => {
  mainWindow?.minimize();
});

ipcMain.handle('maximize-window', () => {
  if (mainWindow?.isMaximized()) {
    mainWindow.unmaximize();
  } else {
    mainWindow?.maximize();
  }
});

ipcMain.handle('close-window', () => {
  mainWindow?.close();
});

ipcMain.handle('get-system-info', async () => {
  return {
    osName: 'Your Custom OS',
    version: '1.0.0',
    platform: process.platform
  };
});

// Window management for Linux DE
ipcMain.handle('get-windows-list', async () => {
  if (process.platform !== 'linux') return [];
  
  try {
    const { exec } = require('child_process');
    const { promisify } = require('util');
    const execAsync = promisify(exec);
    
    // Use wmctrl to get window list (requires wmctrl installed)
    const { stdout } = await execAsync('wmctrl -l -x');
    const lines = stdout.trim().split('\n');
    
    const windows = lines.map(line => {
      const parts = line.split(/\s+/);
      return {
        id: parts[0],
        desktop: parts[1],
        class: parts[2],
        title: parts.slice(3).join(' ')
      };
    }).filter(win => !win.class.includes('custom-os')); // Filter out our own window
    
    return windows;
  } catch (error) {
    console.error('Error getting windows:', error);
    return [];
  }
});

ipcMain.handle('focus-window', async (event, windowId) => {
  if (process.platform !== 'linux') return;
  
  try {
    const { exec } = require('child_process');
    await exec(`wmctrl -ia ${windowId}`);
  } catch (error) {
    console.error('Error focusing window:', error);
  }
});

ipcMain.handle('close-app-window', async (event, windowId) => {
  if (process.platform !== 'linux') return;
  
  try {
    const { exec } = require('child_process');
    await exec(`wmctrl -ic ${windowId}`);
  } catch (error) {
    console.error('Error closing window:', error);
  }
});
