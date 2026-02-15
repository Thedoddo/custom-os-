# CustomOS Desktop Development Guide

## Architecture Overview

The CustomOS desktop is built with Electron and follows a secure architecture:

```
┌─────────────────────────────────────────┐
│          Renderer Process(es)           │
│     (UI - HTML/CSS/JavaScript)          │
│                                         │
│  - panel.html     (Top panel)          │
│  - launcher.html  (App launcher)       │
│                                         │
└────────────┬────────────────────────────┘
             │ IPC (Inter-Process Communication)
             │ Context Bridge (preload.js)
             │
┌────────────▼────────────────────────────┐
│          Main Process                   │
│        (Node.js Backend)                │
│                                         │
│  - Window management                    │
│  - System integration (D-Bus)          │
│  - File system access                   │
│  - Child processes (launching apps)    │
└─────────────────────────────────────────┘
```

## Project Structure

```
desktop/
├── src/
│   ├── main/                    # Main process (Node.js)
│   │   ├── index.js            # Application entry point
│   │   ├── preload.js          # Security bridge
│   │   └── system.js           # System information gathering
│   └── renderer/               # Renderer processes (UI)
│       ├── panel.html          # Top panel UI
│       ├── panel.js            # Panel logic
│       ├── launcher.html       # Application launcher UI
│       ├── launcher.js         # Launcher logic
│       └── styles.css          # Global styles
├── resources/                  # Static assets
├── package.json               # Node.js dependencies
└── electron-builder.yml       # Build configuration
```

## Getting Started

### Prerequisites

- Node.js 16+ and npm
- Linux system (for full testing)
- Code editor (VS Code recommended)

### Setup Development Environment

```bash
# Clone and navigate to desktop directory
cd desktop

# Install dependencies
npm install

# Start in development mode
npm start
```

### Development Mode Features

- **DevTools**: Automatically opens for debugging
- **Hot reload**: Restart the app to see changes (no hot reload by default)
- **Console logging**: Check terminal for main process logs

## Key Concepts

### 1. Process Separation

Electron apps have two process types:

**Main Process** (`src/main/index.js`):
- One per app
- Has full Node.js access
- Controls windows
- Handles system operations
- **Security**: Can access everything

**Renderer Process** (`src/renderer/*.html`):
- One per window
- Limited access (for security)
- Runs your UI code
- **Security**: Sandboxed, can't access Node.js directly

### 2. Context Isolation

For security, renderer processes can't directly access Node.js. Instead:

```javascript
// ❌ DON'T - Won't work (nodeIntegration disabled)
const fs = require('fs');

// ✅ DO - Use IPC through preload bridge
window.api.readFile('/path/to/file');
```

### 3. IPC Communication

Communication happens through IPC (Inter-Process Communication):

**Renderer → Main** (Invoke/Send):
```javascript
// In renderer (panel.js)
const result = await window.api.getSystemInfo();
```

**Main → Renderer** (Send):
```javascript
// In main (index.js)
panelWindow.webContents.send('system-info-update', data);
```

**Bridge** (preload.js):
```javascript
contextBridge.exposeInMainWorld('api', {
  getSystemInfo: () => ipcRenderer.invoke('get-system-info')
});
```

## Common Development Tasks

### Add a New Feature to the Panel

**Example**: Add a network indicator

**1. Update system.js** to gather network info:
```javascript
async getNetworkInfo() {
  const networkInterfaces = await si.networkInterfaces();
  return {
    connected: networkInterfaces.some(i => i.operstate === 'up'),
    interfaces: networkInterfaces
  };
}
```

**2. Update main/index.js** to include it:
```javascript
ipcMain.handle('get-system-info', async () => {
  return {
    // ... existing info
    network: await systemInfo.getNetworkInfo()
  };
});
```

**3. Update panel.html** to display it:
```html
<div class="indicator" id="networkIndicator">
  <svg><!-- network icon --></svg>
  <span id="networkText">Connected</span>
</div>
```

**4. Update panel.js** to handle updates:
```javascript
function updateSystemDisplay(info) {
  // ... existing updates
  
  const networkText = document.getElementById('networkText');
  networkText.textContent = info.network.connected ? 'Connected' : 'Disconnected';
}
```

### Add a New Application to Launcher

Edit `src/renderer/launcher.js`:

```javascript
const applications = [
  // ... existing apps
  {
    name: 'Your App',
    command: 'your-app-command',
    icon: '🚀',  // Emoji or SVG
    category: 'Category'
  }
];
```

### Create a New Window

In `src/main/index.js`:

```javascript
function createSettingsWindow() {
  let settingsWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });
  
  settingsWindow.loadFile(path.join(__dirname, '../renderer/settings.html'));
  return settingsWindow;
}

// Add IPC handler to show it
ipcMain.handle('show-settings', () => {
  if (!settingsWindow) {
    settingsWindow = createSettingsWindow();
  }
  settingsWindow.show();
});
```

### Integrate with D-Bus (System Services)

Install D-Bus library:
```bash
npm install dbus-next
```

Example - Get battery info via D-Bus:

```javascript
const dbus = require('dbus-next');

async function getBatteryFromDBus() {
  const bus = dbus.systemBus();
  const obj = await bus.getProxyObject(
    'org.freedesktop.UPower',
    '/org/freedesktop/UPower/devices/battery_BAT0'
  );
  
  const properties = obj.getInterface('org.freedesktop.DBus.Properties');
  const percentage = await properties.Get('org.freedesktop.UPower.Device', 'Percentage');
  
  return percentage.value;
}
```

### Style Customization

Edit `src/renderer/styles.css`:

