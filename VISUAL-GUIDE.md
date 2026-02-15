# CustomOS - Visual Project Map

```
╔══════════════════════════════════════════════════════════════════════╗
║                     CUSTOMOS PROJECT STRUCTURE                       ║
╚══════════════════════════════════════════════════════════════════════╝

📦 distro/
│
├─ 📖 DOCUMENTATION
│  ├─ README.md                    ⭐ Start here!
│  ├─ GETTING-STARTED.md           🚀 Step-by-step guide
│  ├─ PROJECT-SUMMARY.md           📊 What's included
│  ├─ QUICK-REFERENCE.md           ⚡ Command cheat sheet
│  ├─ CONTRIBUTING.md              🤝 How to contribute
│  ├─ WINDOWS-NOTE.md              💻 Important for Windows users!
│  └─ LICENSE                      ⚖️  MIT License
│
├─ 🔨 BUILD SYSTEM
│  ├─ build.sh                     🏗️  Main ISO builder (run with sudo)
│  ├─ setup.sh                     ⚙️  Install dependencies
│  ├─ test-iso.sh                  🧪 Test in QEMU
│  ├─ .gitignore                   🚫 Git ignore rules
│  └─ .gitattributes               📝 Git line ending config
│
├─ 🤖 CI/CD
│  └─ .github/workflows/
│     └─ build.yml                 ☁️  GitHub Actions workflow
│
├─ 🖥️  ELECTRON DESKTOP
│  └─ desktop/
│     ├─ package.json              📦 Dependencies & scripts
│     │
│     ├─ 🎯 MAIN PROCESS (Backend - Node.js)
│     │  └─ src/main/
│     │     ├─ index.js            💡 App entry point
│     │     ├─ preload.js          🔒 IPC security bridge
│     │     └─ system.js           📊 System info gathering
│     │
│     └─ 🎨 RENDERER PROCESS (Frontend - UI)
│        └─ src/renderer/
│           ├─ panel.html          🔝 Top panel structure
│           ├─ panel.js            🎛️  Panel logic
│           ├─ launcher.html       🚀 App launcher structure
│           ├─ launcher.js         📱 Launcher logic
│           └─ styles.css          🎨 Global styles
│
├─ ⚙️  DISTRIBUTION CONFIG
│  └─ config/
│     ├─ README.md                 📚 Config documentation
│     │
│     ├─ 🪝 BUILD HOOKS (Run during build)
│     │  └─ hooks/normal/
│     │     ├─ 9999-customos-config.hook.chroot  🔧 System setup
│     │     └─ 9999-cleanup.hook.chroot          🧹 Size optimization
│     │
│     ├─ 📄 FILES TO INCLUDE IN ISO
│     │  └─ includes.chroot/
│     │     ├─ etc/
│     │     │  ├─ default/grub                   🥾 Bootloader config
│     │     │  ├─ issue                          📋 Login banner
│     │     │  └─ xdg/openbox/rc.xml            🪟 Window manager config
│     │     └─ usr/
│     │        ├─ bin/custom-os-desktop          ▶️  Session starter
│     │        └─ share/xsessions/
│     │           └─ customos.desktop            🖥️  X session definition
│     │
│     ├─ 📦 PACKAGE LISTS
│     │  └─ package-lists/
│     │     └─ desktop.list.chroot               📋 Packages to install
│     │
│     └─ 💿 LOCAL PACKAGES (Created during build)
│        └─ packages.chroot/
│           └─ .gitkeep
│
└─ 📚 EXTENDED DOCS
   └─ docs/
      ├─ desktop-development.md    🛠️  Electron dev guide
      └─ troubleshooting.md        🔧 Common issues & fixes


╔══════════════════════════════════════════════════════════════════════╗
║                          WORKFLOW DIAGRAM                            ║
╚══════════════════════════════════════════════════════════════════════╝

1️⃣  DEVELOPMENT
   ┌─────────────────┐
   │  Edit desktop/  │ → npm start → Test in dev mode
   │  src/renderer/  │
   └─────────────────┘

2️⃣  BUILD DESKTOP
   ┌─────────────────┐
   │  npm run build  │ → Creates .deb package
   └─────────────────┘

3️⃣  BUILD ISO
   ┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
   │ sudo ./build.sh │ →   │ Downloads Ubuntu │ →   │ Installs    │
   │                 │     │ Base System      │     │ Packages +  │
   └─────────────────┘     └──────────────────┘     │ Desktop     │
                                                     └──────┬──────┘
                                                            │
   ┌─────────────────┐     ┌──────────────────┐           │
   │ custom-os.iso   │ ←   │ Creates Bootable │ ←─────────┘
   │ (1-2GB)         │     │ ISO Image        │
   └─────────────────┘     └──────────────────┘

4️⃣  TEST
   ┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
   │ ./test-iso.sh   │ →   │ Launches QEMU    │ →   │ Test in VM  │
   └─────────────────┘     └──────────────────┘     └─────────────┘

5️⃣  DEPLOY
   ┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
   │ git push        │ →   │ GitHub Actions   │ →   │ Download    │
   │                 │     │ Builds ISO       │     │ Artifact    │
   └─────────────────┘     └──────────────────┘     └─────────────┘


╔══════════════════════════════════════════════════════════════════════╗
║                     DESKTOP ARCHITECTURE                             ║
╚══════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────┐
│                      🖥️  WHAT YOU SEE                            │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ 🟦 [≡] CustomOS    [💻 50%] [🧠 60%] [🔋 95%]  12:34  [⚡] │  │
│  └────────────────────────────────────────────────────────────┘  │
│                          Top Panel                                │
└──────────────────────────────────────────────────────────────────┘
                                  │
                                  │ User Interaction
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│                    ⚡ ELECTRON DESKTOP                           │
│  ┌───────────────┐          ┌─────────────────────────────────┐ │
│  │  Renderer     │  IPC     │      Main Process               │ │
│  │  (UI Layer)   │ ◄──────► │   (System Integration)          │ │
│  │               │          │                                 │ │
│  │ • panel.html  │          │ • Window management             │ │
│  │ • launcher... │          │ • D-Bus communication           │ │
│  │ • styles.css  │          │ • Launch applications           │ │
│  └───────────────┘          │ • Gather system info            │ │
│                             └─────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
                                  │
                                  │ Window Management
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│                   🪟 OPENBOX (Window Manager)                    │
│  • Handles all application windows                               │
│  • Window positioning, resizing, focus                           │
│  • Alt+Tab, window decorations                                   │
└──────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│                      🖼️  X11 (Display Server)                    │
│  • Graphics rendering                                             │
│  • Input handling (keyboard, mouse)                              │
│  • Display management                                             │
└──────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│                   🐧 UBUNTU BASE SYSTEM                          │
│  • Linux kernel                                                   │
│  • systemd (init system)                                          │
│  • Drivers & hardware support                                     │
│  • Core utilities                                                 │
└──────────────────────────────────────────────────────────────────┘


╔══════════════════════════════════════════════════════════════════════╗
║                       KEY FILE PURPOSES                              ║
╚══════════════════════════════════════════════════════════════════════╝

📍 WHERE TO EDIT → WHAT IT DOES

🎨 APPEARANCE
   desktop/src/renderer/styles.css
   └─→ Colors, fonts, spacing, animations

🚀 APPLICATIONS
   desktop/src/renderer/launcher.js
   └─→ Add/remove apps in launcher, change icons

📊 PANEL FEATURES
   desktop/src/main/system.js
   └─→ Add new system indicators (network, disk, etc.)

📦 SOFTWARE PACKAGES
   config/package-lists/desktop.list.chroot
   └─→ Install additional programs (browsers, editors, etc.)

⚙️  SYSTEM CONFIG
   config/hooks/normal/*.hook.chroot
   └─→ System setup, user creation, service configuration

🪟 WINDOW BEHAVIOR
   config/includes.chroot/etc/xdg/openbox/rc.xml
   └─→ Keyboard shortcuts, window rules, workspaces

🥾 BOOT SETTINGS
   config/includes.chroot/etc/default/grub
   └─→ Boot parameters, timeout, background


╔══════════════════════════════════════════════════════════════════════╗
║                     QUICK START COMMANDS                             ║
╚══════════════════════════════════════════════════════════════════════╝

🛠️  SETUP (First Time - On Linux)
   chmod +x *.sh config/hooks/normal/*.hook.chroot
   ./setup.sh

⚡ TEST DESKTOP (Development)
   cd desktop
   npm start

🏗️  BUILD ISO (30-60 minutes)
   sudo ./build.sh

🧪 TEST ISO (QEMU)
   ./test-iso.sh

📤 PUSH TO GITHUB (Auto-build in cloud)
   git add .
   git commit -m "Initial commit"
   git push


╔══════════════════════════════════════════════════════════════════════╗
║                    CUSTOMIZATION QUICK WINS                          ║
╚══════════════════════════════════════════════════════════════════════╝

🎨 Change theme to dark purple:
   Edit: desktop/src/renderer/styles.css
   Change: --primary-color: #9b59b6;
           --background-dark: #2c2c2c;

🚀 Add VLC to launcher:
   Edit: desktop/src/renderer/launcher.js
   Add: {
     name: 'VLC',
     command: 'vlc',
     icon: '🎬',
     category: 'Multimedia'
   }

📦 Install GIMP image editor:
   Edit: config/package-lists/desktop.list.chroot
   Add: gimp

🔧 Auto-start application on login:
   Create: config/includes.chroot/etc/xdg/autostart/myapp.desktop


╔══════════════════════════════════════════════════════════════════════╗
║                         HELP & RESOURCES                             ║
╚══════════════════════════════════════════════════════════════════════╝

📖 Full guide           → GETTING-STARTED.md
⚡ Quick commands       → QUICK-REFERENCE.md
🛠️  Desktop development → docs/desktop-development.md
🔧 Troubleshooting     → docs/troubleshooting.md
🤝 Contributing        → CONTRIBUTING.md
🖥️  Build config       → config/README.md

💻 Important for Windows users → WINDOWS-NOTE.md


╔══════════════════════════════════════════════════════════════════════╗
║                            NEXT STEPS                                ║
╚══════════════════════════════════════════════════════════════════════╝

1️⃣  READ: GETTING-STARTED.md for detailed instructions

2️⃣  ON LINUX/WSL:
    chmod +x *.sh config/hooks/normal/*.hook.chroot
    ./setup.sh

3️⃣  TEST DESKTOP:
    cd desktop && npm start

4️⃣  BUILD ISO:
    sudo ./build.sh

5️⃣  TEST IN VM:
    ./test-iso.sh

6️⃣  CUSTOMIZE:
    Make it yours! Edit colors, add apps, change behavior

7️⃣  SHARE:
    git push → GitHub Actions builds automatically


╔══════════════════════════════════════════════════════════════════════╗
║                         PROJECT STATUS                               ║
╚══════════════════════════════════════════════════════════════════════╝

✅ Project Structure Created
✅ Electron Desktop Implemented
✅ Distribution Build System Ready
✅ CI/CD Pipeline Configured
✅ Documentation Complete
✅ Ready to Build!

🎉 IMPLEMENTATION COMPLETE! 🎉

Happy Hacking! 🚀
```
