# Custom OS - Linux Distribution with Liquid Glass Desktop

A custom Linux distribution featuring a beautiful Electron-based desktop environment with liquid glass effects.

## 🎯 What is This?

**Two things in one:**
1. **Custom Desktop** - Liquid glass UI with blur effects (Electron + React)
2. **Linux Distro** - Bootable ISO with auto-login and custom desktop

## ✨ Features

### Desktop Environment
- 💎 **Liquid Glass Effects** - Blur, transparency, smooth animations
- 🎨 **4 Themes** - Purple, Ocean, Midnight, Sunset
- 🚀 **Launcher** - Quick app access
- ⚙️ **Settings** - Customize appearance
- 🪟 **Window Management** - Modern controls

## 🚀 Quick Start

### Run Desktop on Windows NOW

```powershell
cd dist\win-unpacked
.\CustomOS.exe
```

## 📦 Project Structure

```
distro/
├── src/               # Desktop source (React + Electron)
├── dist/              # Built executables
│   ├── win-unpacked/  # Windows build
│   └── linux-unpacked/  # Linux build
├── iso-builder/       # Linux distro builder
└── package.json       # Dependencies
```

## 🐧 Building a Linux Distro

### Three Approaches

#### 1️⃣  Archiso (RECOMMENDED)
**Arch Linux based, easiest, auto-login built-in**

✅ One command builds ISO  
✅ Auto-login support  
✅ Rolling release (latest packages)  
✅ Minimal  
⏱️ Build time: ~30 min  

**Setup:**
```bash
# On Arch Linux or WSL2 Arch
sudo pacman -S archiso
cp -r /usr/share/archiso/configs/releng/ my-os
# Edit packages, add desktop, build
sudo mkarchiso -v my-os/
```

#### 2️⃣ Debian Live-Build
**Ubuntu/Debian based, familiar**

✅ Stable  
✅ Huge package repo  
✅ Familiar apt  
⚠️ More complex  
⏱️ Build time: ~1 hour  

#### 3️⃣ Linux From Scratch
**Build everything from source**

✅ Maximum control  
❌ Takes weeks  
❌ Very complex  

### Why Archiso?

After researching, **Archiso is perfect** because:
- Auto-login already works (no hacking needed)
- Single command builds ISO
- Fast rebuilds for testing
- Minimalist philosophy matches our vision

## 📋 Current Status

- [x] Desktop UI complete
- [x] Liquid glass effects
- [x] 4 themes implemented
- [x] Windows build working
- [x] Linux build working
- [ ] ISO builder configured
- [ ] First bootable ISO
- [ ] USB installer

## 🛠️ Next Steps

1. Set up Archiso in WSL2
2. Create build profile
3. Add custom desktop
4. Configure auto-login
5. Build first ISO
6. Test in QEMU

## 💡 The Vision  

> "A middle ground that ascends both Windows and Linux"

- Beautiful liquid glass UI
- No login screens
- Fast boot
- Simple and natural

## 🔧 Tech Stack

- **Desktop**: Electron 28, React 18, TailwindCSS, Framer Motion
- **Base**: Arch Linux (via Archiso)
- **Display**: LightDM (auto-login)
- **WM**: Openbox
- **Compositor**: Picom

## 📚 Resources

- [Archiso Wiki](https://wiki.archlinux.org/title/Archiso)
- [Linux From Scratch](https://www.linuxfromscratch.org/)

## License

MIT
