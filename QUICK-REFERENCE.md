# CustomOS Quick Reference

Quick commands and information for CustomOS development.

## Build Commands

```bash
# Full setup (first time)
./setup.sh

# Build Electron desktop only
cd desktop && npm run build

# Build ISO (takes 30-60 min)
sudo ./build.sh

# Test ISO in QEMU
./test-iso.sh

# Clean build directory
cd build && sudo lb clean --purge && cd ..
```

## Development Commands

```bash
# Run desktop in dev mode
cd desktop && npm start

# Install dependencies
cd desktop && npm install

# Lint/format code (if configured)
npm run lint
npm run format
```

## File Locations

### Key Configuration Files

| File | Purpose |
|------|---------|
| `config/package-lists/desktop.list.chroot` | Packages to install |
| `config/hooks/normal/*.hook.chroot` | Build-time customization |
| `config/includes.chroot/` | Files to include in ISO |
| `desktop/src/renderer/styles.css` | Desktop styling |
| `desktop/src/renderer/launcher.js` | Application list |

### Important Paths (in ISO)

| Path | Purpose |
|------|---------|
| `/usr/bin/custom-os-desktop` | Desktop session script |
| `/usr/share/xsessions/customos.desktop` | X session definition |
| `/etc/xdg/openbox/rc.xml` | Window manager config |
| `/opt/custom-os-desktop/` | Electron app location |

## Default Credentials

**Live System & Default User:**
- Username: `customos`
- Password: `customos`

**SSH:** Not enabled by default

## Customization Quick Guide

### Change Theme Colors

Edit `desktop/src/renderer/styles.css`:
```css
:root {
  --primary-color: #3498db;      /* Main accent color */
  --background-dark: #2c3e50;    /* Panel background */
  --text-color: #ecf0f1;         /* Text color */
}
```

### Add Application to Launcher

Edit `desktop/src/renderer/launcher.js`:
```javascript
{
  name: 'App Name',
  command: 'command-to-run',
  icon: '🚀',  // Emoji or SVG
  category: 'Category'
}
```

### Add System Package

Edit `config/package-lists/desktop.list.chroot`:
```
package-name
another-package
```

### Add Custom File to ISO

Place file in: `config/includes.chroot/path/to/file`

Example: `config/includes.chroot/etc/custom.conf` → `/etc/custom.conf` in ISO

## Troubleshooting Quick Fixes

### Build fails - Package not found
```bash
apt-cache search package-name
# Remove from config/package-lists/desktop.list.chroot if doesn't exist
```

### Desktop won't start
```bash
# Check X11 logs
cat /var/log/Xorg.0.log | grep EE

# Check desktop session
cat ~/.xsession-errors

# Try starting manually
/usr/bin/custom-os-desktop
```

### Black screen on boot
Add boot parameter at GRUB: `nomodeset`

### Out of disk space
```bash
# Clean build
cd build && sudo lb clean --purge && cd ..

# Check space
df -h
```

## Testing Commands

### QEMU with Options

```bash
# Basic test
qemu-system-x86_64 -cdrom custom-os.iso -m 2048 -enable-kvm

# With virtual disk
qemu-img create -f qcow2 test.qcow2 20G
qemu-system-x86_64 -cdrom custom-os.iso -hda test.qcow2 -m 2048 -enable-kvm

# More RAM
qemu-system-x86_64 -cdrom custom-os.iso -m 4096 -enable-kvm

# Multiple CPUs
qemu-system-x86_64 -cdrom custom-os.iso -m 2048 -smp 4 -enable-kvm
```

### Create Bootable USB

**Linux:**
```bash
# Find device
lsblk

# Write ISO (replace sdX!)
sudo dd if=custom-os.iso of=/dev/sdX bs=4M status=progress
sync
```

**Windows:** Use Rufus (DD mode)

**macOS:** Use balenaEtcher

## Useful Checks

