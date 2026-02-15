const si = require('systeminformation');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class SystemInfo {
  constructor() {
    this.cachedInfo = {};
  }

  async getSystemInfo() {
    try {
      const [time, mem, cpu, battery] = await Promise.all([
        this.getCurrentTime(),
        si.mem(),
        si.currentLoad(),
        this.getBatteryInfo()
      ]);

      return {
        time: time,
        memory: {
          used: Math.round((mem.used / mem.total) * 100),
          total: this.formatBytes(mem.total),
          available: this.formatBytes(mem.available)
        },
        cpu: {
          load: Math.round(cpu.currentLoad)
        },
        battery: battery
      };
    } catch (error) {
      console.error('Error getting system info:', error);
      return this.getDefaultInfo();
    }
  }

  getCurrentTime() {
    const now = new Date();
    return {
      hours: now.getHours().toString().padStart(2, '0'),
      minutes: now.getMinutes().toString().padStart(2, '0'),
      date: now.toLocaleDateString('en-US', { 
        weekday: 'short', 
        month: 'short', 
        day: 'numeric' 
      })
    };
  }

  async getBatteryInfo() {
    try {
      const battery = await si.battery();
      return {
        hasBattery: battery.hasBattery,
        percent: battery.percent || 0,
        isCharging: battery.isCharging,
        acConnected: battery.acConnected
      };
    } catch (error) {
      return {
        hasBattery: false,
        percent: 0,
        isCharging: false,
        acConnected: true
      };
    }
  }

  formatBytes(bytes) {
    if (bytes === 0) return '0 GB';
    const gb = bytes / (1024 * 1024 * 1024);
    return `${gb.toFixed(1)} GB`;
  }

  getDefaultInfo() {
    return {
      time: { hours: '00', minutes: '00', date: 'Unknown' },
      memory: { used: 0, total: '0 GB', available: '0 GB' },
      cpu: { load: 0 },
      battery: { hasBattery: false, percent: 0, isCharging: false }
    };
  }
}

module.exports = new SystemInfo();
