# CustomOS - Autonomous ISO Build
# This script handles the entire build process without user interaction

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CustomOS - Autonomous ISO Build" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$currentDir = $PWD.Path

Write-Host "Starting autonomous build process..." -ForegroundColor Green
Write-Host "Build location: WSL ~/distro-build/" -ForegroundColor Gray
Write-Host "This will take 30-60 minutes`n" -ForegroundColor Gray

# Get WSL path - handle the ! character
$wslPath = "/mnt/" + $currentDir.Substring(0,1).ToLower() + $currentDir.Substring(2).Replace('\', '/').Replace('!', '\!')

Write-Host "[1/5] Copying project to WSL native filesystem..." -ForegroundColor Yellow
Write-Host "      (Avoids Windows mount tar extraction issues)" -ForegroundColor DarkGray

$copyCmd = "rsync -av --exclude=build --exclude=node_modules --exclude=.git --exclude=desktop/dist --exclude=desktop/node_modules '$wslPath/' ~/distro-build/ 2>&1 | tail -5"
$copyResult = wsl bash -c $copyCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "      Done!`n" -ForegroundColor Green
} else {
    Write-Host "`nERROR: Failed to copy project files" -ForegroundColor Red
    Write-Host $copyResult
    exit 1
}

Write-Host "[2/5] Setting permissions..." -ForegroundColor Yellow
wsl bash -c 'cd ~/distro-build; chmod +x build.sh setup.sh test-iso.sh; chmod +x config/hooks/normal/*.hook.chroot' 2>&1 | Out-Null
Write-Host "      Done!`n" -ForegroundColor Green

Write-Host "[3/5] Checking disk space..." -ForegroundColor Yellow
$diskSpace = wsl bash -c 'df -h ~ | tail -1 | awk "{print \$4}"'
Write-Host "      Available: $diskSpace`n" -ForegroundColor Green

Write-Host "[4/5] Building ISO (this is the long part)..." -ForegroundColor Yellow
Write-Host "      Started: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "      Monitor in another terminal: wsl bash -c 'tail -f ~/distro-build/build/build.log'" -ForegroundColor DarkGray
Write-Host ""

$buildStart = Get-Date

# Run the build and show periodic progress
$buildJob = Start-Job -ScriptBlock {
    wsl bash -c 'cd ~/distro-build; sudo ./build.sh 2>&1'
}

# Show progress dots while building
Write-Host "      Building" -NoNewline -ForegroundColor Yellow
while ($buildJob.State -eq 'Running') {
    Start-Sleep -Seconds 10
    Write-Host "." -NoNewline -ForegroundColor Yellow
}

# Wait for completion and get results
$buildOutput = Receive-Job -Job $buildJob
if ($buildJob.State -eq 'Completed') {
    $buildExitCode = 0
} else {
    $buildExitCode = 1
}
Remove-Job -Job $buildJob

$buildEnd = Get-Date
$duration = $buildEnd - $buildStart

Write-Host ""
Write-Host "      Finished: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "      Duration: $($duration.TotalMinutes.ToString('0.0')) minutes`n" -ForegroundColor DarkGray

if ($buildExitCode -eq 0) {
    Write-Host "[5/5] Copying ISO back to Windows..." -ForegroundColor Yellow
    wsl bash -c "cp ~/distro-build/build/customos-*.iso '$wslPath/'" 2>&1 | Out-Null
    
    $isoPattern = Join-Path $currentDir "customos-*.iso"
    $isoFile = Get-ChildItem $isoPattern -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($isoFile) {
        Write-Host "      Done!`n" -ForegroundColor Green
        
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        
        Write-Host "ISO Details:" -ForegroundColor Cyan
        Write-Host "  Location: $($isoFile.FullName)" -ForegroundColor White
        Write-Host "  Size: $([math]::Round($isoFile.Length / 1MB, 2)) MB" -ForegroundColor White
        Write-Host "  Build Time: $($duration.TotalMinutes.ToString('0.0')) minutes`n" -ForegroundColor White
        
        Write-Host "Next Steps:" -ForegroundColor Cyan
        Write-Host "  Test in QEMU: .\run-qemu.ps1" -ForegroundColor White
        Write-Host "  Or with more resources: .\run-qemu.ps1 -Memory 4096 -Cores 4`n" -ForegroundColor White
        
        # Auto-launch QEMU
        Write-Host "Launching in QEMU automatically in 5 seconds..." -ForegroundColor Yellow
        Write-Host "(Press Ctrl+C to cancel)`n" -ForegroundColor DarkGray
        Start-Sleep -Seconds 5
        
        if (Test-Path ".\run-qemu.ps1") {
            .\run-qemu.ps1
        } else {
            Write-Host "run-qemu.ps1 not found. Launch manually with:" -ForegroundColor Yellow
            Write-Host "  D:\qemu\qemu-system-x86_64w.exe -cdrom `"$($isoFile.FullName)`" -m 2048 -smp 2 -accel whpx" -ForegroundColor White
        }
        
    } else {
        Write-Host "`nWARNING: ISO built but could not copy to Windows" -ForegroundColor Yellow
        Write-Host "ISO available at: ~/distro-build/build/" -ForegroundColor Gray
        Write-Host "Copy manually: wsl bash -c 'cp ~/distro-build/build/customos-*.iso $wslPath/'" -ForegroundColor Gray
    }
    
} else {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  BUILD FAILED" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    
    Write-Host "Last 20 lines of build log:" -ForegroundColor Yellow
    wsl bash -c 'tail -20 ~/distro-build/build/build.log'
    
    Write-Host "`nCommon Issues:" -ForegroundColor Cyan
    Write-Host "  1. Disk space: wsl bash -c 'df -h ~'" -ForegroundColor White
    Write-Host "  2. WSL issues: Try GitHub Actions (already configured)" -ForegroundColor White
    Write-Host "  3. Check full log: wsl bash -c 'less ~/distro-build/build/build.log'`n" -ForegroundColor White
}
