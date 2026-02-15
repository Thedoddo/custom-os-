# IMPORTANT: Script Permissions for Linux/WSL

## If you're on Windows

The `.sh` script files have been created but need to be made executable when you move to Linux or WSL.

### On Linux or WSL, run this:

```bash
cd /path/to/distro

# Make build scripts executable
chmod +x build.sh
chmod +x setup.sh
chmod +x test-iso.sh

# Make hooks executable
chmod +x config/hooks/normal/*.hook.chroot

# Make session script executable
chmod +x config/includes.chroot/usr/bin/custom-os-desktop
```

### Quick Command (Copy-Paste All)

```bash
cd "$(git rev-parse --show-toplevel)" && \
chmod +x build.sh setup.sh test-iso.sh && \
chmod +x config/hooks/normal/*.hook.chroot && \
chmod +x config/includes.chroot/usr/bin/custom-os-desktop && \
echo "✓ All scripts are now executable!"
```

## Verifying Permissions

```bash
# Check if scripts are executable
ls -la *.sh
# Should show: -rwxr-xr-x

# Check hooks
ls -la config/hooks/normal/
# Should show: -rwxr-xr-x

# Check session script
ls -la config/includes.chroot/usr/bin/custom-os-desktop
# Should show: -rwxr-xr-x
```

## If Using Git

If you commit these files and push to GitHub, Git will remember the executable permissions. When someone else clones the repo on Linux, the files will automatically be executable.

To set executable in Git (on Windows):
```bash
git update-index --chmod=+x build.sh
git update-index --chmod=+x setup.sh
git update-index --chmod=+x test-iso.sh
git update-index --chmod=+x config/hooks/normal/9999-customos-config.hook.chroot
git update-index --chmod=+x config/hooks/normal/9999-cleanup.hook.chroot
git update-index --chmod=+x config/includes.chroot/usr/bin/custom-os-desktop
```

## Line Endings (Important!)

Since you're on Windows, ensure Unix line endings (LF) for shell scripts:

Create `.gitattributes`:
```
*.sh text eol=lf
*.hook.chroot text eol=lf
```

Or convert manually:
```bash
# Using dos2unix (install first)
dos2unix *.sh
dos2unix config/hooks/normal/*.hook.chroot
dos2unix config/includes.chroot/usr/bin/custom-os-desktop

# Or using sed
sed -i 's/\r$//' *.sh
```

---

**TL;DR**: Before building on Linux, run:
```bash
chmod +x build.sh setup.sh test-iso.sh config/hooks/normal/*.hook.chroot config/includes.chroot/usr/bin/custom-os-desktop
```
