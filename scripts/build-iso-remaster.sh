#!/bin/bash
# CustomOS ISO Builder - Remaster Approach
# Much simpler than archiso - just extracts, customizes, and repacks an ISO

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$PROJECT_ROOT/work"
ISO_EXTRACT="$WORK_DIR/iso-extract"
SQUASHFS_DIR="$WORK_DIR/squashfs"
OUT_DIR="$PROJECT_ROOT/out"

echo "======================================"
echo "  CustomOS ISO Builder (Remaster)"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    echo "Run with: sudo $0"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
apt-get update -qq
apt-get install -y -qq \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-utils \
    wget \
    rsync \
    curl

# Clean and create directories
echo "Setting up directories..."
rm -rf "$WORK_DIR" "$OUT_DIR"
mkdir -p "$ISO_EXTRACT" "$SQUASHFS_DIR" "$OUT_DIR"

# Download base Ubuntu minimal ISO if not present
BASE_ISO="$WORK_DIR/ubuntu-minimal.iso"
if [ ! -f "$BASE_ISO" ]; then
    echo "Downloading Ubuntu Minimal ISO..."
    wget -q --show-progress \
        "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso" \
        -O "$BASE_ISO"
fi

# Extract ISO
echo "Extracting base ISO..."
xorriso -osirrox on -indev "$BASE_ISO" -extract / "$ISO_EXTRACT" 2>/dev/null
chmod -R u+w "$ISO_EXTRACT"

# Extract squashfs (the actual filesystem)
echo "Extracting squashfs filesystem..."
SQUASHFS_FILE=$(find "$ISO_EXTRACT" -name "filesystem.squashfs" | head -n1)
if [ -z "$SQUASHFS_FILE" ]; then
    echo "Error: Could not find filesystem.squashfs"
    exit 1
fi

unsquashfs -f -d "$SQUASHFS_DIR" "$SQUASHFS_FILE"

echo ""
echo "======================================"
echo "  Customizing System"
echo "======================================"
echo ""

# Mount required filesystems for chroot
echo "Mounting filesystems for chroot..."
mount --bind /dev "$SQUASHFS_DIR/dev"
mount --bind /dev/pts "$SQUASHFS_DIR/dev/pts"
mount --bind /proc "$SQUASHFS_DIR/proc"
mount --bind /sys "$SQUASHFS_DIR/sys"
mount --bind /run "$SQUASHFS_DIR/run"

# Copy DNS for internet access in chroot
cp /etc/resolv.conf "$SQUASHFS_DIR/etc/resolv.conf"

# Function to run commands in chroot
chroot_run() {
    chroot "$SQUASHFS_DIR" /bin/bash -c "$1"
}

# Customize the system
echo "Installing packages..."
chroot_run "apt-get update"
chroot_run "DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wine64 wine32 \
    winetricks \
    nodejs npm \
    xorg openbox \
    x11-xserver-utils \
    xinit \
    pulseaudio \
    network-manager \
    firefox \
    git curl wget"

echo "Installing Electron..."
chroot_run "npm install -g electron@latest"

# Copy Electron desktop
echo "Installing CustomOS desktop..."
mkdir -p "$SQUASHFS_DIR/usr/share/customos-desktop"
rsync -a --exclude node_modules --exclude dist \
    "$PROJECT_ROOT/electron-de/" \
    "$SQUASHFS_DIR/usr/share/customos-desktop/"

# Copy Wine integration
echo "Installing Wine integration..."
mkdir -p "$SQUASHFS_DIR/usr/local/bin"
cp "$PROJECT_ROOT/wine-integration/wine-setup.sh" "$SQUASHFS_DIR/usr/local/bin/"
cp "$PROJECT_ROOT/wine-integration/binfmt-setup.sh" "$SQUASHFS_DIR/usr/local/bin/"
chmod +x "$SQUASHFS_DIR/usr/local/bin/wine-setup.sh"
chmod +x "$SQUASHFS_DIR/usr/local/bin/binfmt-setup.sh"

# Create systemd service for Electron desktop
cat > "$SQUASHFS_DIR/etc/systemd/system/customos-desktop.service" << 'EOF'
[Unit]
Description=CustomOS Electron Desktop
After=graphical.target

[Service]
Type=simple
User=customos
Environment=DISPLAY=:0
ExecStart=/usr/bin/electron /usr/share/customos-desktop/main.js
Restart=on-failure

[Install]
WantedBy=graphical.target
EOF

# Create user
echo "Creating customos user..."
chroot_run "useradd -m -s /bin/bash customos"
chroot_run "echo 'customos:customos' | chpasswd"
chroot_run "usermod -aG sudo customos"

# Enable services
echo "Enabling services..."
chroot_run "systemctl enable customos-desktop.service"
chroot_run "systemctl enable NetworkManager"

# Auto-login setup
mkdir -p "$SQUASHFS_DIR/etc/systemd/system/getty@tty1.service.d"
cat > "$SQUASHFS_DIR/etc/systemd/system/getty@tty1.service.d/autologin.conf" << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin customos --noclear %I $TERM
EOF

# Set default to graphical target
chroot_run "systemctl set-default graphical.target"

# Cleanup
echo "Cleaning up chroot..."
chroot_run "apt-get clean"
rm -f "$SQUASHFS_DIR/etc/resolv.conf"

# Unmount filesystems
echo "Unmounting filesystems..."
umount "$SQUASHFS_DIR/run" || true
umount "$SQUASHFS_DIR/sys" || true
umount "$SQUASHFS_DIR/proc" || true
umount "$SQUASHFS_DIR/dev/pts" || true
umount "$SQUASHFS_DIR/dev" || true

echo ""
echo "======================================"
echo "  Building ISO"
echo "======================================"
echo ""

# Rebuild squashfs
echo "Rebuilding squashfs..."
rm -f "$SQUASHFS_FILE"
mksquashfs "$SQUASHFS_DIR" "$SQUASHFS_FILE" -comp xz -b 1M

# Calculate new filesystem size
echo "Updating filesystem size..."
FILESYSTEM_SIZE=$(du -sx --block-size=1 "$SQUASHFS_DIR" | cut -f1)
echo "$FILESYSTEM_SIZE" > "$ISO_EXTRACT/casper/filesystem.size"

# Update MD5 sums
echo "Updating MD5 checksums..."
cd "$ISO_EXTRACT"
find . -type f -print0 | xargs -0 md5sum > md5sum.txt

# Create new ISO
echo "Creating bootable ISO..."
ISO_OUTPUT="$OUT_DIR/customos-$(date +%Y%m%d).iso"

xorriso -as mkisofs \
    -r -V "CustomOS" \
    -o "$ISO_OUTPUT" \
    -J -l \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    "$ISO_EXTRACT"

ISO_SIZE=$(du -h "$ISO_OUTPUT" | cut -f1)

echo ""
echo "======================================"
echo "  Build Complete!"
echo "======================================"
echo ""
echo "ISO: $ISO_OUTPUT"
echo "Size: $ISO_SIZE"
echo ""
echo "Test with: qemu-system-x86_64 -m 2048 -cdrom $ISO_OUTPUT"
echo ""
