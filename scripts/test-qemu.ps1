# QEMU Test Script for CustomOS (Windows PowerShell)
# Boots the ISO in QEMU for testing on Windows

param(
    [string]$IsoPath = "",
    [int]$Memory = 4096,
    [int]$Cpus = 4
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  CustomOS QEMU Test (Windows)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Find project root
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $ProjectRoot "out"

# Find the most recent ISO if not specified
if ([string]::IsNullOrEmpty($IsoPath)) {
    $IsoFiles = Get-ChildItem -Path $OutDir -Filter "*.iso" -File | Sort-Object LastWriteTime -Descending
    if ($IsoFiles.Count -eq 0) {
        Write-Host "Error: No ISO file found in $OutDir" -ForegroundColor Red
        Write-Host "Build an ISO first in WSL2: sudo ./scripts/build-iso.sh" -ForegroundColor Yellow
        exit 1
    }
    $IsoPath = $IsoFiles[0].FullName
}

if (-not (Test-Path $IsoPath)) {
    Write-Host "Error: ISO file not found: $IsoPath" -ForegroundColor Red
    exit 1
}

Write-Host "ISO: $IsoPath" -ForegroundColor Green
Write-Host ""

# Check if QEMU is installed
$QemuPaths = @(
    "C:\Program Files\qemu\qemu-system-x86_64.exe",
    "C:\Program Files (x86)\qemu\qemu-system-x86_64.exe",
    "$env:ProgramFiles\qemu\qemu-system-x86_64.exe",
    "${env:ProgramFiles(x86)}\qemu\qemu-system-x86_64.exe"
)

$QemuExe = $null
foreach ($path in $QemuPaths) {
    if (Test-Path $path) {
        $QemuExe = $path
        break
    }
}

# Try to find in PATH
if ($null -eq $QemuExe) {
    $QemuExe = (Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue).Source
}

if ($null -eq $QemuExe) {
    Write-Host "Error: QEMU is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install QEMU for Windows:" -ForegroundColor Yellow
    Write-Host "  Download: https://qemu.weilnetz.de/w64/" -ForegroundColor Cyan
    Write-Host "  Or use chocolatey: choco install qemu" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternative: Use VirtualBox or test in WSL2 with QEMU" -ForegroundColor Yellow
    exit 1
}

Write-Host "QEMU: $QemuExe" -ForegroundColor Green

# Create virtual disk for testing
$DiskImg = Join-Path $ProjectRoot "test-disk.qcow2"
if (-not (Test-Path $DiskImg)) {
    Write-Host "Creating virtual disk (20GB)..." -ForegroundColor Yellow
    $QemuImg = Join-Path (Split-Path $QemuExe) "qemu-img.exe"
    & $QemuImg create -f qcow2 $DiskImg 20G
    Write-Host "Virtual disk created: $DiskImg" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Memory: $Memory MB" -ForegroundColor Gray
Write-Host "CPUs: $Cpus" -ForegroundColor Gray
Write-Host ""
Write-Host "Starting QEMU..." -ForegroundColor Yellow
Write-Host "Press Ctrl+Alt+G to release mouse/keyboard" -ForegroundColor Cyan
Write-Host ""

# QEMU arguments
$QemuArgs = @(
    "-m", "$Memory",
    "-smp", "$Cpus",
    "-cdrom", $IsoPath,
    "-hda", $DiskImg,
    "-boot", "d",
    "-vga", "virtio",
    "-net", "nic,model=virtio",
    "-net", "user"
)

# Check if WHPX (Windows Hypervisor Platform) is available for acceleration
# Note: Requires Windows 10 1803+ and Hyper-V features enabled
$QemuArgs += "-accel", "whpx,tcg"

# Run QEMU
try {
    & $QemuExe $QemuArgs
    Write-Host ""
    Write-Host "QEMU exited" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "QEMU error: $_" -ForegroundColor Red
    exit 1
}
