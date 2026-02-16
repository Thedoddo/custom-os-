// Main renderer process JavaScript

// UI Elements
const appMenuBtn = document.getElementById('appMenuBtn');
const launcher = document.getElementById('launcher');
const closeLauncherBtn = document.getElementById('closeLauncherBtn');
const welcomeScreen = document.getElementById('welcomeScreen');
const appGrid = document.getElementById('appGrid');
const searchInput = document.getElementById('searchInput');
const clock = document.getElementById('clock');
const powerBtn = document.getElementById('powerBtn');
const powerModal = document.getElementById('powerModal');
const cancelPowerBtn = document.getElementById('cancelPowerBtn');
const logoutBtn = document.getElementById('logoutBtn');
const rebootBtn = document.getElementById('rebootBtn');
const shutdownBtn = document.getElementById('shutdownBtn');
const settingsBtn = document.getElementById('settingsBtn');
const openAppsBtn = document.getElementById('openAppsBtn');
const openFilesBtn = document.getElementById('openFilesBtn');

let allApps = [];

// Initialize
async function init() {
  console.log('CustomOS Desktop UI initialized');
  updateClock();
  setInterval(updateClock, 1000);
  
  // Load applications
  await loadApplications();
  
  // Setup event listeners
  setupEventListeners();
}

function updateClock() {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  clock.textContent = `${hours}:${minutes}`;
}

async function loadApplications() {
  try {
    console.log('Loading applications...');
    allApps = await window.electronAPI.getApplications();
    console.log(`Loaded ${allApps.length} applications`);
    renderApplications(allApps);
  } catch (error) {
    console.error('Failed to load applications:', error);
    // Show mock apps for development
    showMockApps();
  }
}

function renderApplications(apps) {
  if (apps.length === 0) {
    appGrid.innerHTML = `
      <div class="app-item" style="grid-column: 1/-1; text-align: center;">
        <p>No applications found</p>
        <p style="font-size: 0.8rem; opacity: 0.7;">Install apps or check your configuration</p>
      </div>
    `;
    return;
  }

  appGrid.innerHTML = apps.map(app => `
    <div class="app-item" data-app-path="${app.path}" data-app-type="${app.type}">
      <div class="app-icon">${app.icon || '📦'}</div>
      <div class="app-name">${app.name}</div>
    </div>
  `).join('');

  // Add click handlers to app items
  document.querySelectorAll('.app-item').forEach(item => {
    item.addEventListener('click', () => {
      const appPath = item.dataset.appPath;
      const appType = item.dataset.appType;
      launchApp(appPath, appType);
    });
  });
}

function showMockApps() {
  // Mock apps for development/testing
  const mockApps = [
    { name: 'Firefox', icon: '🦊', path: '/usr/bin/firefox', type: 'native' },
    { name: 'Files', icon: '📁', path: '/usr/bin/nautilus', type: 'native' },
    { name: 'Terminal', icon: '💻', path: '/usr/bin/xterm', type: 'native' },
    { name: 'Settings', icon: '⚙️', path: '/usr/bin/gnome-control-center', type: 'native' },
    { name: 'Notepad++', icon: '📝', path: 'C:\\Program Files\\Notepad++\\notepad++.exe', type: 'windows' },
    { name: 'Paint.NET', icon: '🎨', path: 'C:\\Program Files\\paint.net\\PaintDotNet.exe', type: 'windows' },
  ];
  
  allApps = mockApps;
  renderApplications(mockApps);
}

async function launchApp(appPath, appType) {
  console.log(`Launching: ${appPath} (${appType})`);
  
  try {
    const result = await window.electronAPI.launchApp(appPath, appType);
    if (result.success) {
      console.log('App launched successfully');
      closeLauncher();
      // Show notification
      await window.electronAPI.showNotification('App Launched', `${appPath} is starting...`);
    } else {
      console.error('Failed to launch app:', result.error);
      alert(`Failed to launch app: ${result.error}`);
    }
  } catch (error) {
    console.error('Error launching app:', error);
    alert(`Error: ${error.message}`);
  }
}

function setupEventListeners() {
  // App menu / launcher
  appMenuBtn.addEventListener('click', openLauncher);
  openAppsBtn.addEventListener('click', openLauncher);
  closeLauncherBtn.addEventListener('click', closeLauncher);
  
  // Close launcher when clicking outside
  launcher.addEventListener('click', (e) => {
    if (e.target === launcher) {
      closeLauncher();
    }
  });
  
  // Search
  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    if (query) {
      const filtered = allApps.filter(app => 
        app.name.toLowerCase().includes(query)
      );
      renderApplications(filtered);
    } else {
      renderApplications(allApps);
    }
  });
  
  // Focus search when launcher opens
  appMenuBtn.addEventListener('click', () => {
    setTimeout(() => searchInput.focus(), 100);
  });
  
  // Power menu
  powerBtn.addEventListener('click', () => {
    powerModal.classList.remove('hidden');
  });
  
  cancelPowerBtn.addEventListener('click', () => {
    powerModal.classList.add('hidden');
  });
  
  powerModal.addEventListener('click', (e) => {
    if (e.target === powerModal) {
      powerModal.classList.add('hidden');
    }
  });
  
  // Power actions
  logoutBtn.addEventListener('click', async () => {
    if (confirm('Are you sure you want to log out?')) {
      await window.electronAPI.logout();
    }
  });
  
  rebootBtn.addEventListener('click', async () => {
    if (confirm('Are you sure you want to restart?')) {
      await window.electronAPI.reboot();
    }
  });
  
  shutdownBtn.addEventListener('click', async () => {
    if (confirm('Are you sure you want to shut down?')) {
      await window.electronAPI.shutdown();
    }
  });
  
  // File manager
  openFilesBtn.addEventListener('click', async () => {
    await window.electronAPI.openFileManager();
  });
  
  // Settings (placeholder)
  settingsBtn.addEventListener('click', () => {
    alert('Settings panel coming soon!');
  });
  
  // Keyboard shortcuts
  document.addEventListener('keydown', (e) => {
    // Escape to close launcher/modals
    if (e.key === 'Escape') {
      if (!launcher.classList.contains('hidden')) {
        closeLauncher();
      }
      if (!powerModal.classList.contains('hidden')) {
        powerModal.classList.add('hidden');
      }
    }
    
    // Ctrl+Space or Super to open launcher
    if ((e.ctrlKey && e.code === 'Space') || e.key === 'Meta') {
      e.preventDefault();
      if (launcher.classList.contains('hidden')) {
        openLauncher();
      } else {
        closeLauncher();
      }
    }
  });
}

function openLauncher() {
  launcher.classList.remove('hidden');
  welcomeScreen.style.display = 'none';
  searchInput.focus();
}

function closeLauncher() {
  launcher.classList.add('hidden');
  welcomeScreen.style.display = 'flex';
  searchInput.value = '';
  renderApplications(allApps); // Reset filter
}

// Start the app
init();
