# CustomOS - UI Preview Only
# This script just shows the Electron desktop interface

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CustomOS - UI Preview" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check for X Server
$vcxsrv = Get-Process -Name vcxsrv -ErrorAction SilentlyContinue
$xming = Get-Process -Name Xming -ErrorAction SilentlyContinue

if (-not $vcxsrv -and -not $xming) {
    Write-Host "ERROR: No X Server detected!`n" -ForegroundColor Red
    Write-Host "You need an X Server to display Linux GUI apps on Windows.`n" -ForegroundColor Yellow
    Write-Host "Quick setup:" -ForegroundColor Green
    Write-Host "  1. Install: winget install VcXsrv" -ForegroundColor White
    Write-Host "  2. Launch 'XLaunch' from Start menu" -ForegroundColor White
    Write-Host "  3. Click through the setup (defaults are fine)" -ForegroundColor White
    Write-Host "  4. Run this script again`n" -ForegroundColor White
    exit 1
}

Write-Host "X Server detected!" -ForegroundColor Green
Write-Host "Launching Electron Desktop UI...`n" -ForegroundColor Yellow

# Get WSL path - properly escape the ! character
$currentDir = $PWD.Path
$wslPathRaw = "/mnt/" + $currentDir.Substring(0,1).ToLower() + $currentDir.Substring(2).Replace('\', '/')

Write-Host "Working Directory: $currentDir" -ForegroundColor Gray
Write-Host "Starting desktop app..." -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to close the app`n" -ForegroundColor Yellow

# Launch with DISPLAY set - use double quotes to let bash handle the path
wsl bash -c "export DISPLAY=:0 && cd `"$wslPathRaw/desktop`" && npm start"

Write-Host "`nUI Preview complete!" -ForegroundColor Green
