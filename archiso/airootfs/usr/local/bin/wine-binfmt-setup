#!/bin/bash
# Wine binfmt_misc Setup
# Allows direct execution of .exe files without 'wine' prefix

set -e

echo "Setting up Wine binfmt_misc for automatic .exe execution..."

# Check if binfmt_misc is mounted
if ! mount | grep -q binfmt_misc; then
    echo "Mounting binfmt_misc..."
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
fi

# Check if Wine is installed
if ! command -v wine &> /dev/null; then
    echo "Error: Wine is not installed"
    exit 1
fi

# Register .exe files with Wine
# Format: :name:type:offset:magic:mask:interpreter:flags
# MZ is the magic bytes for Windows PE executables

echo "Registering .exe files with Wine..."
echo ':wine:M::MZ::/usr/bin/wine:' > /proc/sys/fs/binfmt_misc/register 2>/dev/null || {
    echo "Note: Wine already registered or registration failed"
}

# Also register for .exe with different architecture hints
echo ':wine-fixed:M::MZ::/usr/bin/wine:F' > /proc/sys/fs/binfmt_misc/register 2>/dev/null || {
    echo "Note: wine-fixed already registered"
}

echo "Wine binfmt setup complete!"
echo "You can now execute .exe files directly: ./program.exe"
