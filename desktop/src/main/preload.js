const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('api', {
  // System information
  getSystemInfo: () => ipcRenderer.invoke('get-system-info'),
  
  // Launcher
  toggleLauncher: () => ipcRenderer.invoke('toggle-launcher'),
  launchApp: (command) => ipcRenderer.invoke('launch-app', command),
  
  // Power management
  shutdown: () => ipcRenderer.invoke('shutdown'),
  reboot: () => ipcRenderer.invoke('reboot'),
  logout: () => ipcRenderer.invoke('logout'),
  
  // Event listeners
  onSystemInfoUpdate: (callback) => {
    ipcRenderer.on('system-info-update', (event, info) => callback(info));
  }
});
