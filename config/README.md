# CustomOS Desktop - Build Configuration

## Overview

This directory contains the live-build configuration for creating the CustomOS ISO image.

## Directory Structure

```
config/
├── hooks/                          # Build-time hooks
│   └── normal/
│       ├── 9999-customos-config.hook.chroot    # System configuration
│       └── 9999-cleanup.hook.chroot            # Cleanup to reduce size
├── includes.chroot/               # Files to include in the root filesystem
│   ├── etc/
│   │   ├── default/
│   │   │   └── grub              # GRUB configuration
│   │   ├── issue                  # Login banner
│   │   └── xdg/
│   │       └── openbox/
│   │           └── rc.xml         # OpenBox WM configuration
│   └── usr/
│       ├── bin/
│       │   └── custom-os-desktop  # Desktop session starter script
│       └── share/
│           └── xsessions/
│               └── customos.desktop  # X session file
├── package-lists/                 # Package selections
│   └── desktop.list.chroot       # Desktop packages to install
└── packages.chroot/              # Local .deb packages (created during build)
```

## Build Process

### 1. Configuration Phase

The `lb config` command in `build.sh` sets up:
- Base distribution: Ubuntu 22.04 (Jammy)
- Architecture: amd64
- Boot loader: GRUB EFI
- ISO format: Hybrid (USB/DVD compatible)

### 2. Bootstrap Phase

Downloads and installs the minimal Ubuntu base system.

### 3. Chroot Phase

- Installs packages from package lists
- Runs hooks to customize the system
- Installs local .deb packages (Electron desktop)
- Configures services and users

### 4. Binary Phase

Creates the bootable ISO image with:
- Bootloader (GRUB)
- SquashFS compressed filesystem
- ISO 9660 filesystem

## Customization

### Adding Packages

Edit `config/package-lists/desktop.list.chroot` to add more packages:

```
# Add your packages here
vlc
gimp
blender
```

### Custom Configuration Files

Add files to `config/includes.chroot/` maintaining the directory structure:

```
config/includes.chroot/etc/custom/config.conf
  ↓ will be installed to ↓
/etc/custom/config.conf (in the ISO)
```

### Build Hooks

Hooks are shell scripts that run during the build:

- **Normal hooks** (`hooks/normal/*.hook.chroot`): Run in chroot environment
- **Live hooks** (`hooks/live/*.hook.chroot`): Run in live system
- **Binary hooks** (`hooks/binary/*.hook.binary`): Run during ISO creation

Hook naming format: `NNNN-name.hook.chroot`
- NNNN: Order (0000-9999)
- Lower numbers run first

### Default User Configuration

The default user is created in the post-installation hook:
- Username: `customos`
- Password: `customos`
- Groups: sudo, audio, video, plugdev, netdev

**Security Note**: Change the default password in production!

## Testing the Configuration

### Local Build

```bash
sudo ./build.sh
```

### GitHub Actions Build

Push to GitHub - the workflow will automatically build the ISO.

## Troubleshooting

### Build Fails

Check `build/build.log` for errors.

Common issues:
- Out of disk space (need 20GB+)
- Missing packages in Ubuntu repos
- Network connection problems
- Invalid hook syntax

### ISO Won't Boot

- Check GRUB configuration
- Verify ISO is hybrid-capable
- Test in QEMU first before burning to USB

### Desktop Won't Start

- Check `/var/log/Xorg.0.log` for X11 errors
- Verify session file exists: `/usr/share/xsessions/customos.desktop`
- Check if Electron app is installed: `/opt/custom-os-desktop/`

## Advanced Configuration

### Changing Base Distribution

In `build.sh`, modify the `--distribution` parameter:
- `focal` - Ubuntu 20.04 LTS
- `jammy` - Ubuntu 22.04 LTS
- `lunar` - Ubuntu 23.04
- `bookworm` - Debian 12

### Custom Kernel

Install a specific kernel by adding to package list:
```
linux-image-5.15.0-generic
linux-headers-5.15.0-generic
```

### Adding Desktop Themes

Add theme packages to `desktop.list.chroot`:
```
arc-theme
papirus-icon-theme
numix-icon-theme
```

Configure in hooks:
```bash
# Set GTK theme
cat > /etc/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
EOF
```

## Size Optimization

To reduce ISO size:

1. Remove unnecessary packages
2. Enable documentation removal in cleanup hook
3. Don't install recommended packages (already disabled)
4. Use lighter applications (e.g., `mousepad` instead of `gedit`)

## Resources

- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Ubuntu Wiki: LiveCDCustomization](https://help.ubuntu.com/community/LiveCDCustomization)
- [live-build man page](https://manpages.debian.org/testing/live-build/lb.1.en.html)
