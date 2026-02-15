// Panel UI Logic

let powerMenuOpen = false;

// Initialize panel
document.addEventListener('DOMContentLoaded', () => {
  initializeEventListeners();
  updateSystemInfo();
  startClockUpdate();
});

function initializeEventListeners() {
  // Menu button - toggle launcher
  document.getElementById('menuButton').addEventListener('click', () => {
    window.api.toggleLauncher();
  });

  // Power button - toggle power menu
  document.getElementById('powerButton').addEventListener('click', (e) => {
    e.stopPropagation();
    togglePowerMenu();
  });

  // Power menu actions
  document.getElementById('logoutBtn').addEventListener('click', () => {
    window.api.logout();
  });

  document.getElementById('rebootBtn').addEventListener('click', () => {
    if (confirm('Are you sure you want to restart?')) {
      window.api.reboot();
    }
  });

  document.getElementById('shutdownBtn').addEventListener('click', () => {
    if (confirm('Are you sure you want to shut down?')) {
      window.api.shutdown();
    }
  });

  // Close power menu when clicking outside
  document.addEventListener('click', (e) => {
    if (powerMenuOpen && !e.target.closest('.power-button')) {
      closePowerMenu();
    }
  });

  // Listen for system info updates
  window.api.onSystemInfoUpdate((info) => {
    updateSystemDisplay(info);
  });
}

function togglePowerMenu() {
  const menu = document.getElementById('powerMenu');
  powerMenuOpen = !powerMenuOpen;
  menu.style.display = powerMenuOpen ? 'block' : 'none';
}

function closePowerMenu() {
  const menu = document.getElementById('powerMenu');
  powerMenuOpen = false;
  menu.style.display = 'none';
}

async function updateSystemInfo() {
  try {
    const info = await window.api.getSystemInfo();
    updateSystemDisplay(info);
  } catch (error) {
    console.error('Failed to get system info:', error);
  }
  
  // Update every 2 seconds
  setTimeout(updateSystemInfo, 2000);
}

function updateSystemDisplay(info) {
  // Update CPU
  const cpuText = document.getElementById('cpuText');
  if (cpuText) {
    cpuText.textContent = `${info.cpu.load}%`;
  }

  // Update Memory
  const memText = document.getElementById('memText');
  if (memText) {
    memText.textContent = `${info.memory.used}%`;
  }

  // Update Battery (if available)
  const batteryIndicator = document.getElementById('batteryIndicator');
  const batteryText = document.getElementById('batteryText');
  const batteryLevel = document.getElementById('batteryLevel');
  
  if (info.battery.hasBattery) {
    batteryIndicator.style.display = 'flex';
    batteryText.textContent = `${info.battery.percent}%`;
    
    // Update battery level visual
    const width = (info.battery.percent / 100) * 8;
    batteryLevel.setAttribute('width', width);
    
    // Change color based on level
    if (info.battery.percent < 20) {
      batteryLevel.setAttribute('fill', '#e74c3c');
    } else if (info.battery.percent < 50) {
      batteryLevel.setAttribute('fill', '#f39c12');
    } else {
      batteryLevel.setAttribute('fill', 'currentColor');
    }
    
    // Show charging indicator
    if (info.battery.isCharging) {
      batteryIndicator.title = 'Battery: Charging';
    } else {
      batteryIndicator.title = `Battery: ${info.battery.percent}%`;
    }
  } else {
    batteryIndicator.style.display = 'none';
  }
}

function startClockUpdate() {
  updateClock();
  // Update every second
  setInterval(updateClock, 1000);
}

function updateClock() {
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  const minutes = now.getMinutes().toString().padStart(2, '0');
  const date = now.toLocaleDateString('en-US', { 
    weekday: 'short', 
    month: 'short', 
    day: 'numeric' 
  });

  const clockTime = document.querySelector('.clock-time');
  const clockDate = document.querySelector('.clock-date');

  if (clockTime) clockTime.textContent = `${hours}:${minutes}`;
  if (clockDate) clockDate.textContent = date;
}

// Handle errors
window.addEventListener('error', (e) => {
  console.error('Panel error:', e.error);
});
