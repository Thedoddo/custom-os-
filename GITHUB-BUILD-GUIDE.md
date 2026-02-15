# Build ISO on GitHub Actions

## Quick Steps

### 1. Install Git
Download: https://git-scm.com/download/win
- Run installer, use defaults
- Restart terminal after install

### 2. Setup Repository
```powershell
# In your project folder
git init
git add .
git commit -m "Initial commit - Custom OS with liquid glass desktop"
```

### 3. Create GitHub Repo
- Go to: https://github.com/new
- Repository name: `custom-os`
- Click "Create repository"
- Copy the commands shown

### 4. Push Code
```powershell
git remote add origin https://github.com/YOUR-USERNAME/custom-os.git
git branch -M main
git push -u origin main
```

### 5. Trigger Build
- Go to: https://github.com/YOUR-USERNAME/custom-os/actions
- Click "Build Custom OS ISO"
- Click "Run workflow" → "Run workflow"
- Wait 20-30 minutes
- Download ISO from "Artifacts"

## That's It!
Your ISO will be built on GitHub's Linux servers FREE!

---

## OR - Alternative: Just Use Windows Version
Your desktop already works:
```powershell
cd dist\win-unpacked
.\CustomOS.exe
```
