# Run CustomOS in QEMU on Windows
# This script launches the ISO in QEMU for testing

param(
    [string]$IsoPath = "custom-os.iso",
    [int]$Memory = 2048,
    [int]$Cores = 2,
    [string]$QemuPath = "D:\qemu\qemu-system-x86_64w.exe"
)

Write-Host "`n=== CustomOS QEMU Launcher ===" -ForegroundColor Cyan
Write-Host ""

# Check if QEMU exists
if (-not (Test-Path $QemuPath)) {
    Write-Host "[!] QEMU not found at: $QemuPath" -ForegroundColor Red
    Write-Host "    Looking for QEMU..." -ForegroundColor Yellow
    
    # Search common locations
    $searchPaths = @(
        "D:\qemu\qemu-system-x86_64w.exe",
        "D:\qemu\qemu-system-x86_64.exe",
        "C:\Program Files\qemu\qemu-system-x86_64w.exe",
        "C:\Program Files\qemu\qemu-system-x86_64.exe"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $QemuPath = $path
            Write-Host "[OK] Found QEMU at: $QemuPath" -ForegroundColor Green
            break
        }
    }
    
    if (-not (Test-Path $QemuPath)) {
        Write-Host "`nPlease install QEMU from: https://qemu.weilnetz.de/w64/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "[OK] QEMU: $QemuPath" -ForegroundColor Green

# Check if ISO exists
if (-not (Test-Path $IsoPath)) {
    Write-Host "[!] ISO not found: $IsoPath" -ForegroundColor Red
    Write-Host "`nYou need to build the ISO first:" -ForegroundColor Yellow
    Write-Host "  1. Use WSL: wsl -d Ubuntu -- cd /mnt/e/PROJECTS!/distro && sudo ./build.sh"
    Write-Host "  2. Or push to GitHub and download from Actions artifacts"
    Write-Host ""
    exit 1
}

$isoFile = Get-Item $IsoPath
$isoSizeMB = [math]::Round($isoFile.Length / 1MB, 2)

Write-Host "[OK] ISO: $IsoPath ($isoSizeMB MB)" -ForegroundColor Green
Write-Host "[OK] Memory: $Memory MB" -ForegroundColor Green
Write-Host "[OK] CPU Cores: $Cores" -ForegroundColor Green
Write-Host ""

# Check for acceleration
$accelArgs = ""
if ((Get-CimInstance -ClassName Win32_Processor).VirtualizationFirmwareEnabled) {
    $accelArgs = "-accel whpx"
    Write-Host "[OK] Hardware acceleration: WHPX enabled" -ForegroundColor Green
} else {
    Write-Host "[!] No hardware acceleration (will be slower)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting QEMU..." -ForegroundColor Cyan
Write-Host "  - Press Ctrl+Alt+G to release mouse" -ForegroundColor Gray
Write-Host "  - Press Alt+F4 or close window to exit" -ForegroundColor Gray
Write-Host ""

# Build QEMU arguments
$qemuArgs = @(
    "-cdrom", $IsoPath,
    "-m", $Memory,
    "-smp", $Cores,
    "-vga", "virtio",
    "-device", "virtio-net,netdev=net0",
    "-netdev", "user,id=net0",
    "-device", "AC97",
    "-boot", "d"
)

if ($accelArgs) {
    $qemuArgs += $accelArgs.Split(" ")
}

# Launch QEMU
try {
    & $QemuPath $qemuArgs
    Write-Host "`n[OK] QEMU session ended" -ForegroundColor Green
} catch {
    Write-Host "`n[!] Error launching QEMU: $_" -ForegroundColor Red
    exit 1
}
