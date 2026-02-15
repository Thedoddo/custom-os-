// Application Launcher Logic

// Default applications
const applications = [
  {
    name: 'Firefox',
    command: 'firefox',
    icon: '🌐',
    category: 'Internet'
  },
  {
    name: 'Files',
    command: 'pcmanfm',
    icon: '📁',
    category: 'System'
  },
  {
    name: 'Terminal',
    command: 'xterm',
    icon: '⚡',
    category: 'System'
  },
  {
    name: 'Text Editor',
    command: 'gedit',
    icon: '📝',
    category: 'Accessories'
  },
  {
    name: 'Calculator',
    command: 'gnome-calculator',
    icon: '🔢',
    category: 'Accessories'
  },
  {
    name: 'Settings',
    command: 'lxappearance',
    icon: '⚙️',
    category: 'System'
  },
  {
    name: 'Image Viewer',
    command: 'gpicview',
    icon: '🖼️',
    category: 'Graphics'
  },
  {
    name: 'Screenshot',
    command: 'gnome-screenshot -i',
    icon: '📷',
    category: 'Accessories'
  }
];

let filteredApps = [...applications];

// Initialize launcher
document.addEventListener('DOMContentLoaded', () => {
  initializeSearchInput();
  renderApplications();
  
  // Focus search input when launcher opens
  document.getElementById('searchInput').focus();
  
  // Handle escape key to close launcher
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      window.close();
    }
  });
});

function initializeSearchInput() {
  const searchInput = document.getElementById('searchInput');
  
  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    
    if (query === '') {
      filteredApps = [...applications];
    } else {
      filteredApps = applications.filter(app => 
        app.name.toLowerCase().includes(query) ||
        app.category.toLowerCase().includes(query)
      );
    }
    
    renderApplications();
  });

  // Handle enter key to launch first result
  searchInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && filteredApps.length > 0) {
      launchApplication(filteredApps[0]);
    }
  });
}

function renderApplications() {
  const appsGrid = document.getElementById('appsGrid');
  
  if (filteredApps.length === 0) {
    appsGrid.innerHTML = '<div class="no-results">No applications found</div>';
    return;
  }

  // Group by category
  const categories = {};
  filteredApps.forEach(app => {
    if (!categories[app.category]) {
      categories[app.category] = [];
    }
    categories[app.category].push(app);
  });

  let html = '';
  
  Object.keys(categories).sort().forEach(category => {
    html += `<div class="category-header">${category}</div>`;
    html += '<div class="apps-grid">';
    
    categories[category].forEach(app => {
      html += createAppElement(app);
    });
    
    html += '</div>';
  });

  appsGrid.innerHTML = html;

  // Add click handlers
  document.querySelectorAll('.app-item').forEach(item => {
    item.addEventListener('click', () => {
      const appName = item.dataset.app;
      const app = applications.find(a => a.name === appName);
      if (app) {
        launchApplication(app);
      }
    });
  });
}

function createAppElement(app) {
  return `
    <div class="app-item" data-app="${app.name}">
      <div class="app-icon">${app.icon}</div>
      <div class="app-name">${app.name}</div>
    </div>
  `;
}

function launchApplication(app) {
  console.log(`Launching: ${app.name} (${app.command})`);
  window.api.launchApp(app.command);
  
  // Clear search and reset
  document.getElementById('searchInput').value = '';
  filteredApps = [...applications];
}

// Load system applications from .desktop files (future enhancement)
async function loadSystemApplications() {
  // This would read from /usr/share/applications/*.desktop
  // and parse the desktop entry files
  // For now, we use the hardcoded list above
  console.log('Using default application list');
}

// Handle errors
window.addEventListener('error', (e) => {
  console.error('Launcher error:', e.error);
});
