# Mac Development Environment Setup

Automated setup script for macOS development environment with standardized configuration.

## 📋 What's Included

### Command Line Tools
- Git, NVM, uv (Python version & package manager), Wget, Yarn
- Powerlevel10k theme
- Zsh plugins (autosuggestions, completions, syntax highlighting)
- **Python:** Managed by uv (installs latest version automatically)
- **Node.js:** Managed by nvm (installs LTS version automatically)

### GUI Applications
- **Browsers:** Chrome, Tor Browser
- **Editors:** Cursor, Visual Studio Code
- **Productivity:** Caffeine, Flow (Pomodoro timer), Flux, Notion, Raycast, Rectangle
- **Development:** Docker, Insomnia (API client), iTerm2, pgAdmin 4, Postgres.app, TablePlus
- **Font:** MesloLGS NF (Nerd Font)
- **Communication:** Discord

### Configuration
- Oh My Zsh with standardized `.zshrc` template
- Powerlevel10k config template (`p10k.zsh`) enforced to `~/.p10k.zsh` (with backup)
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
omz update
nvm install --lts --latest-npm
```

## 🔧 Post-Installation

After setup completes, configure these manually:

```bash
# Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Powerlevel10k theme (restart terminal, follow wizard)
p10k configure
```

**Note:** Python and Node.js LTS are automatically installed during setup via `uv` and `nvm`.

### iTerm2 Font
- Preferences → Profiles → Text → Font: "MesloLGS NF"

### Shell Customization
- Your existing `.zshrc` is backed up to `~/.zshrc.backup.TIMESTAMP`
- Add personal configs to the bottom of `~/.zshrc` (under "Personal Customizations")
- `~/.p10k.zsh` is kept identical to the repo template `p10k.zsh`.
  Your existing file is backed up to `~/.p10k.zsh.backup.TIMESTAMP` before overwrite.

### Cursor IDE Configuration
- Extensions are installed from `cursor-extensions.txt` when the `cursor` CLI is available
- Settings and keybindings are restored from backup files
- Existing configurations are backed up before restoration

Note: The setup script adds required Homebrew taps, including `homebrew/cask-fonts` for fonts and `postgres-unofficial/postgres-unofficial` for Postgres.app (unofficial), to ensure all casks and formulae resolve.

## ✨ Features

- Idempotent (safe to run multiple times)
- Standardized `.zshrc` across all installations
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

### Update Powerlevel10k Configuration
```bash
# Configure Powerlevel10k (generates ~/.p10k.zsh)
p10k configure

# Save your config back into the repo template
cp ~/.p10k.zsh p10k.zsh
git add p10k.zsh
git commit -m "Update p10k config"
```

Note: The setup script will overwrite `~/.p10k.zsh` to ensure consistency across machines (after creating a timestamped backup).

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

- [Homebrew](https://docs.brew.sh/) • [Oh My Zsh](https://ohmyz.sh/) • [NVM](https://github.com/nvm-sh/nvm) • [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

---

💡 **Tip:** Commit changes to track your environment over time!

