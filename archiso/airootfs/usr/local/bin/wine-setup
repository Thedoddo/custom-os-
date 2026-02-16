#!/bin/bash
# Initial Wine Configuration
# Sets up Wine with sensible defaults for CustomOS

set -e

WINE_PREFIX="${WINEPREFIX:-$HOME/.wine}"

echo "Initializing Wine prefix at: $WINE_PREFIX"

# Check if Wine is installed
if ! command -v wine &> /dev/null; then
    echo "Error: Wine is not installed"
    exit 1
fi

# Create Wine prefix if it doesn't exist
if [ ! -d "$WINE_PREFIX" ]; then
    echo "Creating new Wine prefix..."
    WINEARCH=win64 wineboot -i
    
    # Wait for wineboot to complete
    while pgrep -x wineserver >/dev/null; do
        sleep 1
    done
    
    echo "Wine prefix created successfully"
else
    echo "Wine prefix already exists"
fi

# Configure Wine settings
echo "Configuring Wine settings..."

# Set Windows version (Windows 10 by default)
wine reg add 'HKEY_CURRENT_USER\Software\Wine' /v Version /t REG_SZ /d win10 /f

# Disable crash dialog
wine reg add 'HKEY_CURRENT_USER\Software\Wine\WineDbg' /v ShowCrashDialog /t REG_DWORD /d 0 /f

# Enable CSMT (Command Stream Multithreading) for better performance
wine reg add 'HKEY_CURRENT_USER\Software\Wine\Direct3D' /v csmt /t REG_DWORD /d 1 /f

# Install essential dependencies via winetricks (if available)
if command -v winetricks &> /dev/null; then
    echo "Installing common Windows dependencies..."
    
    # Install in silent mode
    winetricks -q corefonts
    winetricks -q vcrun2019
    winetricks -q dotnet48
    
    echo "Dependencies installed"
else
    echo "Warning: winetricks not found, skipping dependency installation"
fi

# Install DXVK for better gaming performance (if available)
if command -v setup_dxvk.sh &> /dev/null; then
    echo "Installing DXVK..."
    setup_dxvk.sh install
else
    echo "DXVK setup script not found, skipping"
fi

echo "Wine configuration complete!"
echo "Wine prefix: $WINE_PREFIX"
echo "Windows version: Windows 10"
