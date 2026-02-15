# ISO Builder - Custom Linux Distribution

This directory will contain the Archiso profile for building your custom Linux distro.

## Overview

We'll use **Archiso** to create a bootable Linux ISO with:
- Auto-login (no password prompt)
- Custom liquid glass desktop pre-installed
- Minimal base system
- Fast boot time

## Setup Instructions

### Option 1: WSL2 with Arch Linux (Windows)

```powershell
# Install Arch Linux in WSL2
wsl --install -d Arch

# Enter Arch
wsl -d Arch

# Inside Arch, set up archiso
sudo pacman -Syu
sudo pacman -S archiso base-devel
```

### Option 2: Native Arch Linux

```bash
sudo pacman -S archiso
```

## Build Process

1. **Copy base profile**
   ```bash
   cp -r /usr/share/archiso/configs/releng/ ./custom-os-profile
   ```

2. **Edit packages** (`custom-os-profile/packages.x86_64`)
   ```
   # Add these packages
   electron
   openbox
   lightdm
   picom
   nitrogen
   ```

3. **Add custom desktop**
   ```bash
   mkdir -p custom-os-profile/airootfs/opt/custom-os
   cp -r ../dist/linux-unpacked/* custom-os-profile/airootfs/opt/custom-os/
   ```

4. **Configure auto-login**
   ```bash
   mkdir -p custom-os-profile/airootfs/etc/lightdm/lightdm.conf.d
   cat > custom-os-profile/airootfs/etc/lightdm/lightdm.conf.d/autologin.conf << 'EOF'
   [Seat:*]
   autologin-user=liveuser
   autologin-user-timeout=0
   autologin-session=openbox
   EOF
   ```

5. **Add autostart script**
   ```bash
   mkdir -p custom-os-profile/airootfs/etc/skel/.config/openbox
   cat > custom-os-profile/airootfs/etc/skel/.config/openbox/autostart << 'EOF'
   # Start compositor for transparency
   picom -b &
   
   # Launch custom desktop
   /opt/custom-os/custom-os-desktop &
   EOF
   chmod +x custom-os-profile/airootfs/etc/skel/.config/openbox/autostart
   ```

6. **Build ISO**
   ```bash
   sudo mkarchiso -v -w /tmp/archiso-tmp -o ~/iso-output custom-os-profile/
   ```

7. **Test ISO**
   ```bash
   # Install QEMU
   sudo pacman -S qemu-desktop
   
   # Run ISO
   qemu-system-x86_64 -m 2048 -enable-kvm -cdrom ~/iso-output/custom-os-*.iso
   ```

## Expected Output

After building, you'll have:
- `custom-os-YYYY.MM.DD-x86_64.iso` - Bootable ISO (~800MB)
- Can be written to USB with `dd` or Rufus
- Boots to your liquid glass desktop automatically
- No login required

## Customization

### Change Boot Splash
Edit `custom-os-profile/syslinux/splash.png`

### Modify Default User
Edit `custom-os-profile/profiledef.sh`:
```bash
iso_label="CUSTOM_OS"
iso_publisher="Your Name"
iso_application="Custom OS ${iso_version}"
```

### Add More Packages
Edit `custom-os-profile/packages.x86_64` and add package names (one per line)

## Troubleshooting

### "mkarchiso not found"
```bash
sudo pacman -S archiso
```

### "Permission denied"
Run with `sudo`:
```bash
sudo mkarchiso ...
```

### Build fails
Check `/tmp/archiso-tmp/` for logs

## Next Steps

1. Set up WSL2 Arch Linux
2. Create build automation script
3. Test ISO in QEMU
4. Write to USB and test on real hardware
5. Create installer (optional)

## Resources

- [Archiso Documentation](https://wiki.archlinux.org/title/Archiso)
- [Archiso GitLab](https://gitlab.archlinux.org/archlinux/archiso)
