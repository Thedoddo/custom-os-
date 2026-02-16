# Build CustomOS ISO from Windows
# This script automates the build process using WSL

param(
    [string]$Distribution = "archlinux"
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  CustomOS Builder (Windows)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is available
try {
    $wslList = wsl --list --quiet
} catch {
    Write-Host "ERROR: WSL is not available" -ForegroundColor Red
    Write-Host "Install WSL2 first: wsl --install" -ForegroundColor Yellow
    exit 1
}

# Check if requested distribution exists
if ($wslList -notcontains $Distribution) {
    Write-Host "ERROR: WSL distribution '$Distribution' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available distributions:" -ForegroundColor Yellow
    wsl --list --verbose
    Write-Host ""
    Write-Host "Recommendation: Install Arch Linux WSL" -ForegroundColor Yellow
    Write-Host "  Download ArchWSL from: https://github.com/yuk7/ArchWSL/releases" -ForegroundColor Cyan
    exit 1
}

Write-Host "Using WSL distribution: $Distribution" -ForegroundColor Green
Write-Host ""

# Project paths
$ProjectRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($ProjectRoot)) {
    $ProjectRoot = Get-Location
}
$ProjectRoot = Split-Path -Parent $ProjectRoot

# Convert Windows path to WSL path
$WslPath = $ProjectRoot -replace '^([A-Z]):', '/mnt/$1' -replace '\\', '/'
$WslPath = $WslPath.ToLower()

Write-Host "Project directory: $ProjectRoot" -ForegroundColor Gray
Write-Host "WSL path: $WslPath" -ForegroundColor Gray
Write-Host ""

# Step 1: Make scripts executable
Write-Host "[1/4] Making scripts executable..." -ForegroundColor Yellow
$makeExecCmd = "cd '$WslPath' && chmod +x scripts/*.sh wine-integration/*.sh archiso/profiledef.sh"
wsl -d $Distribution -e bash -c $makeExecCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to make scripts executable" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Scripts are executable" -ForegroundColor Green
Write-Host ""

# Step 2: Check if archiso is installed
Write-Host "[2/4] Checking dependencies..." -ForegroundColor Yellow
$checkCmd = "command -v mkarchiso >/dev/null 2>&1 && echo 'installed' || echo 'not-installed'"
$archIsoStatus = wsl -d $Distribution -e bash -c $checkCmd

if ($archIsoStatus -match "not-installed") {
    Write-Host "  archiso not found. Running setup script..." -ForegroundColor Yellow
    Write-Host "  This will take 5-10 minutes on first run..." -ForegroundColor Gray
    Write-Host ""
    
    $setupCmd = "cd '$WslPath' && ./scripts/setup-wsl.sh"
    wsl -d $Distribution -e bash -c $setupCmd
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Setup failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✓ Dependencies installed" -ForegroundColor Green
}
Write-Host ""

# Step 3: Install Electron dependencies
Write-Host "[3/4] Installing Electron dependencies..." -ForegroundColor Yellow
$npmCmd = "cd '$WslPath/electron-de' && npm install 2>&1 | tail -5"
wsl -d $Distribution -e bash -c $npmCmd
Write-Host "  ✓ Electron dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 4: Build the ISO
Write-Host "[4/4] Building ISO..." -ForegroundColor Yellow
Write-Host "  This will take 15-30 minutes on first build..." -ForegroundColor Gray
Write-Host "  Downloading packages, configuring system, creating ISO..." -ForegroundColor Gray
Write-Host ""

$buildCmd = "cd '$WslPath' && sudo ./scripts/build-iso.sh"
wsl -d $Distribution -e bash -c $buildCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Not enough disk space (need ~10GB)" -ForegroundColor Gray
    Write-Host "  - Network issues downloading packages" -ForegroundColor Gray
    Write-Host "  - Permission issues (check sudo access)" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "ISO location: $ProjectRoot\out\" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Test the ISO" -ForegroundColor Yellow
Write-Host "  Run: .\scripts\test-qemu.ps1" -ForegroundColor Cyan
Write-Host ""
