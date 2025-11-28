#!/bin/bash

###############################################################################
# Mac Development Environment Setup Script
# Automated setup for macOS development environment with robust error handling
###############################################################################

# Continue on errors - individual command failures won't stop the script
set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for summary
PACKAGES_INSTALLED=0
PACKAGES_SKIPPED=0
PACKAGES_FAILED=0

# Get script directory for referencing files in the repo
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if script is run with sudo (we don't want that)
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this script with sudo"
    exit 1
fi

###############################################################################
# 1. Install Xcode Command Line Tools
###############################################################################
print_section "1. Xcode Command Line Tools"

if xcode-select -p &> /dev/null; then
    print_success "Xcode Command Line Tools already installed"
else
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete the Xcode installation and run this script again"
    exit 0
fi

###############################################################################
# 2. Install Homebrew
###############################################################################
print_section "2. Homebrew Package Manager"

if command -v brew &> /dev/null; then
    print_success "Homebrew already installed"
    print_info "Updating Homebrew..."
    if brew update 2>&1; then
        print_success "Homebrew updated successfully"
    else
        print_warning "Homebrew update had issues, but continuing..."
    fi
else
    print_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_error "Failed to install Homebrew. Please install manually and re-run this script."
        exit 1
    fi
fi

###############################################################################
# 3. Install Homebrew Formulae (CLI Tools)
###############################################################################
print_section "3. Homebrew Formulae (Command Line Tools)"

FORMULAE=(
    "git"
    "nvm"
    "uv"
    "wget"
    "yarn"
)

print_info "Installing formula packages..."
for formula in "${FORMULAE[@]}"; do
    if brew list --formula 2>/dev/null | grep -q "^${formula}$"; then
        print_success "Already installed: $formula"
        ((PACKAGES_SKIPPED++))
    else
        print_info "Installing: $formula"
        if brew install "$formula" 2>&1; then
            print_success "Installed: $formula"
            ((PACKAGES_INSTALLED++))
        else
            print_error "Failed to install: $formula (continuing anyway)"
            ((PACKAGES_FAILED++))
        fi
    fi
done

###############################################################################
# 4. Install Homebrew Casks (GUI Applications)
###############################################################################
print_section "4. Homebrew Casks (GUI Applications)"

CASKS=(
    "caffeine"
    "cursor"
    "discord"
    "docker"
    "flux"
    "ghostty"
    "google-chrome"
    "insomnia"
    "notion"
    "postgres-unofficial"
    "rectangle"
    "tableplus"
    "tor-browser"
    "visual-studio-code"
)

print_info "Installing cask applications..."
for cask in "${CASKS[@]}"; do
    if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
        print_success "Already installed: $cask"
        ((PACKAGES_SKIPPED++))
    else
        print_info "Installing: $cask"
        if brew install --cask "$cask" 2>&1; then
            print_success "Installed: $cask"
            ((PACKAGES_INSTALLED++))
        else
            print_error "Failed to install: $cask (continuing anyway)"
            ((PACKAGES_FAILED++))
        fi
    fi
done

###############################################################################
# 5. PostgreSQL Installation
###############################################################################
print_section "5. PostgreSQL Installation"

print_success "Postgres.app will be installed via the casks section"
print_info "Postgres.app provides a GUI for managing PostgreSQL databases"
print_info "Website: https://postgresapp.com/"

###############################################################################
# 6. Install Python via uv
###############################################################################
print_section "6. Python Installation (via uv)"

if command -v uv &> /dev/null; then
    print_success "uv is installed"
    
    # Check if Python is already installed via uv
    if uv python list 2>/dev/null | grep -q "cpython"; then
        print_success "Python already installed via uv"
        print_info "Installed Python versions:"
        uv python list 2>/dev/null | head -5 || true
    else
        # Install latest Python version
        print_info "Installing latest Python version via uv..."
        if uv python install 2>&1; then
            print_success "Python installed via uv"
            
            # Show installed Python versions
            print_info "Installed Python versions:"
            uv python list 2>/dev/null || true
        else
            print_warning "Failed to install Python via uv. You can install manually with: uv python install"
        fi
    fi
else
    print_warning "uv not available. Install it first with: brew install uv"
fi

###############################################################################
# 7. Install Node.js via NVM
###############################################################################
print_section "7. Node.js Installation (via NVM)"

# Create NVM directory
if [ ! -d "$HOME/.nvm" ]; then
    mkdir -p "$HOME/.nvm" 2>&1 && print_success "NVM directory created" || print_warning "Failed to create NVM directory"
else
    print_success "NVM directory already exists"
fi

# Source NVM for current session
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" 2>/dev/null

# Install latest LTS Node.js version
if command -v nvm &> /dev/null; then
    # Check if Node.js is already installed
    if nvm ls 2>/dev/null | grep -q "node\|v[0-9]"; then
        print_success "Node.js already installed via nvm"
        CURRENT_NODE=$(nvm current 2>/dev/null)
        print_info "Current Node.js version: $CURRENT_NODE"
        print_info "To install another version: nvm install --lts"
    else
        print_info "Installing Node.js LTS version..."
        if nvm install --lts 2>&1 && nvm use --lts 2>&1; then
            print_success "Node.js LTS installed"
        else
            print_warning "Failed to install Node.js. Run 'nvm install --lts' manually after restarting terminal."
        fi
    fi
else
    print_warning "NVM not available in current session. Restart terminal and run: nvm install --lts"
fi

###############################################################################
# 8. Configure VS Code Extensions and Settings
###############################################################################
print_section "8. VS Code Extensions and Settings"

# Path to extension list and settings files in the repo
VSCODE_EXTENSIONS_FILE="$SCRIPT_DIR/vscode-extensions.txt"
VSCODE_SETTINGS_FILE="$SCRIPT_DIR/vscode-global-settings.json"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

# Check if VS Code is installed
if command -v code &> /dev/null || [ -d "/Applications/Visual Studio Code.app" ]; then
    print_success "VS Code is installed"
    
    # Install extensions (only if VS Code CLI is available)
    if command -v code &> /dev/null; then
        if [ -f "$VSCODE_EXTENSIONS_FILE" ]; then
            print_info "Installing VS Code extensions..."
            VSCODE_EXT_INSTALLED=0
            VSCODE_EXT_FAILED=0
            
            while IFS= read -r extension || [ -n "$extension" ]; do
                # Skip empty lines
                [ -z "$extension" ] && continue
                
                # Check if extension is already installed
                if code --list-extensions 2>/dev/null | grep -q "^${extension}$"; then
                    print_success "Extension already installed: $extension"
                else
                    print_info "Installing extension: $extension"
                    if code --install-extension "$extension" --force 2>&1; then
                        print_success "Installed extension: $extension"
                        ((VSCODE_EXT_INSTALLED++))
                    else
                        print_error "Failed to install extension: $extension"
                        ((VSCODE_EXT_FAILED++))
                    fi
                fi
            done < "$VSCODE_EXTENSIONS_FILE"
            
            [ $VSCODE_EXT_INSTALLED -gt 0 ] && print_success "Installed $VSCODE_EXT_INSTALLED new VS Code extension(s)"
            [ $VSCODE_EXT_FAILED -gt 0 ] && print_warning "Failed to install $VSCODE_EXT_FAILED VS Code extension(s)"
        else
            print_warning "vscode-extensions.txt not found in repository"
            print_info "To export extensions: code --list-extensions > vscode-extensions.txt"
        fi
    else
        print_warning "VS Code CLI not found. Skipping extension installation."
    fi
    
    # Restore settings
    if [ -f "$VSCODE_SETTINGS_FILE" ]; then
        # Create VS Code User directory if it doesn't exist
        mkdir -p "$VSCODE_USER_DIR" 2>/dev/null
        
        # Backup existing settings if they exist
        if [ -f "$VSCODE_USER_DIR/settings.json" ]; then
            BACKUP_FILE="$VSCODE_USER_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backing up existing VS Code settings to: ${BACKUP_FILE##*/}"
            cp "$VSCODE_USER_DIR/settings.json" "$BACKUP_FILE" 2>/dev/null
        fi
        
        print_info "Restoring VS Code settings..."
        if cp "$VSCODE_SETTINGS_FILE" "$VSCODE_USER_DIR/settings.json" 2>&1; then
            print_success "VS Code settings restored"
        else
            print_error "Failed to restore VS Code settings"
        fi
    else
        print_warning "vscode-global-settings.json not found in repository"
    fi
else
    print_warning "VS Code not installed yet. Extensions and settings will be skipped."
fi

###############################################################################
# 8b. Import VS Code Extensions and Settings to Cursor
###############################################################################
print_section "8b. Import to Cursor (from VS Code config)"

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

# Check if Cursor is installed
if command -v cursor &> /dev/null || [ -d "/Applications/Cursor.app" ]; then
    print_success "Cursor is installed"
    
    # Install same extensions in Cursor (only if Cursor CLI is available)
    if command -v cursor &> /dev/null; then
        if [ -f "$VSCODE_EXTENSIONS_FILE" ]; then
            print_info "Installing extensions in Cursor (same as VS Code)..."
            CURSOR_EXT_INSTALLED=0
            CURSOR_EXT_FAILED=0
            
            while IFS= read -r extension || [ -n "$extension" ]; do
                # Skip empty lines
                [ -z "$extension" ] && continue
                
                # Check if extension is already installed
                if cursor --list-extensions 2>/dev/null | grep -q "^${extension}$"; then
                    print_success "Extension already installed: $extension"
                else
                    print_info "Installing extension: $extension"
                    if cursor --install-extension "$extension" --force 2>&1; then
                        print_success "Installed extension: $extension"
                        ((CURSOR_EXT_INSTALLED++))
                    else
                        print_error "Failed to install extension: $extension"
                        ((CURSOR_EXT_FAILED++))
                    fi
                fi
            done < "$VSCODE_EXTENSIONS_FILE"
            
            [ $CURSOR_EXT_INSTALLED -gt 0 ] && print_success "Installed $CURSOR_EXT_INSTALLED new Cursor extension(s)"
            [ $CURSOR_EXT_FAILED -gt 0 ] && print_warning "Failed to install $CURSOR_EXT_FAILED Cursor extension(s)"
        else
            print_warning "vscode-extensions.txt not found - cannot import extensions to Cursor"
        fi
    else
        print_warning "Cursor CLI not found. Skipping extension installation."
    fi
    
    # Copy settings to Cursor (same as VS Code)
    if [ -f "$VSCODE_SETTINGS_FILE" ]; then
        # Create Cursor User directory if it doesn't exist
        mkdir -p "$CURSOR_USER_DIR" 2>/dev/null
        
        # Backup existing settings if they exist
        if [ -f "$CURSOR_USER_DIR/settings.json" ]; then
            BACKUP_FILE="$CURSOR_USER_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backing up existing Cursor settings to: ${BACKUP_FILE##*/}"
            cp "$CURSOR_USER_DIR/settings.json" "$BACKUP_FILE" 2>/dev/null
        fi
        
        print_info "Importing VS Code settings to Cursor..."
        if cp "$VSCODE_SETTINGS_FILE" "$CURSOR_USER_DIR/settings.json" 2>&1; then
            print_success "Cursor settings imported from VS Code config"
        else
            print_error "Failed to import settings to Cursor"
        fi
    else
        print_warning "vscode-global-settings.json not found - cannot import settings to Cursor"
    fi
else
    print_warning "Cursor not installed yet. Import will be skipped."
    print_info "Run this script again after Cursor is installed to import settings."
fi

###############################################################################
# 9. Configure Ghostty Terminal
###############################################################################
print_section "9. Ghostty Terminal Configuration"

GHOSTTY_CONFIG_FILE="$SCRIPT_DIR/ghostty-config"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"

# Check if Ghostty is installed
if [ -d "/Applications/Ghostty.app" ]; then
    print_success "Ghostty is installed"
    
    # Restore config
    if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
        # Create Ghostty config directory if it doesn't exist
        mkdir -p "$GHOSTTY_CONFIG_DIR" 2>/dev/null
        
        # Backup existing config if it exists
        if [ -f "$GHOSTTY_CONFIG_DIR/config" ]; then
            if cmp -s "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_DIR/config" 2>/dev/null; then
                print_success "Ghostty config already matches template"
            else
                BACKUP_FILE="$GHOSTTY_CONFIG_DIR/config.backup.$(date +%Y%m%d_%H%M%S)"
                print_info "Backing up existing Ghostty config to: ${BACKUP_FILE##*/}"
                cp "$GHOSTTY_CONFIG_DIR/config" "$BACKUP_FILE" 2>/dev/null
                
                print_info "Restoring Ghostty config..."
                if cp "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_DIR/config" 2>&1; then
                    print_success "Ghostty config restored"
                else
                    print_error "Failed to restore Ghostty config"
                fi
            fi
        else
            print_info "Installing Ghostty config..."
            if cp "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_DIR/config" 2>&1; then
                print_success "Ghostty config installed"
            else
                print_error "Failed to install Ghostty config"
            fi
        fi
    else
        print_warning "ghostty-config not found in repository"
    fi
else
    print_warning "Ghostty not installed yet. Config will be skipped."
    print_info "Run this script again after Ghostty is installed to configure it."
fi

###############################################################################
# 10. Configure Git
###############################################################################
print_section "10. Git Configuration"

print_info "Current Git configuration:"
git config --global user.name 2>/dev/null || print_warning "Git user.name not set"
git config --global user.email 2>/dev/null || print_warning "Git user.email not set"

echo ""
print_warning "To configure Git, run:"
echo "  git config --global user.name \"Your Name\""
echo "  git config --global user.email \"your.email@example.com\""

###############################################################################
# 11. macOS System Preferences
###############################################################################
print_section "11. macOS System Preferences"

print_info "Configuring macOS system preferences..."

# Finder settings
defaults write com.apple.finder AppleShowAllFiles -bool true 2>/dev/null
defaults write com.apple.finder ShowPathbar -bool true 2>/dev/null
defaults write com.apple.finder ShowStatusBar -bool true 2>/dev/null

# Disable app quarantine dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false 2>/dev/null

# Keyboard settings
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 2>/dev/null
defaults write NSGlobalDomain KeyRepeat -int 2 2>/dev/null
defaults write NSGlobalDomain InitialKeyRepeat -int 15 2>/dev/null
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false 2>/dev/null

# Screenshot settings
defaults write com.apple.screencapture location -string "${HOME}/Downloads" 2>/dev/null
defaults write com.apple.screencapture type -string "png" 2>/dev/null

print_success "macOS preferences configured"
print_warning "Some changes require restarting Finder: killall Finder"

###############################################################################
# 12. Cleanup and Final Steps
###############################################################################
print_section "12. Cleanup"

print_info "Running Homebrew cleanup..."
if brew cleanup 2>&1; then
    print_success "Homebrew cleanup completed"
else
    print_warning "Homebrew cleanup had issues, but continuing..."
fi

print_info "Running Homebrew diagnostics..."
if brew doctor 2>&1; then
    print_success "Homebrew diagnostics passed"
else
    print_warning "Homebrew diagnostics found some issues (this is often normal)"
fi

###############################################################################
# Summary
###############################################################################
print_section "Setup Complete!"

echo ""
print_success "Your Mac development environment is now set up!"
echo ""

# Installation summary
echo "Installation Summary:"
[ $PACKAGES_INSTALLED -gt 0 ] && print_success "Packages installed: $PACKAGES_INSTALLED"
[ $PACKAGES_SKIPPED -gt 0 ] && print_info "Packages skipped (already installed): $PACKAGES_SKIPPED"
[ $PACKAGES_FAILED -gt 0 ] && print_warning "Packages failed: $PACKAGES_FAILED"

echo ""
echo "Installed versions:"
echo "  • Homebrew:    $(brew --version 2>/dev/null | head -n 1 || echo 'Not available')"
echo "  • Git:         $(git --version 2>/dev/null || echo 'Not available')"
echo "  • uv:          $(uv --version 2>/dev/null || echo 'Not available')"
echo "  • Python:      $(uv python list 2>/dev/null | grep -m1 'cpython' | awk '{print $1}' || echo 'Managed by uv')"
echo "  • NVM:         $(nvm --version 2>/dev/null || echo 'Not available')"
echo "  • Node.js:     $(node --version 2>/dev/null || echo 'Managed by nvm')"
echo "  • Zsh:         $(zsh --version 2>/dev/null || echo 'Not available')"
echo ""
print_warning "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Configure Git: git config --global user.name/user.email"
echo "  3. Restart Finder: killall Finder"
echo ""
print_info "Python managed by uv - use: uv python install <version>"
print_info "Node.js managed by nvm - already installed LTS version"
echo ""
print_info "To update all packages: brew update && brew upgrade && brew cleanup"
echo ""

[ $PACKAGES_FAILED -gt 0 ] && print_warning "Some packages failed. Check output above for details." && echo ""

print_success "Happy coding! 🚀"

