#!/bin/bash

# Quick Setup Script for CustomOS Development

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CustomOS Development Setup          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo -e "${GREEN}✓ Node.js installed${NC}"
else
    echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${YELLOW}npm not found. Installing...${NC}"
    sudo apt-get install -y npm
    echo -e "${GREEN}✓ npm installed${NC}"
else
    echo -e "${GREEN}✓ npm found: $(npm --version)${NC}"
fi

# Install desktop dependencies
echo ""
echo -e "${BLUE}Installing Electron desktop dependencies...${NC}"
cd desktop
npm install
echo -e "${GREEN}✓ Desktop dependencies installed${NC}"

# Install build dependencies
echo ""
echo -e "${BLUE}Installing live-build dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools

echo -e "${GREEN}✓ Build dependencies installed${NC}"

# Optional: Install QEMU for testing
echo ""
read -p "Install QEMU for ISO testing? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt-get install -y qemu-system-x86 qemu-utils
    echo -e "${GREEN}✓ QEMU installed${NC}"
fi

# Create necessary directories
echo ""
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p config/packages.chroot
mkdir -p build
echo -e "${GREEN}✓ Directories created${NC}"

cd ..

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Setup Complete!                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Test the desktop in development mode:"
echo "   ${BLUE}cd desktop && npm start${NC}"
echo ""
echo "2. Build the ISO (requires sudo):"
echo "   ${BLUE}sudo ./build.sh${NC}"
echo ""
echo "3. Test ISO in QEMU:"
echo "   ${BLUE}./test-iso.sh${NC}"
echo ""
echo -e "${YELLOW}For more information, see README.md${NC}"
echo ""
