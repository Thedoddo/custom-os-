# CustomOS - Seamless Windows Apps on Linux

A custom Linux distribution with an Electron-based desktop environment that seamlessly runs Windows applications via Wine/Proton with zero configuration.

## Vision

- **No Linux Complexity**: Users never see terminal, Wine prefixes, or Linux jargon
- **Universal App Support**: Windows .exe files and Linux apps launch from the same launcher
- **Custom UI**: Unique Electron-based desktop that doesn't look like traditional Linux DEs
- **Gaming Ready**: Built-in Proton support with automatic shader caching and optimization
- **Just Works**: Wine/Proton configured automatically, dependencies installed silently

## Architecture

### Base System
- **Distribution Base**: Ubuntu Server 22.04 (stable, well-supported)
- **Build Tool**: ISO remastering (extract → customize → repack)
- **Package Manager**: apt
- **Init System**: systemd

### Desktop Environment
- **Shell**: Custom Electron application (full-screen, frameless)
- **UI Framework**: React + modern web technologies
- **Window Manager**: X11 with minimal WM (Openbox) or custom Wayland compositor
- **System Integration**: Node.js + native modules for Linux system calls

### Windows Compatibility Layer
- **Wine**: For Windows applications
- **Proton**: For Windows games (Steam compatibility layer)
- **Auto-detection**: Kernel binfmt_misc for automatic .exe execution
- **Prefix Management**: Lutris backend (headless) for isolated environments
- **Dependencies**: winetricks, DXVK, VKD3D-Proton auto-installed

### Key Features
1. **Smart Launcher**: Detects and launches any app type (native Linux, Windows exe, AppImage, Flatpak)
2. **Unified File Manager**: No distinction between "Linux" and "Windows" file paths
3. **Invisible Wine**: Users never configure Wine - it just works
4. **Gaming Mode**: Optional compositor (gamescope) for optimized gaming
5. **App Store**: Curated Windows/Linux apps with one-click installation

## Project Structure

```
distro/
├── README.md                 # This file
├── docs/                     # Architecture and development docs
├── archiso/                  # Arch Linux ISO builder configuration
│   ├── packages.x86_64       # Packages to include in ISO
│   ├── profiledef.sh         # Build profile metadata
│   ├── airootfs/             # Root filesystem overlay
│   │   ├── etc/              # System configuration files
│   │   ├── usr/              # User binaries and services
│   │   └── root/             # Root user files
│   └── efiboot/              # EFI boot configuration
├── electron-de/              # Custom Electron Desktop Environment
│   ├── package.json          # Node.js dependencies
│   ├── main.js               # Electron main process (system integration)
│   ├── preload.js            # Secure bridge between main and renderer
│   ├── renderer/             # Frontend UI
│   │   ├── index.html        # Main UI entry point
│   │   ├── styles/           # CSS/styling
│   │   └── js/               # Frontend JavaScript/React
│   └── system/               # System integration modules
│       ├── launcher.js       # App detection and launching
│       ├── wine-manager.js   # Wine/Proton integration
│       └── desktop-parser.js # Parse .desktop files
├── wine-integration/         # Wine/Proton automation
│   ├── binfmt-setup.sh       # Auto .exe execution setup
│   ├── wine-setup.sh         # Initial Wine configuration
│   └── lutris-configs/       # Pre-configured Wine bottles
├── scripts/                  # Build and development scripts
│   ├── build-iso.sh          # Build bootable ISO
│   ├── setup-wsl.sh          # Setup WSL2 environment
│   └── test-vm.sh            # Helper for VirtualBox testing
└── assets/                   # Branding and media
    ├── logo.svg              # Distro logo
    ├── wallpapers/           # Default wallpapers
    └── icons/                # Custom icon theme
```

## Development Setup

### Prerequisites
- **Windows**: WSL2 installed and configured
- **WSL2**: Arch Linux distribution (or Ubuntu with arch-chroot)
- **VirtualBox**: For testing the built ISO
- **Node.js**: v18+ (for developing Electron UI on Windows)

### Initial Setup

1. **Install Arch Linux in WSL2** (if not already done):
   ```powershell
   # From PowerShell
   wsl --install -d Arch  # If using ArchWSL
   ```

2. **Setup build environment in WSL2**:
   ```bash
   # From WSL2 terminal
   cd /mnt/e/PROJECTS!/distro
   sudo pacman -S archiso base-devel git nodejs npm wine
   ```

3. **Install Electron dependencies**:
   ```bash
   cd electron-de
   npm install
   ```

4. **Build your first ISO**:
   ```bash
   cd /mnt/e/PROJECTS!/distro
   ./scripts/build-iso.sh
   ```

5. **Test in VirtualBox**:
   - Create new VM (Linux, Arch Linux, 4GB RAM, 20GB disk)
   - Attach `out/CustomOS.iso`
   - Boot and test

## Development Workflow

### Developing the Electron UI
- **On Windows**: Edit files in VS Code, run `npm start` in `electron-de/` folder
- **Testing**: Use Electron's dev tools, hot reload
- **Building**: Package as Arch package for inclusion in ISO

### Building the Distro
- **In WSL2**: Run `./scripts/build-iso.sh`
- **Output**: `out/CustomOS-YYYY.MM.DD-x86_64.iso`
- **Testing**: Boot in VirtualBox or write to USB with Rufus

### Iteration Cycle
1. Modify Electron UI or archiso configuration
2. Rebuild ISO (`./scripts/build-iso.sh`)
3. Boot in VirtualBox
4. Test changes
5. Repeat

## Roadmap

### Phase 1: Foundation (Current)
- [x] Project structure
- [ ] Basic Electron desktop boots
- [ ] Minimal ISO builds successfully
- [ ] Can launch Linux apps from Electron UI

### Phase 2: Wine Integration
- [ ] binfmt_misc auto .exe execution
- [ ] Lutris backend integration
- [ ] Windows apps launch automatically
- [ ] Icon extraction from .exe files

### Phase 3: Smart Launcher
- [ ] Parse all .desktop files
- [ ] Unified app grid UI
- [ ] Search and categories
- [ ] Recently used apps

### Phase 4: Polish
- [ ] Custom branding and themes
- [ ] Settings panel (power, display, network)
- [ ] File manager integration
- [ ] Installer for bare metal

### Phase 5: Gaming Focus
- [ ] Steam integration
- [ ] Proton-GE auto-updates
- [ ] Shader caching
- [ ] Performance overlays

## Technical Details

### How .exe Auto-execution Works
1. Kernel module `binfmt_misc` registers .exe with Wine
2. Configuration: `echo ':wine:M::MZ::/usr/bin/wine:' > /proc/sys/fs/binfmt_misc/register`
3. Result: `./application.exe` runs directly without `wine` prefix
4. systemd service ensures persistence across reboots

### Electron as Desktop Environment
1. X11 session file: `/usr/share/xsessions/electron-de.desktop`
2. Systemd user service: `electron-de.service`
3. Electron runs full-screen, frameless
4. Node.js main process handles system calls
5. React renderer provides UI

### Application Detection
```javascript
// Simplified flow
const appType = detectAppType(path);
if (appType === 'windows') {
  launchWithWine(path, config);
} else if (appType === 'desktop') {
  parseAndLaunch(path);
} else if (appType === 'native') {
  spawn(path);
}
```

## Contributing

This is a personal project, but ideas and contributions are welcome!

## License

MIT (to be decided - may change to GPL for distro components)

---

**Current Status**: 🚧 Early Development - Setting up foundation

Last Updated: February 15, 2026
