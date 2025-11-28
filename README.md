# Mac Development Environment Setup

Automated setup script for macOS development environment with standardized configuration.

## 📋 What's Included

### Command Line Tools
- Git, NVM, uv (Python version & package manager), Wget, Yarn
- **Python:** Managed by uv (installs latest version automatically)
- **Node.js:** Managed by nvm (installs LTS version automatically)

### GUI Applications
- **Browsers:** Chrome, Tor Browser
- **Editors:** Cursor, Visual Studio Code
- **Productivity:** Caffeine, Flow (Pomodoro timer), Flux, Notion, Rectangle
- **Development:** Docker, Ghostty, Insomnia (API client), Postgres.app, TablePlus
- **Communication:** Discord

### Configuration
- Ghostty terminal config (`ghostty-config`) with Dracula theme
- NVM for Node.js version management
- Cursor extensions and settings backup/restore
- Developer-friendly macOS system settings
- Automatic backups of existing configurations

## 🚀 Usage

### Initial Setup
```bash
cd ~/Desktop
git clone <your-repo-url> mac-setup
cd mac-setup
chmod +x mac_setup.sh
./mac_setup.sh
```

### Update Everything
```bash
brew update && brew upgrade && brew cleanup
nvm install --lts --latest-npm
```

## 🔧 Post-Installation

After setup completes, configure these manually:

```bash
# Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Note:** Python and Node.js LTS are automatically installed during setup via `uv` and `nvm`.

### Cursor IDE Configuration
- Extensions are installed from `cursor-extensions.txt` when the `cursor` CLI is available
- Settings and keybindings are restored from backup files
- Existing configurations are backed up before restoration

## ✨ Features

- Idempotent (safe to run multiple times)
- Automatic backups before changes
- Robust error handling (continues on failures)
- Skips already installed packages
- Color-coded progress output
- Installation summary report

## 📦 Managing Packages

### Add New Software
```bash
# Find package
brew search <package-name>

# Edit mac_setup.sh: add to FORMULAE (CLI) or CASKS (GUI)
# Then commit
git add mac_setup.sh
git commit -m "Add <package-name>"
```

### Update Cursor Configuration
```bash
# Export current extensions
cursor --list-extensions > cursor-extensions.txt

# Backup current settings
cp "$HOME/Library/Application Support/Cursor/User/settings.json" cursor-settings.json
cp "$HOME/Library/Application Support/Cursor/User/keybindings.json" cursor-keybindings.json

# Commit changes
git add cursor-*.txt cursor-*.json
git commit -m "Update Cursor configuration"
```

### Remove Software
```bash
brew uninstall <formula-name>              # CLI tool
brew uninstall --cask <cask-name>          # GUI app
brew autoremove                             # Remove unused dependencies
```

### Check Installed
```bash
brew list --formula    # CLI tools
brew list --cask       # GUI apps
uv python list        # Python versions
nvm list              # Node.js versions
```

## 🐍 Python & Node Version Management

### Python (via uv)
```bash
# List available Python versions
uv python list --all-versions

# Install specific Python version
uv python install 3.12

# Install latest Python
uv python install

# Create project with specific Python
uv init my-project --python 3.12

# Install packages
uv pip install requests pandas numpy
```

### Node.js (via nvm)
```bash
# List available Node versions
nvm ls-remote

# Install specific version
nvm install 20.10.0

# Install latest LTS
nvm install --lts

# Use specific version
nvm use 20

# Set default version
nvm alias default node
```

## 🐛 Troubleshooting

```bash
# Homebrew issues
brew doctor

# Permission issues
sudo chown -R $(whoami) $(brew --prefix)/*

# Shell issues
source ~/.zshrc      # Reload config
exec zsh             # Restart shell

# Failed package
brew install --verbose <package-name>
```

## 📚 Resources

- [Homebrew](https://docs.brew.sh/) • [NVM](https://github.com/nvm-sh/nvm) • [uv](https://github.com/astral-sh/uv) • [Ghostty](https://ghostty.org/)

---

💡 **Tip:** Commit changes to track your environment over time!
