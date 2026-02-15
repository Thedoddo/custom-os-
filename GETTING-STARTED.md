# Getting Started with CustomOS

This guide will walk you through building your first custom Linux distribution with an Electron-based desktop environment.

## Prerequisites

### System Requirements

**For Building:**
- Linux system (Ubuntu 20.04+ or Debian 11+ recommended)
- 20GB+ free disk space
- 4GB+ RAM (8GB recommended)
- Stable internet connection
- Sudo/root access

**For Running (the built OS):**
- 2GB+ RAM (4GB recommended)
- 10GB+ disk space (for installation)
- x86_64 processor
- Graphics card with X11 support

### Software Requirements

- Git
- Node.js 18+
- npm
- live-build
- QEMU (optional, for testing)

## Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd distro
```

## Step 2: Run Setup Script

The setup script will install all necessary dependencies:

```bash
chmod +x setup.sh
./setup.sh
```

This installs:
- Node.js and npm (if not present)
- Electron desktop dependencies
- live-build tools
- QEMU (optional)

## Step 3: Test the Desktop (Optional)

Before building the full ISO, you can test the Electron desktop:

```bash
cd desktop
npm start
```

You should see:
- A top panel with menu button, system indicators, and clock
- Click the menu button to see the application launcher
- Click the power button to see shutdown options

**Note**: Some features (like launching apps) won't fully work outside the actual distro environment.

Press `Ctrl+C` in terminal to stop.

## Step 4: Customize (Optional)

Before building, you can customize:

### Change Desktop Appearance

Edit `desktop/src/renderer/styles.css`:

```css
:root {
  --primary-color: #e74c3c;  /* Change to red theme */
  --background-dark: #1a1a1a;  /* Darker background */
}
```

### Add More Applications

Edit `config/package-lists/desktop.list.chroot`:

```
# Add your favorite apps
vlc
gimp
libreoffice
```

### Change Wallpaper

Add your wallpaper to `config/includes.chroot/usr/share/backgrounds/customos.jpg`

## Step 5: Build the ISO

Now build the complete ISO:

```bash
sudo ./build.sh
```

**This will take 30-60 minutes** depending on:
- Internet speed (downloading packages)
- CPU speed (compression)
- Disk I/O speed

You'll see output like:
```
========================================
Checking Dependencies
========================================
✓ lb found
✓ debootstrap found
...
========================================
Building ISO Image
========================================
...
```

When complete:
```
========================================
Build Complete!
========================================
✓ Your custom OS ISO is ready: custom-os.iso
```

## Step 6: Test the ISO

### Option A: Test in QEMU (Recommended)

```bash
chmod +x test-iso.sh
./test-iso.sh
```

Choose option 1 (Live mode) for quick testing.

### Option B: Test in VirtualBox

1. Open VirtualBox
2. Click "New"
3. Name: CustomOS, Type: Linux, Version: Ubuntu (64-bit)
4. Memory: 2048 MB
5. Create virtual hard disk (20GB)
6. Settings → Storage → Add optical drive → Select `custom-os.iso`
7. Start the VM

### Option C: Test in VMware

1. Create New Virtual Machine
2. Select "Installer disc image file" → Browse to `custom-os.iso`
3. Guest OS: Linux, Version: Ubuntu 64-bit
4. Allocate 2GB RAM, 20GB disk
5. Power on

## Step 7: Boot and Explore

When the ISO boots:

1. **GRUB Menu**: Select "CustomOS (live)"
2. **Boot Process**: You'll see boot messages
3. **Login Screen**: 
   - Username: `customos`
   - Password: `customos`
4. **Desktop**: You should see your Electron-based desktop!

### Exploring the Desktop

**Top Panel:**
- **Grid Icon (left)**: Opens application launcher
- **System Indicators**: CPU, Memory, Battery (if laptop)
- **Clock**: Current time and date
- **Power Icon (right)**: Logout, Restart, Shutdown

**Application Launcher:**
- Click the grid icon or press the menu button
- Search for applications by typing
- Click an app to launch it
- Press `ESC` to close

**Trying Applications:**
- Firefox: Web browsing
- Files (PCManFM): File manager
- Terminal (xterm): Command line
- Text Editor: Simple text editing

## Step 8: Create Bootable USB

To install on real hardware:

### On Linux:

```bash
# Find your USB device
lsblk

