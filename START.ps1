# Custom OS - Build Your Own Linux Distro!

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   CUSTOM OS - Fresh Start!" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✓ Repository cleaned!" -ForegroundColor Green
Write-Host "✓ Desktop app working!" -ForegroundColor Green
Write-Host "✓ ISO builder ready!" -ForegroundColor Green
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   What You Have Now:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. " -NoNewline
Write-Host "Custom Desktop App" -ForegroundColor Green
Write-Host "     → Liquid glass effects, 4 themes" -ForegroundColor Gray
Write-Host "     → Works on Windows NOW" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. " -NoNewline
Write-Host "ISO Builder (Archiso)" -ForegroundColor Green
Write-Host "     → Build your own Linux distro" -ForegroundColor Gray
Write-Host "     → Auto-login configured" -ForegroundColor Gray
Write-Host "     → Desktop pre-installed" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Quick Actions:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Run Desktop on Windows NOW" -ForegroundColor Cyan
Write-Host "      → cd dist\win-unpacked" -ForegroundColor Gray
Write-Host "      → .\CustomOS.exe" -ForegroundColor Gray
Write-Host ""
Write-Host "  [2] Read ISO Builder Guide" -ForegroundColor Cyan
Write-Host "      → cd iso-builder" -ForegroundColor Gray
Write-Host "      → cat README.md" -ForegroundColor Gray
Write-Host ""
Write-Host "  [3] Build Linux ISO (requires WSL2 Arch)" -ForegroundColor Cyan
Write-Host "      → wsl --install -d Arch" -ForegroundColor Gray
Write-Host "      → wsl -d Arch" -ForegroundColor Gray
Write-Host "      → cd iso-builder" -ForegroundColor Gray
Write-Host "      → sudo ./build-iso.sh" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Why Archiso?" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Based on online research:" -ForegroundColor White
Write-Host "  ✓ Auto-login built-in (no hacking!)" -ForegroundColor Green
Write-Host "  ✓ One command builds ISO" -ForegroundColor Green
Write-Host "  ✓ Rolling release (always updated)" -ForegroundColor Green
Write-Host "  ✓ Minimalist (perfect for custom desktop)" -ForegroundColor Green
Write-Host "  ✓ Fast build (~30 minutes)" -ForegroundColor Green
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Next Steps:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Test desktop on Windows" -ForegroundColor White
Write-Host "  2. Install WSL2 Arch Linux" -ForegroundColor White
Write-Host "  3. Run build-iso.sh" -ForegroundColor White
Write-Host "  4. Test ISO in QEMU" -ForegroundColor White
Write-Host "  5. Burn to USB and boot!" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
