#!/bin/bash
# QEMU Test Script for CustomOS
# Boots the ISO in QEMU for testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUT_DIR="$PROJECT_ROOT/out"

# Find the most recent ISO
ISO_FILE=$(find "$OUT_DIR" -name "*.iso" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$ISO_FILE" ] || [ ! -f "$ISO_FILE" ]; then
    echo "Error: No ISO file found in $OUT_DIR"
    echo "Build an ISO first: sudo ./scripts/build-iso.sh"
    exit 1
fi

echo "======================================"
echo "  CustomOS QEMU Test"
echo "======================================"
echo ""
echo "ISO: $ISO_FILE"
echo ""

# QEMU settings
MEMORY="4G"
CPUS="4"
DISK_SIZE="20G"

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: QEMU is not installed"
    echo ""
    echo "Install QEMU:"
    echo "  Arch:   sudo pacman -S qemu"
    echo "  Ubuntu: sudo apt install qemu-system-x86"
    echo "  Windows: Download from https://qemu.weilnetz.de/"
    exit 1
fi

# Create a virtual disk if it doesn't exist (for testing installation)
DISK_IMG="$PROJECT_ROOT/test-disk.qcow2"
if [ ! -f "$DISK_IMG" ]; then
    echo "Creating virtual disk ($DISK_SIZE)..."
    qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
    echo "Virtual disk created: $DISK_IMG"
    echo ""
fi

# Check for KVM acceleration (Linux only)
KVM_OPTS=""
if [ -e /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "KVM acceleration: ENABLED"
    KVM_OPTS="-enable-kvm"
else
    echo "KVM acceleration: DISABLED (slower)"
    if [ "$(uname)" == "Linux" ]; then
        echo "  Enable KVM: sudo modprobe kvm-intel  # or kvm-amd"
        echo "  Add user to kvm group: sudo usermod -a -G kvm $USER"
    fi
fi

echo ""
echo "Starting QEMU..."
echo "Press Ctrl+Alt+G to release mouse/keyboard"
echo ""

# Run QEMU
qemu-system-x86_64 \
    $KVM_OPTS \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -cdrom "$ISO_FILE" \
    -hda "$DISK_IMG" \
    -boot d \
    -vga virtio \
    -display gtk \
    -net nic,model=virtio \
    -net user \
    -audiodev pa,id=snd0 \
    -device ich9-intel-hda \
    -device hda-output,audiodev=snd0 \
    "$@"

echo ""
echo "QEMU exited"
