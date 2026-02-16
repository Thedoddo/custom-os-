const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// select methods of ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Application management
  getApplications: () => ipcRenderer.invoke('get-applications'),
  launchApp: (appPath, appType) => ipcRenderer.invoke('launch-app', appPath, appType),
  getRecentApps: () => ipcRenderer.invoke('get-recent-apps'),
  searchApps: (query) => ipcRenderer.invoke('search-apps', query),
  
  // Wine integration
  getWineApps: () => ipcRenderer.invoke('get-wine-apps'),
  configureWineApp: (appPath, config) => ipcRenderer.invoke('configure-wine-app', appPath, config),
  
  // System controls
  shutdown: () => ipcRenderer.invoke('system-shutdown'),
  reboot: () => ipcRenderer.invoke('system-reboot'),
  logout: () => ipcRenderer.invoke('system-logout'),
  
  // File system
  openFileManager: (path) => ipcRenderer.invoke('open-file-manager', path),
  
  // Notifications
  showNotification: (title, body) => ipcRenderer.invoke('show-notification', title, body),
  
  // Platform info
  platform: process.platform,
  arch: process.arch
});
