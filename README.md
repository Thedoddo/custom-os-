# CustomOS - Linux Distribution with Electron Desktop

A custom Linux distribution featuring a modern desktop environment built with Electron.

## 🎯 Project Overview

CustomOS is a Ubuntu-based Linux distribution with a custom desktop environment powered by Electron. It combines the stability of Ubuntu with a sleek, modern interface built using web technologies.

### Features

- **Custom Electron Desktop**: Modern UI built with HTML/CSS/JavaScript
- **Lightweight**: Based on Ubuntu minimal with only essential packages
- **Fast Boot**: Optimized for quick startup times
- **Modern Design**: Clean, intuitive interface
- **Full Desktop Experience**: Top panel, application launcher, system tray, settings

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│   Electron Desktop Shell (UI)      │
│   - Top Panel                       │
│   - App Launcher                    │
│   - System Tray                     │
│   - Settings                        │
├─────────────────────────────────────┤
│   Window Manager (Openbox)         │
├─────────────────────────────────────┤
│   Display Server (X11)             │
├─────────────────────────────────────┤
│   Ubuntu Base System               │
└─────────────────────────────────────┘
```

## 📦 Components

- **Base**: Ubuntu 24.04 LTS (minimal)
- **Display Server**: X.org
- **Window Manager**: Openbox (lightweight, configurable)
- **Login Manager**: LightDM
- **Desktop Shell**: Custom Electron application
- **File Manager**: PCManFM
- **Terminal**: xterm / Electron-based custom terminal

## 🚀 Quick Start

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- `live-build` package installed
- 20GB+ free disk space
- Sudo privileges

### Building the ISO

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install live-build debootstrap squashfs-tools xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin mtools

# Build the ISO
sudo ./build.sh
```

The ISO will be created in `build/` directory.

### Using GitHub Actions

This project includes CI/CD configuration. Push to GitHub to automatically build the ISO:

```bash
git add .
git commit -m "Build custom OS"
git push
```

Download the artifact from the Actions tab.

## 🛠️ Development

### Desktop Application

The Electron desktop is located in `desktop/` directory.

```bash
cd desktop
npm install
npm start  # Run in development mode
```

### Customization

- **UI Styling**: Edit `desktop/src/renderer/styles.css`
- **Panel Layout**: Modify `desktop/src/renderer/panel.html`
- **Launcher**: Customize `desktop/src/renderer/launcher.html`
- **System Integration**: Edit `desktop/src/main/system.js`

### Building Desktop Package

```bash
cd desktop
npm run build
```

This creates a `.deb` package in `desktop/dist/`.

## 📁 Project Structure

```
distro/
├── desktop/                 # Electron desktop application
│   ├── src/
│   │   ├── main/           # Main process (Node.js)
│   │   └── renderer/       # Renderer process (UI)
│   ├── package.json
│   └── electron-builder.yml
├── config/                  # Live-build configuration
│   ├── hooks/              # Build hooks
│   ├── includes/           # Files to include in ISO
│   └── package-lists/      # Package selections
├── build.sh                # Main build script
├── .github/workflows/      # CI/CD configuration
└── README.md
```

## 🎨 Customization Guide

### Changing the Theme

Edit `desktop/src/renderer/styles.css`:

```css
:root {
  --primary-color: #3498db;
  --background-color: #2c3e50;
  --text-color: #ecf0f1;
}
```

### Adding Applications

Add to package list in `config/package-lists/desktop.list.chroot`:

```
firefox
gimp
vlc
```

### Boot Configuration

Edit GRUB settings in `config/includes.chroot/etc/default/grub`.

## 🧪 Testing

### Virtual Machine

Test the ISO using QEMU:

```bash
qemu-system-x86_64 -cdrom build/custom-os.iso -m 2048 -enable-kvm
```

Or use VirtualBox/VMware:
- Create new VM
- Attach ISO as CD-ROM
- Boot and test

### Live USB

Create bootable USB (Linux):

```bash
sudo dd if=build/custom-os.iso of=/dev/sdX bs=4M status=progress
sync
```

**Warning**: Replace `/dev/sdX` with your actual USB device. This will erase the USB!

## 📚 Documentation

- [Building Guide](docs/building.md)
- [Desktop Development](docs/desktop.md)
- [Customization](docs/customization.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

This is a hobby project for learning. Feel free to fork and experiment!

## 📝 License

MIT License - See LICENSE file

## 🔗 Resources

- [Electron Documentation](https://www.electronjs.org/docs)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)
- [Ubuntu ISO Customization](https://help.ubuntu.com/community/LiveCDCustomization)

## 🎯 Roadmap

- [x] Basic Electron desktop shell
- [x] ISO build system
- [x] GitHub Actions CI/CD
- [ ] Custom application launcher
- [ ] Settings panel
- [ ] Network manager GUI
- [ ] Power management
- [ ] Custom greeter theme
- [ ] Notification system
- [ ] Multi-monitor support

---

**Made with ❤️ for learning Linux internals and Electron**
