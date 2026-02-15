#!/bin/bash

# Test ISO in QEMU Virtual Machine

ISO_FILE="custom-os.iso"
MEMORY="2048"  # 2GB RAM
DISK_SIZE="20G"
VM_NAME="customos-test"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}CustomOS ISO Test Script${NC}"
echo ""

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo -e "${RED}✗ QEMU not found!${NC}"
    echo "Install with: sudo apt-get install qemu-system-x86"
    exit 1
fi

# Check if ISO exists
if [ ! -f "$ISO_FILE" ]; then
    echo -e "${RED}✗ ISO file not found: $ISO_FILE${NC}"
    echo "Build it first with: sudo ./build.sh"
    exit 1
fi

echo -e "${GREEN}✓ Found ISO: $ISO_FILE${NC}"
echo -e "${GREEN}✓ ISO Size: $(du -h $ISO_FILE | cut -f1)${NC}"
echo ""

# Check for KVM support
KVM_OPTS=""
if [ -e /dev/kvm ]; then
    echo -e "${GREEN}✓ KVM acceleration available${NC}"
    KVM_OPTS="-enable-kvm"
else
    echo -e "${YELLOW}⚠ KVM not available (will be slower)${NC}"
fi

echo ""
echo -e "${BLUE}Starting QEMU...${NC}"
echo ""
echo "Boot options:"
echo "  1) Live mode - Boot from ISO (no installation)"
echo "  2) With virtual disk - Create persistent disk"
echo ""
read -p "Choice (1 or 2): " choice

case $choice in
    1)
        echo -e "${YELLOW}Booting in live mode...${NC}"
        qemu-system-x86_64 \
            -cdrom "$ISO_FILE" \
            -m "$MEMORY" \
            -smp 2 \
            $KVM_OPTS \
            -vga virtio \
            -display sdl \
            -boot d
        ;;
    2)
        DISK_FILE="${VM_NAME}.qcow2"
        
        # Create disk if it doesn't exist
        if [ ! -f "$DISK_FILE" ]; then
            echo -e "${YELLOW}Creating virtual disk ($DISK_SIZE)...${NC}"
            qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"
        else
            echo -e "${GREEN}✓ Using existing disk: $DISK_FILE${NC}"
        fi
        
        echo -e "${YELLOW}Booting with virtual disk...${NC}"
        qemu-system-x86_64 \
            -cdrom "$ISO_FILE" \
            -hda "$DISK_FILE" \
            -m "$MEMORY" \
            -smp 2 \
            $KVM_OPTS \
            -vga virtio \
            -display sdl \
            -boot menu=on
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}QEMU session ended${NC}"
echo ""
echo -e "${YELLOW}Tips:${NC}"
echo "  - Ctrl+Alt+G: Release mouse from VM"
echo "  - Ctrl+Alt+F: Toggle fullscreen"
echo "  - View in menu -> select 'Quit' to exit"
echo ""
