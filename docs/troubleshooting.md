# CustomOS Troubleshooting Guide

## Build Issues

### Issue: "lb: command not found"

**Solution**: Install live-build
```bash
sudo apt-get install live-build
```

### Issue: Build fails with "E: Unable to locate package"

**Cause**: Package name is incorrect or not available in Ubuntu repos.

**Solution**: 
1. Check package name: `apt-cache search <package-name>`
2. Remove or replace the package in `config/package-lists/desktop.list.chroot`

### Issue: Out of disk space during build

**Cause**: Building requires 20GB+ free space.

**Solution**:
```bash
# Check disk space
df -h

# Clean up previous build
cd build && sudo lb clean --purge && cd ..

# Remove Docker images (if using Docker)
docker system prune -a
```

### Issue: Electron build fails with npm errors

**Solution**:
```bash
cd desktop
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Issue: Permission denied errors

**Cause**: Build script needs root privileges.

**Solution**:
```bash
sudo ./build.sh
```

### Issue: ISO is too large (>4GB) for FAT32 USB

**Solution**:
1. Format USB as exFAT or ext4
2. Or reduce ISO size by removing packages
3. Use DVD instead of USB

## Runtime Issues

### Issue: Black screen after boot

**Possible causes**:
1. Graphics driver issue
2. X11 not starting
3. Desktop session not loading

**Solutions**:

**Check X11 logs**:
Press `Ctrl+Alt+F2` to get a terminal, then:
```bash
cat /var/log/Xorg.0.log | grep EE
```

**Try different graphics driver**:
Add boot parameter at GRUB:
- `nomodeset` - Use basic graphics
- `i915.modeset=0` - Disable Intel modesetting
- `nouveau.modeset=0` - Disable Nouveau (NVIDIA)

**Start X manually**:
```bash
startx
```

### Issue: Electron desktop doesn't start

**Check if process is running**:
```bash
ps aux | grep electron
ps aux | grep custom-os-desktop
```

**Check logs**:
```bash
journalctl -xe | grep custom-os-desktop
```

**Try starting manually**:
```bash
/usr/bin/custom-os-desktop
```

**Check if Electron app is installed**:
```bash
ls -la /opt/custom-os-desktop/
```

### Issue: No keyboard/mouse input

**Cause**: X11 input drivers not loaded.

**Solution**: Add boot parameter:
```
xorg.conf_input_driver=libinput
```

Or install additional packages:
```bash
sudo apt-get install xserver-xorg-input-libinput
```

### Issue: WiFi not working

**Check if NetworkManager is running**:
```bash
systemctl status NetworkManager
```

**Start NetworkManager**:
```bash
sudo systemctl start NetworkManager
```

**Check WiFi device**:
```bash
nmcli device
ip link show
```

**Check if WiFi is blocked**:
```bash
rfkill list
sudo rfkill unblock wifi
```

### Issue: No sound

**Check PulseAudio**:
```bash
pulseaudio --check
pulseaudio --start
```

**Check sound cards**:
```bash
aplay -l
```

**Unmute audio**:
```bash
alsamixer
# Press M to unmute channels
```

### Issue: Can't install software - "package manager is locked"

**Solution**:
```bash
# Wait for automatic updates to finish, or:
sudo killall apt apt-get
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a
sudo apt-get update
```

### Issue: Screen resolution wrong / HiDPI issues

**Set resolution manually**:
```bash
xrandr --output HDMI-1 --mode 1920x1080
```

**For HiDPI**:
```bash
xrandr --output eDP-1 --scale 0.5x0.5
```

**Make permanent**: Add to `~/.config/openbox/autostart`

### Issue: System runs slowly / High memory usage

**Check resource usage**:
```bash
htop
```

**Electron uses significant RAM** (~200-400MB). This is normal.

**Reduce memory usage**:
1. Close unused applications
2. Disable animations in desktop settings
3. Use lighter alternatives (e.g., lxterminal instead of gnome-terminal)

## Development Issues

### Issue: Hot reload not working in dev mode

**Solution**: Electron doesn't support hot reload by default. Restart:
```bash
cd desktop
npm start
```

### Issue: Can't access system APIs from Electron

**Cause**: Context isolation is enabled (security feature).

**Solution**: Use IPC calls through the preload script:
```javascript
// In renderer
window.api.someFunction()

