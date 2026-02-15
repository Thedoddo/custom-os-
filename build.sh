#!/bin/bash

# CustomOS Build Script
# Builds a custom Ubuntu-based Linux distribution with Electron desktop

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="build"
CONFIG_DIR="config"
ISO_NAME="custom-os"
DESKTOP_DIR="desktop"

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check required tools
print_header "Checking Dependencies"

REQUIRED_TOOLS=(
    "lb"  # live-build
    "debootstrap"
    "xorriso"
    "mksquashfs"
)

MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        MISSING_TOOLS+=("$tool")
        print_error "$tool not found"
    else
        print_success "$tool found"
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    print_error "Missing required tools. Install them with:"
    echo "sudo apt-get install live-build debootstrap squashfs-tools xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin mtools"
    exit 1
fi

# Build Electron desktop application
print_header "Building Electron Desktop Application"

if [ -d "$DESKTOP_DIR" ]; then
    cd "$DESKTOP_DIR"
    
    if [ ! -d "node_modules" ]; then
        print_info "Installing Node.js dependencies..."
        npm install
    fi
    
    print_info "Building Electron application..."
    npm run build
    
    # Check if .deb was created
    if [ -f "dist/"*.deb ]; then
        print_success "Electron desktop package built successfully"
        cp dist/*.deb "../$CONFIG_DIR/packages.chroot/"
    else
        print_error "Failed to build Electron desktop package"
        exit 1
    fi
    
    cd ..
else
    print_error "Desktop directory not found!"
    exit 1
fi

# Setup live-build environment
print_header "Setting up Live-Build Environment"

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    print_info "Cleaning previous build..."
    cd "$BUILD_DIR"
    lb clean --purge
    cd ..
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

print_info "Initializing live-build configuration..."

# Initialize live-build
lb config \
    --binary-images iso-hybrid \
    --mode ubuntu \
    --architectures amd64 \
    --linux-flavours generic \
    --distribution jammy \
    --archive-areas "main restricted universe multiverse" \
    --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --mirror-chroot "http://archive.ubuntu.com/ubuntu/" \
    --mirror-binary "http://archive.ubuntu.com/ubuntu/" \
    --apt-secure false \
    --apt-recommends false \
    --apt-indices false \
    --bootappend-live "boot=live components quiet splash" \
    --bootloader grub-efi \
    --debian-installer false \
    --iso-application "$ISO_NAME" \
    --iso-volume "$ISO_NAME"

print_success "Live-build configuration created"

# Remove Debian security repo that gets added by default
print_info "Fixing security repository configuration..."
sed -i '/security.debian.org/d' "$BUILD_DIR/config/archives/*.list.chroot" 2>/dev/null || true
sed -i '/security.debian.org/d' "$BUILD_DIR/config/archives/*.list.binary" 2>/dev/null || true

# Copy custom configuration
print_info "Copying custom configuration..."
cp -r "../$CONFIG_DIR/"* config/ 2>/dev/null || true

# Build the ISO
print_header "Building ISO Image"

print_info "This may take 30-60 minutes depending on your internet connection..."
print_info "Building..."

lb build 2>&1 | tee build.log

# Check if ISO was created
if [ -f *.iso ]; then
    ISO_FILE=$(ls *.iso | head -n 1)
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    
    print_success "ISO created successfully!"
    print_info "File: $ISO_FILE"
    print_info "Size: $ISO_SIZE"
    
    # Move ISO to parent directory with consistent name
    mv "$ISO_FILE" "../${ISO_NAME}.iso"
    print_success "ISO moved to ../${ISO_NAME}.iso"
else
    print_error "ISO creation failed! Check build.log for details"
    exit 1
fi

cd ..

print_header "Build Complete!"
echo ""
print_success "Your custom OS ISO is ready: ${ISO_NAME}.iso"
echo ""
print_info "To test in QEMU:"
echo "  qemu-system-x86_64 -cdrom ${ISO_NAME}.iso -m 2048 -enable-kvm"
echo ""
print_info "To create a bootable USB (Linux):"
echo "  sudo dd if=${ISO_NAME}.iso of=/dev/sdX bs=4M status=progress"
echo "  (Replace /dev/sdX with your USB device)"
echo ""
