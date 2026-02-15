const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  minimizeWindow: () => ipcRenderer.invoke('minimize-window'),
  maximizeWindow: () => ipcRenderer.invoke('maximize-window'),
  closeWindow: () => ipcRenderer.invoke('close-window'),
  getSystemInfo: () => ipcRenderer.invoke('get-system-info'),
  platform: process.platform, // Expose platform info
  // Window management for DE mode
  getWindowsList: () => ipcRenderer.invoke('get-windows-list'),
  focusWindow: (windowId) => ipcRenderer.invoke('focus-window', windowId),
  closeAppWindow: (windowId) => ipcRenderer.invoke('close-app-window', windowId)
});