```css
:root {
  --primary-color: #3498db;      /* Change theme color */
  --background-dark: #2c3e50;    /* Panel background */
  --text-color: #ecf0f1;         /* Text color */
}
```

## Building and Packaging

### Build for Testing

```bash
npm run build
```

This creates a `.deb` package in `dist/`.

### Install Locally

```bash
sudo dpkg -i dist/custom-os-desktop_*.deb
```

### Build for Different Targets

Modify `package.json`:
```json
"scripts": {
  "build:deb": "electron-builder --linux deb",
  "build:rpm": "electron-builder --linux rpm",
  "build:appimage": "electron-builder --linux AppImage"
}
```

## Debugging

### Main Process Debugging

Add breakpoints or console logs in `src/main/*.js`:
```javascript
console.log('Main process:', data);
```

View in terminal where you ran `npm start`.

### Renderer Process Debugging

1. Open DevTools (enabled in dev mode)
2. Use Console tab for logs
3. Use Elements tab for HTML/CSS
4. Use Sources tab for breakpoints

### Common Issues

**Panel doesn't appear**:
- Check if window was created: `console.log('Panel created')`
- Check X11 window type: Should be `toolbar`
- Verify z-index/always-on-top settings

**IPC not working**:
- Check handler is registered: `ipcMain.handle('event-name', ...)`
- Verify preload exposes the function
- Check for typos in event names

**System info not updating**:
- Check interval is running
- Verify window still exists: `if (!window.isDestroyed())`
- Check for errors in systeminformation library

## Testing

### Manual Testing

```bash
# Start in dev mode
npm start

# Test panel:
# - Click menu button -> launcher should appear
# - Click power button -> power menu should appear
# - Check system indicators update

# Test launcher:
# - Search for apps
# - Click app to launch
# - Press ESC to close
```

### Automated Testing (Future)

Consider adding:
- **Spectron**: Electron app testing framework
- **Jest**: Unit tests for logic
- **Playwright**: E2E testing

## Performance Optimization

### Reduce Memory Usage

1. **Disable unused features**:
```javascript
webPreferences: {
  nodeIntegration: false,
  enableRemoteModule: false,  // Don't use remote module
}
```

2. **Lazy load windows**:
```javascript
// Create launcher only when needed, not at startup
```

3. **Optimize rendering**:
```css
/* Use CSS transforms (GPU accelerated) */
.app-item:hover {
  transform: translateY(-2px);  /* Instead of top: -2px */
}
```

### Reduce Startup Time

1. **Bundle resources**:
```bash
# Use asar to package resources
npm install -g asar
asar pack app app.asar
```

2. **Preload only essentials**
3. **Defer non-critical initialization**

## Security Best Practices

### ✅ Do's

- ✅ Keep `nodeIntegration: false`
- ✅ Keep `contextIsolation: true`
- ✅ Use `preload.js` for all API exposure
- ✅ Validate all input from renderer
- ✅ Use CSP (Content Security Policy)
- ✅ Keep Electron updated

### ❌ Don'ts

- ❌ Never enable `nodeIntegration` in renderer
- ❌ Don't pass user input directly to `exec`
- ❌ Don't load remote content without validation
- ❌ Don't expose entire Node.js API to renderer
- ❌ Don't disable web security in production

### Example - Secure Command Execution

```javascript
// ❌ INSECURE
ipcMain.handle('run-command', (event, cmd) => {
  exec(cmd);  // User can run ANY command!
});

// ✅ SECURE
const ALLOWED_APPS = {
  'firefox': '/usr/bin/firefox',
  'terminal': '/usr/bin/xterm'
};

ipcMain.handle('launch-app', (event, appName) => {
  const appPath = ALLOWED_APPS[appName];
  if (!appPath) {
    throw new Error('App not allowed');
  }
  exec(appPath);
});
```

## Contributing

### Code Style

- Use 2 spaces for indentation
- Use semicolons
- Use `const` and `let`, not `var`
- Use arrow functions when appropriate
- Add comments for complex logic

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-panel-widget

# Make changes
git add .
git commit -m "Add network indicator to panel"

# Push and create PR
git push origin feature/new-panel-widget
```

## Resources

- [Electron Documentation](https://www.electronjs.org/docs)
- [Electron Security](https://www.electronjs.org/docs/tutorial/security)
- [systeminformation docs](https://systeminformation.io/)
- [D-Bus Specification](https://dbus.freedesktop.org/doc/dbus-specification.html)

## Advanced Topics

### Using Native Modules

Some npm packages include native (C++) code:

```bash
# Rebuild for Electron's version
npm install --save-dev electron-rebuild
./node_modules/.bin/electron-rebuild
```

### Window Management Integration

To read other windows (for taskbar):

```javascript
const { exec } = require('child_process');

function getWindowList() {
  return new Promise((resolve) => {
    exec('wmctrl -l', (error, stdout) => {
      if (error) {
        resolve([]);
        return;
      }
      const windows = stdout.split('\n')
        .map(line => line.split(/\s+/).slice(3).join(' '))
        .filter(Boolean);
      resolve(windows);
    });
  });
}
```

### Custom Wayland Compositor (Advanced)

To replace OpenBox with Electron as full compositor:

1. Study `wlroots` library
2. Create Node.js bindings (N-API)
3. Implement Wayland protocols
4. Handle window management in Electron

This is **very complex** - start with X11/OpenBox approach first.

## Next Steps

1. **Explore the code**: Read through existing files
2. **Make small changes**: Modify colors, add icons
3. **Add features**: Implement new panels or widgets
4. **Share**: Contribute improvements back!

Happy hacking! 🚀