# Create bootable USB (replace sdX with your device!)
sudo dd if=custom-os.iso of=/dev/sdX bs=4M status=progress
sync
```

**⚠️ WARNING**: This will erase all data on the USB drive!

### On Windows:

1. Download [Rufus](https://rufus.ie/)
2. Select your USB drive
3. Select the `custom-os.iso` file
4. Click "Start"
5. If asked, choose "DD mode"

### On macOS:

1. Download [balenaEtcher](https://www.balena.io/etcher/)
2. Select the ISO file
3. Select your USB drive
4. Click "Flash!"

## Step 9: Boot from USB

1. Insert USB drive
2. Restart computer
3. Enter BIOS/UEFI (usually F2, F12, Delete, or ESC during boot)
4. Disable Secure Boot (if enabled)
5. Set USB as first boot device
6. Save and exit
7. Computer should boot CustomOS

## Troubleshooting

### Build fails with "E: Unable to locate package"

**Solution**: Check package names in `config/package-lists/desktop.list.chroot`

```bash
# Test if package exists
apt-cache search package-name
```

### Black screen after boot

**Solution**: Try adding boot parameter `nomodeset`

1. At GRUB menu, press `e`
2. Find line starting with `linux`
3. Add `nomodeset` at the end
4. Press `Ctrl+X` to boot

### Desktop doesn't start

**Solution**: Check logs

```bash
# Press Ctrl+Alt+F2 to get terminal
# Login as: customos / customos
cat /var/log/Xorg.0.log
journalctl -xe
```

### Out of disk space during build

**Solution**: Clean up space

```bash
# Clean previous build
cd build && sudo lb clean --purge && cd ..

# Remove Docker images (if you use Docker)
docker system prune -a

# Check disk space
df -h
```

For more issues, see [docs/troubleshooting.md](docs/troubleshooting.md)

## Next Steps

### Customize Your Distro

1. **Modify the Desktop**: See [docs/desktop-development.md](docs/desktop-development.md)
2. **Add Packages**: Edit `config/package-lists/desktop.list.chroot`
3. **Change Theme**: Edit `desktop/src/renderer/styles.css`
4. **Add Wallpaper**: Place in `config/includes.chroot/usr/share/backgrounds/`

### Advanced Topics

1. **Custom Kernel**: Add specific kernel version
2. **Root Filesystem**: Modify `config/hooks/` for system changes
3. **Installer**: Add Calamares or Ubiquity installer
4. **Repository**: Host packages on GitHub Releases

### Share Your Creation

1. Push code to GitHub
2. GitHub Actions will automatically build the ISO
3. Download from Actions → Artifacts
4. Share with others!

## Learning Resources

### Linux Distribution Creation
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Ubuntu ISO Customization](https://help.ubuntu.com/community/LiveCDCustomization)
- [Linux From Scratch](http://www.linuxfromscratch.org/)

### Electron Development
- [Electron Documentation](https://www.electronjs.org/docs)
- [Electron Security](https://www.electronjs.org/docs/tutorial/security)
- [Awesome Electron](https://github.com/sindresorhus/awesome-electron)

### Desktop Environments
- [X11 Protocol](https://www.x.org/wiki/)
- [Wayland](https://wayland.freedesktop.org/)
- [D-Bus Tutorial](https://dbus.freedesktop.org/doc/dbus-tutorial.html)

## FAQ

**Q: Can I use this for production?**
A: This is a learning/hobby project. For production, consider established distros or work with an experienced team.

**Q: How large is the ISO?**
A: Typically 1-2GB depending on packages. Can be reduced by removing applications.

**Q: Can I install this permanently?**
A: Currently it's a live system. You can add an installer (Calamares, Ubiquity) for permanent installation.

**Q: Why Electron? Isn't it bloated?**
A: Yes, Electron uses more resources than native DEs. This project is about learning and modern UI development. You can replace with native tools later.

**Q: Can I use a different base (Arch, Fedora)?**
A: Yes! You'll need to adapt the build scripts. Arch uses `archiso`, Fedora uses `livecd-tools`.

**Q: How do I update the OS once installed?**
A: Use standard package managers (`apt-get update && apt-get upgrade`). The desktop can be updated separately.

**Q: Can I contribute?**
A: Absolutely! Fork, make changes, and submit PRs.

## Getting Help

- **Documentation**: Check `docs/` directory
- **Issues**: Search existing issues or create new one
- **Logs**: Always include logs when asking for help
- **Community**: Join discussions on GitHub

## Congratulations! 🎉

You've built your own Linux distribution with a custom desktop environment!

Next: Explore the code, make modifications, and create something unique!

---

**Happy Hacking!** 🚀
