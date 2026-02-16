#!/bin/bash
# WSL2 Environment Setup Script
# Prepares WSL2 for building CustomOS

set -e

echo "======================================"
echo "  CustomOS WSL2 Setup"
echo "======================================"
echo ""

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    echo "Warning: This doesn't appear to be WSL"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Detect distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
    echo "Detected: Arch Linux"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
    echo "Detected: Debian/Ubuntu"
else
    echo "Warning: Unknown distribution"
    DISTRO="unknown"
fi

# Update system
echo ""
echo "Updating system packages..."
if [ "$DISTRO" == "arch" ]; then
    sudo pacman -Syu --noconfirm
elif [ "$DISTRO" == "debian" ]; then
    sudo apt update && sudo apt upgrade -y
fi

# Install required packages
echo ""
echo "Installing build dependencies..."

if [ "$DISTRO" == "arch" ]; then
    # Arch Linux packages
    sudo pacman -S --needed --noconfirm \
        base-devel \
        archiso \
        git \
        nodejs \
        npm \
        wine \
        winetricks \
        rsync
        
elif [ "$DISTRO" == "debian" ]; then
    # Debian/Ubuntu packages
    sudo apt install -y \
        build-essential \
        git \
        nodejs \
        npm \
        wine \
        winetricks \
        rsync \
        arch-install-scripts \
        squashfs-tools \
        libisoburn1 \
        dosfstools
    
    # For Ubuntu, archiso needs to be built from source or use debootstrap alternative
    echo ""
    echo "Note: archiso is not available on Debian/Ubuntu"
    echo "You may need to use debootstrap or install Arch Linux in WSL2"
fi

# Install Node.js dependencies for Electron
echo ""
echo "Installing Electron desktop dependencies..."
cd "$(dirname "$0")/../electron-de"
npm install

echo ""
echo "======================================"
echo "  Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Review the configuration in archiso/"
echo "  2. Build the ISO: sudo ./scripts/build-iso.sh"
echo "  3. Test in VirtualBox"
echo ""

if [ "$DISTRO" != "arch" ]; then
    echo "⚠️  Warning: You're not using Arch Linux"
    echo "   Building Arch-based ISOs from non-Arch systems is complex"
    echo "   Consider installing Arch Linux in WSL2:"
    echo "   - ArchWSL: https://github.com/yuk7/ArchWSL"
    echo ""
fi
