# Docker Build Script for CustomOS
# Builds the ISO using Docker instead of WSL

param(
    [switch]$Clean = $false,
    [switch]$NoBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  CustomOS Docker Builder" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker version --format '{{.Server.Version}}' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker is not running" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
        exit 1
    }
    Write-Host "  ✓ Docker is running (version $dockerVersion)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Docker Desktop from:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# Project paths
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $ProjectRoot "out"
$WorkDir = Join-Path $ProjectRoot "work"

Write-Host "Project directory: $ProjectRoot" -ForegroundColor Gray
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    if (Test-Path $WorkDir) { Remove-Item -Recurse -Force $WorkDir }
    if (Test-Path $OutDir) { Remove-Item -Recurse -Force $OutDir }
    Write-Host "  ✓ Cleaned" -ForegroundColor Green
    Write-Host ""
}

# Create directories
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

# Build Docker image
Write-Host "[1/2] Building Docker image..." -ForegroundColor Yellow
Write-Host "  This may take 5-10 minutes on first run..." -ForegroundColor Gray
Write-Host ""

docker build -t customos-builder -f "$ProjectRoot\Dockerfile" "$ProjectRoot"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Docker image build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  ✓ Docker image built" -ForegroundColor Green
Write-Host ""

if ($NoBuild) {
    Write-Host "Skipping ISO build (--NoBuild flag)" -ForegroundColor Yellow
    exit 0
}

# Build ISO in Docker container
Write-Host "[2/2] Building ISO in Docker container..." -ForegroundColor Yellow
Write-Host "  This will take 15-30 minutes..." -ForegroundColor Gray
Write-Host "  Downloading packages, configuring system, creating ISO..." -ForegroundColor Gray
Write-Host ""

# Run the build in Docker
docker run --rm `
    -v "${ProjectRoot}:/build" `
    -w /build `
    customos-builder `
    bash -c "chmod +x scripts/build-iso.sh && ./scripts/build-iso.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: ISO build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the output above for errors" -ForegroundColor Yellow
    exit 1
}

# Find the built ISO
$IsoFiles = Get-ChildItem -Path $OutDir -Filter "*.iso" -File | Sort-Object LastWriteTime -Descending

if ($IsoFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "ERROR: No ISO file found in $OutDir" -ForegroundColor Red
    exit 1
}

$IsoFile = $IsoFiles[0]
$IsoSize = [math]::Round($IsoFile.Length / 1MB, 2)

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "ISO file: $($IsoFile.FullName)" -ForegroundColor Cyan
Write-Host "Size: $IsoSize MB" -ForegroundColor Gray
Write-Host ""
Write-Host "Next: Test the ISO" -ForegroundColor Yellow
Write-Host "  QEMU:       .\scripts\test-qemu.ps1" -ForegroundColor Cyan
Write-Host "  VirtualBox: Attach ISO to a new VM" -ForegroundColor Cyan
Write-Host ""
