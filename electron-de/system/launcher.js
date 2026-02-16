const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');
const ini = require('ini');

/**
 * Application Launcher Module
 * Detects, parses, and launches applications (Linux native, Windows via Wine, AppImages, etc.)
 */

class Launcher {
  constructor() {
    this.applications = [];
    this.desktopDirs = [
      '/usr/share/applications',
      '/usr/local/share/applications',
      path.join(process.env.HOME || '/root', '.local/share/applications')
    ];
    this.recentApps = [];
  }

  async init() {
    console.log('Initializing application launcher...');
    await this.scanApplications();
  }

  async scanApplications() {
    this.applications = [];
    
    // Scan .desktop files
    for (const dir of this.desktopDirs) {
      try {
        await this.scanDesktopDir(dir);
      } catch (error) {
        console.warn(`Could not scan ${dir}:`, error.message);
      }
    }
    
    // TODO: Scan for Wine applications
    // TODO: Scan for AppImages
    
    console.log(`Found ${this.applications.length} applications`);
    return this.applications;
  }

  async scanDesktopDir(dir) {
    try {
      const entries = await fs.readdir(dir);
      
      for (const entry of entries) {
        if (entry.endsWith('.desktop')) {
          const filePath = path.join(dir, entry);
          try {
            const app = await this.parseDesktopFile(filePath);
            if (app && !app.noDisplay) {
              this.applications.push(app);
            }
          } catch (error) {
            console.warn(`Failed to parse ${filePath}:`, error.message);
          }
        }
      }
    } catch (error) {
      // Directory doesn't exist or can't be read
      throw error;
    }
  }

  async parseDesktopFile(filePath) {
    const content = await fs.readFile(filePath, 'utf-8');
    const config = ini.parse(content);
    
    const entry = config['Desktop Entry'];
    if (!entry) return null;
    
    return {
      name: entry.Name || path.basename(filePath, '.desktop'),
      exec: entry.Exec,
      icon: entry.Icon || '📦',
      terminal: entry.Terminal === 'true',
      noDisplay: entry.NoDisplay === 'true',
      type: 'desktop',
      path: filePath,
      categories: entry.Categories ? entry.Categories.split(';').filter(Boolean) : [],
      comment: entry.Comment || ''
    };
  }

  async getAllApplications() {
    if (this.applications.length === 0) {
      await this.scanApplications();
    }
    return this.applications;
  }

  async searchApplications(query) {
    const apps = await this.getAllApplications();
    const lowerQuery = query.toLowerCase();
    
    return apps.filter(app => 
      app.name.toLowerCase().includes(lowerQuery) ||
      (app.comment && app.comment.toLowerCase().includes(lowerQuery)) ||
      (app.categories && app.categories.some(cat => cat.toLowerCase().includes(lowerQuery)))
    );
  }

  async launchApplication(appPath, appType) {
    console.log(`Launching ${appType} application: ${appPath}`);
    
    switch (appType) {
      case 'desktop':
        return await this.launchDesktopApp(appPath);
      case 'windows':
        return await this.launchWindowsApp(appPath);
      case 'native':
        return await this.launchNativeApp(appPath);
      case 'appimage':
        return await this.launchAppImage(appPath);
      default:
        throw new Error(`Unknown app type: ${appType}`);
    }
  }

  async launchDesktopApp(desktopFile) {
    const app = this.applications.find(a => a.path === desktopFile);
    if (!app || !app.exec) {
      throw new Error('Invalid desktop file or missing Exec');
    }
    
    // Parse Exec field (remove field codes like %U, %F, etc.)
    let command = app.exec
      .replace(/%[fFuUdDnNickvm]/g, '')
      .trim();
    
    // Split command and args
    const parts = command.split(' ');
    const executable = parts[0];
    const args = parts.slice(1);
    
    return this.spawnDetached(executable, args, {
      detached: true,
      stdio: 'ignore'
    });
  }

  async launchWindowsApp(exePath) {
    // Use wine-manager for Windows apps
    const wineManager = require('./wine-manager');
    return await wineManager.launchWindowsApp(exePath);
  }

  async launchNativeApp(executable) {
    return this.spawnDetached(executable, [], {
      detached: true,
      stdio: 'ignore'
    });
  }

  async launchAppImage(appImagePath) {
    // Make executable if not already
    try {
      await fs.chmod(appImagePath, 0o755);
    } catch (error) {
      console.warn('Could not chmod AppImage:', error.message);
    }
    
    return this.spawnDetached(appImagePath, [], {
      detached: true,
      stdio: 'ignore'
    });
  }

  spawnDetached(command, args, options) {
    return new Promise((resolve, reject) => {
      const child = spawn(command, args, options);
      
      child.on('error', (error) => {
        reject(error);
      });
      
      // Detach and let it run independently
      child.unref();
      
      // Consider it launched successfully after a short delay
      setTimeout(() => {
        resolve({ pid: child.pid });
      }, 100);
    });
  }

  async getRecentApplications(limit = 10) {
    // TODO: Implement recent apps tracking with SQLite
    return this.recentApps.slice(0, limit);
  }

  trackRecentApp(app) {
    // Remove if already in list
    this.recentApps = this.recentApps.filter(a => a.path !== app.path);
    // Add to front
    this.recentApps.unshift(app);
    // Keep only last 50
    this.recentApps = this.recentApps.slice(0, 50);
    
    // TODO: Persist to disk/database
  }
}

// Singleton instance
const launcher = new Launcher();

module.exports = launcher;