// Define in preload.js
contextBridge.exposeInMainWorld('api', {
  someFunction: () => ipcRenderer.invoke('some-function')
})

// Handle in main process
ipcMain.handle('some-function', async () => {
  // Do system-level stuff here
})
```

### Issue: Application won't launch from launcher

**Debug**:
```bash
# Try command directly in terminal
firefox
pcmanfm

# Check if command exists
which firefox
```

**Fix**: Update command in `desktop/src/renderer/launcher.js`

### Issue: Panel doesn't stay on top

**Solution**: Check OpenBox configuration in:
- `config/includes.chroot/etc/xdg/openbox/rc.xml`
- Ensure `<layer>above</layer>` is set for the panel

## Installation Issues

### Issue: Can't create bootable USB on Windows

**Solutions**:
1. Use **Rufus** (recommended)
   - Select "DD mode" when prompted
2. Use **balenaEtcher**
3. Use **Ventoy**

### Issue: USB won't boot

**Check BIOS settings**:
1. Disable Secure Boot
2. Enable Legacy/CSM mode (or UEFI mode)
3. Set USB as first boot device

**Verify ISO**:
```bash
# Check SHA256 sum
sha256sum custom-os.iso
# Compare with custom-os.iso.sha256
```

### Issue: Installation fails (if installer is added)

**Common causes**:
1. Insufficient disk space
2. Disk partitioning errors
3. GRUB installation problems

**Solution**: Use manual partitioning and check logs:
```bash
cat /var/log/installer/syslog
```

## GitHub Actions Issues

### Issue: Workflow fails with "No space left on device"

**Solution**: Already handled in workflow with cleanup step. If still failing:
1. Reduce package count
2. Enable more aggressive cleanup in hooks

### Issue: Artifact upload fails

**Cause**: ISO too large (>2GB can be slow).

**Solution**: Split into smaller artifacts or use Release instead of Artifacts.

### Issue: Build timeout (>6 hours)

**Cause**: Downloading packages takes too long.

**Solution**: Use Ubuntu mirrors closer to GitHub's servers, or cache packages.

## Getting Help

If issues persist:

1. **Check logs**: Most problems are logged
2. **Search issues**: Someone may have solved it
3. **Create issue**: Provide:
   - System specs
   - Full error message
   - Steps to reproduce
   - Log files

## Useful Commands

```bash
# Check system info
uname -a
lsb_release -a

# Check loaded modules
lsmod

# Check PCI devices
lspci

# Check USB devices
lsusb

# Check running services
systemctl list-units --type=service

# Remount filesystem read-write (live system)
sudo mount -o remount,rw /

# Check disk usage
df -h
du -sh /path/to/directory

# Monitor system resources
htop
iotop  # I/O monitoring
nethogs  # Network monitoring
```

## Performance Tips

1. **Disable unnecessary services**:
```bash
sudo systemctl disable bluetooth
sudo systemctl disable cups  # If no printer
```

2. **Use lighter applications**:
- PCManFM instead of Nautilus
- xterm/lxterminal instead of gnome-terminal
- mousepad instead of gedit

3. **Reduce animations**: Edit CSS in `desktop/src/renderer/styles.css`

4. **Limit startup applications**: Check `~/.config/autostart/`

## Security Notes

- Change default password immediately after first login
- Keep system updated: `sudo apt-get update && sudo apt-get upgrade`
- Enable firewall: `sudo ufw enable`
- Don't run as root unnecessarily
