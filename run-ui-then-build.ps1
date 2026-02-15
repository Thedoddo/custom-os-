# CustomOS - View UI & Build ISO Script
# Run this script to see the desktop UI, then build the ISO on WSL native filesystem

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CustomOS - UI Demo & ISO Build" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Get current directory as WSL path
$currentDir = $PWD.Path
$wslPath = wsl wslpath -a $currentDir

Write-Host "Working Directory: $currentDir" -ForegroundColor Gray
Write-Host "WSL Path: $wslPath`n" -ForegroundColor Gray

# Step 1: Check for X Server
Write-Host "Step 1: Checking for X Server (needed to display UI)..." -ForegroundColor Yellow

$vcxsrv = Get-Process -Name vcxsrv -ErrorAction SilentlyContinue
$xming = Get-Process -Name Xming -ErrorAction SilentlyContinue

if (-not $vcxsrv -and -not $xming) {
    Write-Host "  Warning: No X Server detected!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  To see the UI, you need an X Server running:" -ForegroundColor Yellow
    Write-Host "    - Install VcXsrv: winget install VcXsrv" -ForegroundColor White
    Write-Host "    - Or install Xming: https://sourceforge.net/projects/xming/" -ForegroundColor White
    Write-Host "    - Launch it, then run this script again" -ForegroundColor White
    Write-Host ""
    
    $skip = Read-Host "Skip UI demo and go straight to ISO build? (y/n)"
    if ($skip -ne 'y') {
        Write-Host "Exiting. Install X Server and try again!" -ForegroundColor Red
        exit
    }
    Write-Host ""
} else {
    Write-Host "  X Server found!" -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Launch UI
    Write-Host "Step 2: Launching Electron Desktop UI..." -ForegroundColor Yellow
    Write-Host "  (Press Ctrl+C in the Electron window to close it)" -ForegroundColor Gray
    Write-Host ""
    
    # Set DISPLAY environment variable for WSL
    wsl bash -c "export DISPLAY=:0 && cd '$wslPath/desktop' && npm start"
    
    Write-Host ""
    Write-Host "UI demo complete!" -ForegroundColor Green
    Write-Host ""
    
    $continue = Read-Host "Ready to build the ISO? This will take 30-60 minutes (y/n)"
    if ($continue -ne 'y') {
        Write-Host "Build cancelled. Run this script again when ready!" -ForegroundColor Yellow
        exit
    }
    Write-Host ""
}

# Step 3: Copy to WSL native filesystem
Write-Host "Step 3: Copying project to WSL native filesystem..." -ForegroundColor Yellow
Write-Host "  This avoids Windows mount issues that cause tar failures" -ForegroundColor Gray
Write-Host ""

$copyResult = wsl bash -c "rsync -av --exclude=build --exclude=node_modules --exclude=.git --exclude=desktop/dist --exclude=desktop/node_modules '$wslPath/' ~/distro-build/ 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Project copied to ~/distro-build" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "  ✗ Copy failed!" -ForegroundColor Red
    Write-Host $copyResult
    exit 1
}

# Step 4: Make scripts executable
Write-Host "Step 4: Setting permissions..." -ForegroundColor Yellow
wsl bash -c 'cd ~/distro-build; chmod +x build.sh setup.sh test-iso.sh; chmod +x config/hooks/normal/*.hook.chroot 2>&1' | Out-Null
Write-Host "  Scripts are executable" -ForegroundColor Green
Write-Host ""

# Step 5: Start the build
Write-Host "Step 5: Building ISO (this takes 30-60 minutes)..." -ForegroundColor Yellow
Write-Host "  Building in: ~/distro-build/" -ForegroundColor Gray
Write-Host "  Output: ~/distro-build/build/customos-*.iso" -ForegroundColor Gray
Write-Host ""
Write-Host "  You can monitor progress in another terminal with:" -ForegroundColor Cyan
Write-Host "    wsl bash -c 'tail -f ~/distro-build/build/build.log'" -ForegroundColor White
Write-Host ""

$buildStart = Get-Date

# Run the build
wsl bash -c 'cd ~/distro-build; sudo ./build.sh 2>&1'

$buildEnd = Get-Date
$duration = $buildEnd - $buildStart

Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ISO BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Build time: $($duration.TotalMinutes.ToString('0.0')) minutes" -ForegroundColor Cyan
    Write-Host ""
    
    # Step 6: Copy ISO back to Windows
    Write-Host "Step 6: Copying ISO back to Windows..." -ForegroundColor Yellow
    wsl bash -c "cp ~/distro-build/build/customos-*.iso '$wslPath/'" 2>&1 | Out-Null
    
    $isoPattern = Join-Path $currentDir "customos-*.iso"
    if (Test-Path $isoPattern) {
        Write-Host "  ISO copied to $currentDir\" -ForegroundColor Green
        Write-Host ""
        
        # Get ISO filename
        $isoFile = Get-ChildItem $isoPattern | Select-Object -First 1
        
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Ready to Test!" -ForegroundColor Cyan
        Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "ISO Location: $($isoFile.FullName)" -ForegroundColor White
        Write-Host "ISO Size: $([math]::Round($isoFile.Length / 1MB, 2)) MB" -ForegroundColor White
        Write-Host ""
        Write-Host "To test in QEMU:" -ForegroundColor Yellow
        Write-Host "  .\run-qemu.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "Or with more resources:" -ForegroundColor Yellow
        Write-Host "  .\run-qemu.ps1 -Memory 4096 -Cores 4" -ForegroundColor White
        Write-Host ""
        
        $testNow = Read-Host "Launch in QEMU now? (y/n)"
        if ($testNow -eq 'y') {
            Write-Host ""
            Write-Host "Starting QEMU..." -ForegroundColor Green
            .\run-qemu.ps1
        }
    } else {
        Write-Host "  Warning: Could not copy ISO to Windows" -ForegroundColor Yellow
        Write-Host "  ISO is still available at ~/distro-build/build/" -ForegroundColor Gray
    }
    
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  BUILD FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the log for errors:" -ForegroundColor Yellow
    Write-Host "  wsl bash -c 'tail -100 ~/distro-build/build/build.log'" -ForegroundColor White
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host '  - Disk space: wsl bash -c "df -h ~"' -ForegroundColor White
    Write-Host "  - WSL still has issues: Try GitHub Actions instead" -ForegroundColor White
    Write-Host ""
}
