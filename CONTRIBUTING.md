# Contributing to CustomOS

Thank you for your interest in contributing to CustomOS! This is a hobby/learning project, and all contributions are welcome.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](../../issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, hardware)
   - Log files (if applicable)

### Suggesting Features

1. Check existing issues to avoid duplicates
2. Create a new issue with:
   - Clear description of the feature
   - Use case / motivation
   - Possible implementation approach (optional)

### Code Contributions

1. **Fork** the repository
2. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/awesome-feature
   ```
3. **Make your changes**
4. **Test** your changes:
   ```bash
   # Test desktop
   cd desktop && npm start
   
   # Build and test ISO
   sudo ./build.sh
   ./test-iso.sh
   ```
5. **Commit** with clear messages:
   ```bash
   git commit -m "Add network indicator to panel"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/awesome-feature
   ```
7. **Create a Pull Request** with:
   - Description of changes
   - Before/after screenshots (if UI change)
   - Testing performed

## Development Guidelines

### Code Style

**JavaScript/Node.js:**
- Use 2 spaces for indentation
- Use semicolons
- Use `const` and `let`, not `var`
- Use arrow functions for callbacks
- Add JSDoc comments for functions

**Shell Scripts:**
- Use `#!/bin/bash` shebang
- Quote variables: `"$variable"`
- Use `set -e` to exit on errors
- Add comments for complex logic

**HTML/CSS:**
- Use semantic HTML5
- Keep CSS organized by component
- Use CSS custom properties (variables)
- Mobile-first approach (if applicable)

### Commit Messages

Follow conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

Examples:
```
feat: add battery indicator to panel
fix: launcher not closing on app launch
docs: update installation instructions
refactor: simplify system info gathering
```

### Testing

Before submitting PR:

1. **Desktop Testing:**
   ```bash
   cd desktop
   npm start
   # Test all features manually
   ```

2. **Build Testing:**
   ```bash
   sudo ./build.sh
   # Verify ISO is created
   ```

3. **ISO Testing:**
   ```bash
   ./test-iso.sh
   # Boot and test in VM
   ```

4. **Check for errors:**
   - No console errors in DevTools
   - No build warnings
   - Scripts run without errors

### Documentation

Update documentation when:
- Adding new features
- Changing configuration
- Modifying build process
- Adding dependencies

Affected files:
- `README.md` - Main documentation
- `GETTING-STARTED.md` - Beginner guide
- `docs/desktop-development.md` - Desktop dev guide
- `docs/troubleshooting.md` - Common issues
- `config/README.md` - Build config

## Project Structure

```
distro/
├── .github/workflows/     # CI/CD
├── config/               # Live-build config
│   ├── hooks/           # Build hooks
│   ├── includes.chroot/ # Files for ISO
│   └── package-lists/   # Package selections
├── desktop/             # Electron desktop
│   ├── src/main/       # Node.js backend
│   └── src/renderer/   # UI frontend
├── docs/               # Documentation
├── build.sh            # Main build script
├── setup.sh            # Setup script
└── test-iso.sh         # Test script
```

## Areas for Contribution

### Easy (Good First Issues)

- Add more applications to launcher
- Improve UI styling / themes
- Add icons for applications
- Update documentation
- Fix typos
- Add comments to code

### Medium

- Add system notifications
- Implement settings panel
- Add workspace switcher
- Network manager GUI
- Volume control widget
- Improve error handling

### Hard

- Multi-monitor support
- Custom window decorations
- Wayland support
- Custom installer integration
- Automatic updates system
- Custom package repository

### Desktop Development

**Add a new panel widget:**
1. Update `system.js` to gather data
2. Add HTML in `panel.html`
3. Add styling in `styles.css`
4. Add update logic in `panel.js`

**Add a new window:**
1. Create HTML/JS in `renderer/`
2. Create window in `main/index.js`
3. Add IPC handlers
4. Expose via preload.js

### Distribution Development

**Add packages:**
1. Edit `config/package-lists/desktop.list.chroot`
2. Rebuild ISO
3. Test in VM

**System configuration:**
1. Add hook in `config/hooks/normal/`
2. Ensure it's executable
3. Test build

**Add files to ISO:**
1. Place in `config/includes.chroot/`
2. Maintain directory structure
3. Rebuild ISO

## Release Process

Releases are created when:
1. Significant features added
2. Major bugs fixed
3. Version milestones reached

### Version Numbering

We use Semantic Versioning (SemVer):
- `MAJOR.MINOR.PATCH`
- `1.0.0` - First stable release
- `1.1.0` - New features
- `1.1.1` - Bug fixes

### Creating a Release

1. Update version in:
   - `desktop/package.json`
   - `README.md`
2. Commit changes
3. Create and push tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```
4. GitHub Actions will build and attach ISO to release

## Community

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help newcomers
- Assume good intentions
- No harassment or trolling

### Getting Help

**Before asking:**
1. Read documentation
2. Search existing issues
3. Check troubleshooting guide

**When asking:**
1. Provide context
2. Show what you've tried
3. Include error messages
4. Share relevant logs
5. Describe expected behavior

### Communication

- **GitHub Issues**: Bug reports, feature requests
- **Pull Requests**: Code contributions, reviews
- **Discussions**: General questions, ideas

## Learning Resources

New to Linux distro building or Electron?

**Linux Distros:**
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/)
- [Linux From Scratch](http://www.linuxfromscratch.org/)
- [Ubuntu Community Help](https://help.ubuntu.com/)

**Electron:**
- [Electron Official Docs](https://www.electronjs.org/docs)
- [Electron Tutorial](https://www.electronjs.org/docs/latest/tutorial/tutorial-prerequisites)
- [Awesome Electron](https://github.com/sindresorhus/awesome-electron)

**JavaScript:**
- [MDN Web Docs](https://developer.mozilla.org/)
- [Node.js Documentation](https://nodejs.org/docs/)

## Recognition

Contributors will be:
- Listed in README.md
- Credited in release notes
- Appreciated forever! 💙

## Questions?

Feel free to:
- Open a discussion
- Ask in issues
- Tag maintainers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to CustomOS! 🚀

Every contribution, no matter how small, makes a difference.