```bash
# Check ISO integrity
sha256sum custom-os.iso

# List ISO contents
7z l custom-os.iso

# Mount ISO (Linux)
sudo mount -o loop custom-os.iso /mnt
ls /mnt
sudo umount /mnt

# Check package in ISO
sudo mount -o loop custom-os.iso /mnt
chroot /mnt
dpkg -l | grep package-name
exit
sudo umount /mnt
```

## Package Management (in running system)

```bash
# Update package lists
sudo apt-get update

# Upgrade packages
sudo apt-get upgrade

# Install package
sudo apt-get install package-name

# Remove package
sudo apt-get remove package-name

# Search for package
apt-cache search keyword

# Package information
apt-cache show package-name
```

## System Information

```bash
# OS version
lsb_release -a
cat /etc/os-release

# Kernel version
uname -r

# Hardware info
lscpu          # CPU
lsmem          # Memory
lsblk          # Block devices
lspci          # PCI devices
lsusb          # USB devices

# Running processes
ps aux
htop

# Disk usage
df -h
du -sh /path

# Network
ip addr
ip route
nmcli device
```

## Log Files

```bash
# System log
journalctl -xe
journalctl -f  # Follow

# X11 log
cat /var/log/Xorg.0.log

# Boot log
dmesg

# Application log
~/.xsession-errors

# Kernel messages
cat /var/log/kern.log
```

## Git Commands (for contributors)

```bash
# Clone
git clone <repo-url>

# Create branch
git checkout -b feature/my-feature

# Status
git status

# Stage changes
git add .

# Commit
git commit -m "Description"

# Push
git push origin feature/my-feature

# Update from main
git pull origin main

# Stash changes
git stash
git stash pop
```

## GitHub Actions

Workflow automatically runs on:
- Push to `main` or `develop`
- Pull requests
- Manual trigger

**Download built ISO:**
1. Go to Actions tab
2. Click on workflow run
3. Download artifact

## Performance Tuning

```bash
# Reduce ISO size
# Remove packages from config/package-lists/desktop.list.chroot
# Enable cleanup in config/hooks/normal/9999-cleanup.hook.chroot

# Optimize desktop performance
# Disable animations in styles.css
# Close unused apps
# Use lighter alternatives
```

## Resources

- **Main README:** `README.md`
- **Getting Started:** `GETTING-STARTED.md`
- **Development:** `docs/desktop-development.md`
- **Troubleshooting:** `docs/troubleshooting.md`
- **Contributing:** `CONTRIBUTING.md`

## Common Port Numbers

- **SSH:** 22
- **HTTP:** 80
- **HTTPS:** 443
- **VNC:** 5900
- **Electron DevTools:** Random port (shown in console)

## Keyboard Shortcuts (in CustomOS)

- **Alt+F4:** Close window
- **Alt+Tab:** Switch windows
- **Ctrl+Alt+F1-F6:** Virtual terminals
- **Ctrl+Alt+F7:** Back to X11
- **Ctrl+Alt+Backspace:** Restart X11 (if enabled)

## Boot Parameters (GRUB)

Add at GRUB menu (press `e` to edit):

- `nomodeset` - Basic graphics mode
- `acpi=off` - Disable ACPI
- `noapic` - Disable APIC
- `quiet` - Minimal boot messages
- `splash` - Show splash screen
- `debug` - Verbose output

## Environment Variables

```bash
# Display
export DISPLAY=:0

# Desktop session
export DESKTOP_SESSION=customos

# Node.js
export NODE_ENV=production  # or development
```

## Emergency Recovery

If system won't boot:

1. Boot from USB/ISO
2. Open terminal
3. Mount disk: `sudo mount /dev/sda1 /mnt`
4. Chroot: `sudo chroot /mnt`
5. Fix issues
6. Exit: `exit`
7. Unmount: `sudo umount /mnt`
8. Reboot

---

**Need more help?** Check full documentation in `docs/` directory.
