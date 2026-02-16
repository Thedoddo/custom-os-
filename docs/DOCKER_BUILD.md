# Docker Build Guide for CustomOS

## Current Status
✅ Docker Desktop is installed on your system  
❌ Docker command not available in PowerShell (needs setup)

---

## Step 1: Start Docker Desktop

1. **Open Start Menu** → Search for "Docker Desktop"
2. **Click Docker Desktop** to start it
3. **Wait for Docker to fully start** (icon in system tray will stop animating)
4. **Accept any terms/agreements** if prompted
5. **Wait for "Docker Desktop is running"** notification

This may take 2-3 minutes on first start.

---

## Step 2: Verify Docker is Working

**Open a NEW PowerShell window** (important - fresh PATH):

```powershell
# Check Docker version
docker --version

# Should show something like: Docker version 25.x.x

# Check Docker is running
docker ps

# Should show: CONTAINER ID   IMAGE   ... (empty table is fine)
```

If you still get "docker command not found":
- Close ALL PowerShell windows
- Wait 30 seconds
- Open a new PowerShell as Administrator
- Try again

---

## Step 3: Build CustomOS ISO with Docker

Once Docker is working:

```powershell
cd E:\PROJECTS!\distro

# Build the ISO (this will take 15-30 minutes)
.\scripts\build-docker.ps1
```

This will:
1. Build a Docker image with Arch Linux + build tools (~5 mins)
2. Build your CustomOS ISO inside the container (~20 mins)
3. Output ISO to `out/customos-*.iso`

---

## Alternative: Docker Compose Method

If you prefer Docker Compose:

```powershell
cd E:\PROJECTS!\distro

# Build the Docker image
docker-compose build

# Run the build
docker-compose run builder ./scripts/build-iso.sh
```

---

## Common Docker Issues

### "Docker Desktop is starting..."
Wait for it to finish. Check system tray icon - should be steady, not animated.

### "Cannot connect to Docker daemon"
Docker Desktop isn't running. Start it from Start Menu.

### "no matching manifest for windows/amd64"
Make sure Docker Desktop is set to use **Linux containers**, not Windows containers:
- Right-click Docker Desktop icon in system tray
- If you see "Switch to Linux containers", click it
- If you see "Switch to Windows containers", you're good

### "Access denied" or permission errors
Run PowerShell as Administrator

---

## Test the Built ISO

After building successfully:

### With QEMU:
```powershell
.\scripts\test-qemu.ps1
```

### With VirtualBox:
1. Open VirtualBox
2. Create new VM (Linux, Arch Linux, 4GB RAM)
3. Attach `out/customos-*.iso`
4. Boot and test

---

## Docker Build Advantages

✅ No WSL issues - completely isolated  
✅ Clean environment every time  
✅ Easy to reproduce builds  
✅ Works on any Windows system with Docker  
✅ Can share Docker image with others  

---

## Troubleshooting

### Docker won't start
1. Check if WSL is interfering: `wsl --shutdown`
2. Restart Docker Desktop
3. Check Windows Services: Docker Desktop Service should be "Running"
4. Reboot computer if needed

### Build fails in Docker
```powershell
# Clean and rebuild
.\scripts\build-docker.ps1 -Clean

# Or manually:
docker system prune -a
docker-compose build --no-cache
```

### Check Docker logs
```powershell
# View Docker Desktop logs
# Click Docker icon → Troubleshoot → View logs
```

---

## Next Steps

1. ✅ Start Docker Desktop (wait for it to fully start)
2. ✅ Open NEW PowerShell window
3. ✅ Verify: `docker --version`
4. ✅ Build: `.\scripts\build-docker.ps1`
5. ✅ Test: `.\scripts\test-qemu.ps1`

---

**Once Docker is running, building will be much easier than WSL!**
