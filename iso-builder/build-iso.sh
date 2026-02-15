#!/bin/bash
# Custom OS ISO Builder
# Builds a bootable Arch Linux ISO with custom liquid glass desktop

set -e  # Exit on error

echo "================================================"
echo "   Custom OS - ISO Builder"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo ./build-iso.sh)"
    exit 1
fi

# Check if archiso is installed
if ! command -v mkarchiso &> /dev/null; then
    echo "❌ archiso not found. Installing..."
    pacman -Sy --noconfirm archiso
fi

echo "✓ archiso found"
echo ""

# Configuration
WORK_DIR="/tmp/custom-os-build"
OUTPUT_DIR="$HOME/custom-os-iso"
PROFILE_DIR="./custom-os-profile"
DESKTOP_SOURCE="../dist/linux-unpacked"

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf "$WORK_DIR" "$PROFILE_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy base Archiso profile
echo "📦 Creating build profile..."
cp -r /usr/share/archiso/configs/releng/ "$PROFILE_DIR"

# Customize packages
echo "📝 Adding packages..."
cat >> "$PROFILE_DIR/packages.x86_64" << 'EOF'

# Custom OS Desktop Requirements
electron
nodejs
npm
openbox
lightdm
lightdm-gtk-greeter
picom
wmctrl
xdotool
xorg-server
xorg-xinit
EOF

# Add custom desktop
echo "🖥️  Adding custom desktop..."
mkdir -p "$PROFILE_DIR/airootfs/opt/custom-os"
if [ -d "$DESKTOP_SOURCE" ]; then
    cp -r "$DESKTOP_SOURCE"/* "$PROFILE_DIR/airootfs/opt/custom-os/"
    echo "✓ Desktop files copied"
else
    echo "⚠️  Warning: Desktop build not found at $DESKTOP_SOURCE"
    echo "   Run 'npm run build' first!"
fi

# Configure auto-login
echo "🔐 Configuring auto-login..."
mkdir -p "$PROFILE_DIR/airootfs/etc/lightdm/lightdm.conf.d"
cat > "$PROFILE_DIR/airootfs/etc/lightdm/lightdm.conf.d/50-autologin.conf" << 'EOF'
[Seat:*]
autologin-user=liveuser
autologin-user-timeout=0
autologin-session=openbox
user-session=openbox
EOF

# Create openbox autostart
echo "⚙️  Configuring openbox autostart..."
mkdir -p "$PROFILE_DIR/airootfs/etc/skel/.config/openbox"
cat > "$PROFILE_DIR/airootfs/etc/skel/.config/openbox/autostart" << 'EOF'
#!/bin/bash
# Custom OS Autostart

# Start compositor for transparency and blur effects
picom -b &

# Wait a moment for picom to start
sleep 2

# Launch Custom OS Desktop
/opt/custom-os/custom-os-desktop &
EOF

chmod +x "$PROFILE_DIR/airootfs/etc/skel/.config/openbox/autostart"

# Customize ISO metadata
echo "📄 Customizing ISO metadata..."
cat > "$PROFILE_DIR/profiledef.sh" << 'EOF'
#!/usr/bin/env bash
iso_name="custom-os"
iso_label="CUSTOM_OS_$(date +%Y%m)"
iso_publisher="Custom OS Project <https://github.com/>"
iso_application="Custom OS Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=()
EOF

# Build the ISO
echo ""
echo "🏗️  Building ISO..."
echo "   This will take 20-40 minutes..."
echo ""

mkarchiso -v -w "$WORK_DIR" -o "$OUTPUT_DIR" "$PROFILE_DIR"

# Success!
echo ""
echo "================================================"
echo "   ✓ BUILD COMPLETE!"
echo "================================================"
echo ""
echo "ISO Location:"
ls -lh "$OUTPUT_DIR"/*.iso
echo ""
echo "Next steps:"
echo "  1. Test in QEMU:"
echo "     qemu-system-x86_64 -m 2048 -enable-kvm -cdrom $OUTPUT_DIR/*.iso"
echo ""
echo "  2. Write to USB:"
echo "     sudo dd if=$OUTPUT_DIR/*.iso of=/dev/sdX bs=4M status=progress"
echo ""
echo "  3. Boot from USB and enjoy your custom OS!"
echo ""
