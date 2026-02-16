# Reinstall Arch Linux WSL - Step by Step Guide

## Current Status
Your Arch Linux WSL has been unregistered (or is being removed).

## Step-by-Step Installation

### Step 1: Restart Your Computer
**Important:** WSL service may be stuck. Restart Windows to clean everything up.

```powershell
# After restart, verify WSL is working:
wsl --list --verbose
```

You should only see Ubuntu (if you have it) or nothing.

---

### Step 2: Download Fresh Arch Linux WSL

**Option A: ArchWSL (Recommended)**

1. Go to: https://github.com/yuk7/ArchWSL/releases/latest
2. Download **`Arch.zip`** (about 200MB)
3. Extract to `C:\ArchWSL\` (create this folder)

**Option B: Alternative Arch WSL**

1. Go to: https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/
2. Follow their installation guide

---

### Step 3: Install Arch WSL

**From PowerShell:**

```powershell
# Navigate to the extracted folder
cd C:\ArchWSL

# Run the installer
.\Arch.exe

# Wait for it to extract and initialize
```

This will:
- Register Arch Linux with WSL
- Extract the rootfs
- Set up the basic system

---

### Step 4: Initialize Arch Linux

**Enter Arch WSL:**

```powershell
wsl -d Arch
```

**Inside Arch, run these commands:**

```bash
# Initialize pacman keyring
pacman-key --init
pacman-key --populate archlinux

# Update mirrorlist (optional but recommended)
# This gets faster mirrors
reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Update the system
pacman -Syu

# Install base-devel (needed for building)
pacman -S base-devel

# Exit back to Windows
exit
```

---

### Step 5: Create a User (Optional but Recommended)

**Don't run as root. Create a normal user:**

```bash
wsl -d Arch

# Inside Arch:
useradd -m -G wheel -s /bin/bash myuser
passwd myuser    # Set a password

# Give user sudo access
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel

# Set as default user
exit
```

**From PowerShell, set default user:**

```powershell
# In C:\ArchWSL\
.\Arch.exe config --default-user myuser
```

---

### Step 6: Verify Installation

```powershell
# Check Arch is installed
wsl --list --verbose

# Should show:
#   NAME    STATE      VERSION
# * Arch    Stopped    2
#   Ubuntu  Stopped    2

# Test it works
wsl -d Arch -e bash -c "echo 'Arch Linux is working!' && uname -a"
```

---

### Step 7: Build CustomOS

**Now you can build your distro:**

```powershell
cd E:\PROJECTS!\distro

# Run setup
wsl -d Arch -e bash -c "cd /mnt/e/PROJECTS!/distro && chmod +x scripts/*.sh && ./scripts/setup-wsl.sh"

# Build the ISO
wsl -d Arch -e bash -c "cd /mnt/e/PROJECTS!/distro && sudo ./scripts/build-iso.sh"
```

This will take 15-30 minutes to download packages and build the ISO.

---

## Troubleshooting

### "Distribution not found"
- Make sure you extracted Arch.zip and ran Arch.exe
- Run: `wsl --list` to see installed distributions

### "Access denied" or permission errors
- Run PowerShell as Administrator
- Check antivirus isn't blocking WSL

### WSL commands hang
- Restart WSL: `wsl --shutdown`
- Restart LxssManager service: `Restart-Service LxssManager` (as Admin)
- Reboot Windows if issues persist

### Pacman signature errors
```bash
wsl -d Arch
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
```

---

## Alternative: Use Docker Instead

If WSL continues to have issues, I can create a Docker-based build system that doesn't rely on WSL. Let me know if you want that option.

---

## Quick Reference

```powershell
# List WSL distributions
wsl --list --verbose

# Enter Arch Linux
wsl -d Arch

# Shutdown WSL
wsl --shutdown

# Unregister (delete) a distribution
wsl --unregister Arch

# Update WSL
wsl --update
```

---

**Next Steps:**
1. Restart your computer
2. Download Arch.zip from GitHub
3. Extract and run Arch.exe
4. Follow steps 4-7 above

Good luck! Let me know when you're ready to build the ISO.
