#!/bin/bash
# CustomOS ISO Build Script
# Builds a bootable ISO using archiso

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARCHISO_DIR="$PROJECT_ROOT/archiso"
OUT_DIR="$PROJECT_ROOT/out"
WORK_DIR="$PROJECT_ROOT/work"

echo "======================================"
echo "  CustomOS ISO Builder"
echo "======================================"
echo ""

# Check if running in WSL or native Linux
if grep -qi microsoft /proc/version; then
    echo "Detected WSL environment"
    WSL_MODE=true
else
    echo "Detected native Linux environment"
    WSL_MODE=false
fi

# Check if archiso is installed
if ! command -v mkarchiso &> /dev/null; then
    echo "Error: archiso is not installed"
    echo "Install it with: sudo pacman -S archiso"
    exit 1
fi

# Check if running as root (required for mkarchiso)
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    echo "Run with: sudo $0"
    exit 1
fi

echo "Build configuration:"
echo "  Project root: $PROJECT_ROOT"
echo "  Archiso dir:  $ARCHISO_DIR"
echo "  Output dir:   $OUT_DIR"
echo "  Work dir:     $WORK_DIR"
echo ""

# Create output directory
mkdir -p "$OUT_DIR"

# Clean previous build if requested
if [ "$1" == "clean" ]; then
    echo "Cleaning previous build..."
    rm -rf "$WORK_DIR"
    echo "Clean complete"
    echo ""
fi

# Package Electron desktop environment
echo "Packaging Electron desktop environment..."
ELECTRON_SRC="$PROJECT_ROOT/electron-de"
ELECTRON_DEST="$ARCHISO_DIR/airootfs/usr/share/customos-desktop"

mkdir -p "$ELECTRON_DEST"
rsync -av --exclude node_modules --exclude dist "$ELECTRON_SRC/" "$ELECTRON_DEST/"

# Install dependencies in the build (this happens during archiso build)
echo "Note: Node dependencies will be installed during first boot"

# Copy Wine integration scripts
echo "Copying Wine integration scripts..."
mkdir -p "$ARCHISO_DIR/airootfs/usr/local/bin"
cp "$PROJECT_ROOT/wine-integration/binfmt-setup.sh" "$ARCHISO_DIR/airootfs/usr/local/bin/wine-binfmt-setup"
cp "$PROJECT_ROOT/wine-integration/wine-setup.sh" "$ARCHISO_DIR/airootfs/usr/local/bin/wine-setup"
chmod +x "$ARCHISO_DIR/airootfs/usr/local/bin/wine-binfmt-setup"
chmod +x "$ARCHISO_DIR/airootfs/usr/local/bin/wine-setup"

# Copy systemd service for Wine binfmt
mkdir -p "$ARCHISO_DIR/airootfs/etc/systemd/system"
cp "$PROJECT_ROOT/wine-integration/wine-binfmt.service" "$ARCHISO_DIR/airootfs/etc/systemd/system/"

# Recreate symlinks that were removed for Git compatibility
echo "Recreating systemd symlinks..."
bash "$SCRIPT_DIR/recreate-symlinks.sh" "$ARCHISO_DIR/airootfs"

# Build the ISO
echo ""
echo "Building ISO with mkarchiso..."
echo "This may take 10-30 minutes depending on your system..."
echo ""

mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$ARCHISO_DIR"

# Find the generated ISO
ISO_FILE=$(find "$OUT_DIR" -name "*.iso" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)

if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo ""
    echo "======================================"
    echo "  Build Successful!"
    echo "======================================"
    echo ""
    echo "ISO file: $ISO_FILE"
    echo "Size: $ISO_SIZE"
    echo ""
    echo "Next steps:"
    echo "  1. Test in VirtualBox: Create VM and attach ISO"
    echo "  2. Write to USB: Use Rufus (Windows) or dd (Linux)"
    echo "  3. Boot and test the Electron desktop"
    echo ""
else
    echo ""
    echo "Error: ISO file not found after build"
    exit 1
fi
