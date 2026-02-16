# Fix Arch Linux WSL Issues

## Problem
Your Arch Linux WSL has user/systemd configuration errors preventing it from starting.

## Solution

### Option 1: Reinstall Arch Linux WSL (Recommended - 5 minutes)

1. **Unregister the broken installation:**
   ```powershell
   wsl --unregister archlinux
   ```
   ⚠️ This deletes the existing Arch WSL (back up if needed)

2. **Download fresh ArchWSL:**
   - Go to: https://github.com/yuk7/ArchWSL/releases
   - Download latest `Arch.zip`
   - Extract to `C:\ArchWSL\` (or your preferred location)

3. **Install:**
   ```powershell
   cd C:\ArchWSL
   .\Arch.exe
   ```
   - Follow the prompts to set up a user

4. **Verify:**
   ```powershell
   wsl -d Arch
   ```

### Option 2: Try to Fix Current Installation

1. **Check WSL version:**
   ```powershell
   wsl --list --verbose
   ```
   Make sure it shows VERSION 2 for archlinux

2. **Update WSL:**
   ```powershell
   wsl --update
   wsl --shutdown
   ```

3. **Try starting with different user:**
   ```powershell
   wsl -d archlinux -u root
   ```

4. **If that works, fix the files:**
   ```bash
   touch /etc/default/locale
   echo "LANG=en_US.UTF-8" > /etc/default/locale
   ```

### Option 3: Use Docker Instead (Alternative)

If WSL issues persist, you can build using Docker:

```powershell
# Coming soon - Docker-based build script
```

## After Fixing

Once Arch Linux WSL works, run:

```powershell
cd E:\PROJECTS!\distro
.\scripts\build.ps1
```

This will:
1. Install archiso and dependencies
2. Build the CustomOS ISO
3. Take 15-30 minutes on first run

## Quick Test

Test if Arch WSL is working:
```powershell
wsl -d archlinux -e bash -c "echo 'WSL is working!'; uname -a"
```

If you see "WSL is working!" and kernel info, you're good to go!
