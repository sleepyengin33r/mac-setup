# Mac Setup

Automated macOS development environment setup.

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

## What It Does

- Installs Homebrew packages from `Brewfile`
- Sets up Python (uv) and Node.js (nvm)
- Configures VS Code, Cursor, and Ghostty
- Applies zsh config with autosuggestions + syntax highlighting
- Sets macOS developer preferences

## Packages

**CLI:** git, nvm, uv, wget, yarn, zsh-autosuggestions, zsh-syntax-highlighting

**Apps:** Chrome, Tor Browser, Cursor, VS Code, Docker, Ghostty, Insomnia, Postgres.app, TablePlus, Caffeine, Flux, Notion, Rectangle, Discord

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | Main setup script |
| `Brewfile` | Homebrew packages |
| `zshrc-template` | Zsh configuration |
| `ghostty-config` | Terminal config (Dracula theme) |
| `vscode-settings.json` | Editor settings |
| `vscode-extensions.txt` | Editor extensions |

## Post-Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Quick Reference

```bash
# Update all
brew update && brew upgrade && brew cleanup

# Python
uv python install 3.12

# Node.js
nvm install --lts
```
