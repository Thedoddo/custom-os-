# Custom OS ISO Builder - Quick Reference

## Prerequisites

### On Windows (WSL2)
```powershell
# Install Arch Linux in WSL2
wsl --install -d Arch
```

### Inside WSL2 Arch
```bash
# Initialize pacman
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu

# Install archiso
sudo pacman -S archiso base-devel
```

## Build ISO

```bash
cd iso-builder
sudo ./build-iso.sh
```

The script will:
1. ✅ Check for archiso
2. ✅ Create build profile
3. ✅ Add required packages
4. ✅ Copy your custom desktop
5. ✅ Configure auto-login
6. ✅ Set up openbox autostart
7. ✅ Build bootable ISO (~30 min)

## Output

ISO will be in: `~/custom-os-iso/custom-os-YYYY.MM.DD-x86_64.iso`

Size: ~800MB-1GB

## Test ISO

### In QEMU (Quick Test)
```bash
sudo pacman -S qemu-desktop
qemu-system-x86_64 -m 2048 -enable-kvm -cdrom ~/custom-os-iso/*.iso
```

### On Real Hardware
1. Write to USB:
   ```bash
   sudo dd if=~/custom-os-iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
2. Boot from USB
3. Should auto-login and show your liquid glass desktop!

## Customization

### Add More Packages
Edit `build-iso.sh` and add to the package list:
```bash
cat >> "$PROFILE_DIR/packages.x86_64" << 'EOF'
firefox
vim
htop
EOF
```

### Change Wallpaper
Place image in `custom-os-profile/airootfs/etc/skel/wallpaper.jpg`

### Modify Splash Screen
Edit `custom-os-profile/syslinux/splash.png`

## Troubleshooting

### Build fails: "mkarchiso: command not found"
```bash
sudo pacman -S archiso
```

### Build fails: Permission denied
Run with sudo:
```bash
sudo ./build-iso.sh
```

### Desktop doesn't start
Check that desktop build exists:
```bash
ls -la ../dist/linux-unpacked/
```

Rebuild if needed:
```bash
cd ..
npm run build
```

### Auto-login doesn't work
Check `/var/log/lightdm/` in the live system

## What Gets Built

```
ISO Contents:
├── vmlinuz-linux          # Linux kernel
├── initramfs              # Initial RAM filesystem
└── airootfs.sfs           # Root filesystem (squashfs)
    ├── /usr/bin/          # System binaries
    ├── /opt/custom-os/    # Your desktop! ✨
    ├── /etc/lightdm/      # Auto-login config
    └── ~/.config/openbox/ # Desktop autostart
```

## Performance

- **Build Time**: 20-40 minutes (first build)
- **ISO Size**: 800MB-1.2GB
- **Boot Time**: ~15 seconds to desktop
- **RAM Usage**: 500MB base + desktop

## Next Steps After First ISO

1. ✅ Test in QEMU
2. ✅ Test on real hardware
3. Add more themes/customization
4. Create installer (optional)
5. Add update mechanism
6. Create website/documentation

## Useful Commands

```bash
# Rebuild faster (reuse work dir)
sudo mkarchiso -v custom-os-profile/

# Clean build completely
sudo rm -rf /tmp/custom-os-build

# Check ISO contents
7z l ~/custom-os-iso/*.iso

# Check ISO bootability
file ~/custom-os-iso/*.iso
```

## Resources

- [Archiso Docs](https://wiki.archlinux.org/title/Archiso)
- [Electron Docs](https://www.electronjs.org/docs)
- [Openbox Config](http://openbox.org/wiki/Help:Contents)
