# CustomOS Development Quick Start

## Prerequisites Checklist

- [ ] WSL2 installed on Windows
- [ ] Arch Linux in WSL2 (recommended: ArchWSL)
- [ ] VirtualBox installed on Windows (for testing)
- [ ] At least 20GB free disk space

## Quick Start Guide

### 1. Setup WSL2 Environment

From WSL2 terminal:

```bash
cd /mnt/e/PROJECTS!/distro
chmod +x scripts/*.sh
./scripts/setup-wsl.sh
```

This will install all necessary dependencies.

### 2. Develop Electron UI (Optional - Windows)

You can develop/test the Electron desktop on Windows:

```bash
cd electron-de
npm install
npm start
```

This opens the Electron app so you can work on the UI without building the full ISO.

### 3. Build the ISO

From WSL2 (must be Arch Linux):

```bash
cd /mnt/e/PROJECTS!/distro
sudo ./scripts/build-iso.sh
```

Build time: 10-30 minutes depending on your system.

Output: `out/customos-YYYY.MM.DD-x86_64.iso`

### 4. Test the ISO

#### Option A: QEMU (Faster, Command-line)

**From WSL2:**
```bash
./scripts/test-qemu.sh
```

**From Windows PowerShell:**
```powershell
.\scripts\test-qemu.ps1
```

Install QEMU if needed:
- **Windows**: Download from https://qemu.weilnetz.de/w64/
- **WSL2**: `sudo pacman -S qemu` (Arch) or `sudo apt install qemu-system-x86` (Ubuntu)

#### Option B: VirtualBox (GUI, Easier)

1. Open VirtualBox on Windows
2. Create new VM:
   - Name: CustomOS Test
   - Type: Linux
   - Version: Arch Linux (64-bit)
   - RAM: 4096 MB (4GB)
   - Disk: 20GB VDI
3. Settings → Storage → Add optical drive → Select the ISO
4. Settings → Display → Video Memory: 128MB
5. Start the VM

### 5. What to Expect

When booting the ISO:

1. GRUB boot menu appears
2. Linux kernel loads
3. System boots to X11
4. Electron desktop starts automatically
5. You see the CustomOS welcome screen

### 6. Testing Checklist

- [ ] System boots without errors
- [ ] Electron desktop appears
- [ ] Can open application launcher
- [ ] Can search for apps
- [ ] Clock updates every minute
- [ ] Power menu works
- [ ] Can open file manager (if installed)

## Development Workflow

### Iterative Development

1. **Make changes** to Electron UI or archiso config
2. **Rebuild ISO**: `sudo ./scripts/build-iso.sh clean`
3. **Test in VirtualBox**: Restart VM with new ISO
4. **Repeat**

### Testing Wine Integration

Once booted:

1. Open terminal (if available) or add terminal to launcher
2. Test Wine: `wine --version`
3. Test binfmt: Create a simple Windows .exe and try running it
4. Check if .exe files run directly

### Quick Rebuild (Electron only)

If you only changed Electron files:

```bash
# Copy updated files to ISO build
rsync -av electron-de/ archiso/airootfs/usr/share/customos-desktop/

# Rebuild (faster since packages are cached)
sudo ./scripts/build-iso.sh
```

## Troubleshooting

### "archiso not found"

You need Arch Linux in WSL2. Ubuntu/Debian can't easily build Arch ISOs.

Install ArchWSL: https://github.com/yuk7/ArchWSL

### "Permission denied" when building

Run with sudo: `sudo ./scripts/build-iso.sh`

### Electron app doesn't start

Check logs in the ISO:
- Boot with `systemd.log_level=debug`
- Check journalctl output

### Running out of space

Clean old builds:

```bash
sudo rm -rf work/
rm out/*.iso
```

## Advanced: Testing X .exe Detection

To test Windows app detection before full Wine integration:

1. Boot ISO in VirtualBox
2. Mount a Windows partition or USB with .exe files
3. Try to execute: `./program.exe`
4. Should launch via Wine automatically (if binfmt is working)

## Next Development Steps

1. ✅ Basic Electron desktop
2. 🔄 App launcher with .desktop file parsing
3. ⏳ Wine integration and .exe detection
4. ⏳ Icon extraction from .exe files
5. ⏳ Settings panel
6. ⏳ File manager
7. ⏳ Proton/Steam integration
8. ⏳ Installer for bare metal

---

Happy building! 🚀
