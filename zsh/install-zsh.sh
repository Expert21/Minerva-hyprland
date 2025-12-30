#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                     Oh-My-Zsh + Plugins Installation Script                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -e

# Colors for output
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
}

print_step() {
    echo -e "${CYAN}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_header "Oh-My-Zsh Installation for Obsidian Arcana"

# ═══════════════════════════════════════════════════════════════════════════════
# Check if zsh is installed
# ═══════════════════════════════════════════════════════════════════════════════

if ! command -v zsh &> /dev/null; then
    print_step "Installing zsh..."
    sudo pacman -S --noconfirm zsh
    print_success "Zsh installed"
else
    print_success "Zsh is already installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Install oh-my-zsh
# ═══════════════════════════════════════════════════════════════════════════════

if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh-My-Zsh is already installed"
else
    print_step "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-My-Zsh installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Install zsh-autosuggestions plugin
# ═══════════════════════════════════════════════════════════════════════════════

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions is already installed"
else
    print_step "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Install zsh-syntax-highlighting plugin
# ═══════════════════════════════════════════════════════════════════════════════

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting is already installed"
else
    print_step "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Optional: Install fzf for fuzzy finding
# ═══════════════════════════════════════════════════════════════════════════════

if command -v fzf &> /dev/null; then
    print_success "fzf is already installed"
else
    print_step "Installing fzf for fuzzy finding (optional but recommended)..."
    sudo pacman -S --noconfirm fzf
    print_success "fzf installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Optional: Install Powerline fonts (needed for agnoster theme)
# ═══════════════════════════════════════════════════════════════════════════════

print_step "Checking for Powerline fonts..."
if fc-list | grep -qi "powerline\|nerd"; then
    print_success "Powerline/Nerd fonts detected"
else
    print_step "Installing Nerd Fonts (JetBrains Mono)..."
    if command -v yay &> /dev/null; then
        yay -S --noconfirm ttf-jetbrains-mono-nerd
    else
        sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd 2>/dev/null || {
            print_error "Could not install Nerd Fonts automatically"
            echo "Please install a Nerd Font manually from: https://www.nerdfonts.com/"
        }
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Deploy the .zshrc config
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SRC="$SCRIPT_DIR/.zshrc"

if [ -f "$ZSHRC_SRC" ]; then
    print_step "Deploying .zshrc configuration..."
    
    # Backup existing .zshrc if it exists and isn't a symlink
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Backed up existing .zshrc"
    fi
    
    # Create symlink
    ln -sf "$ZSHRC_SRC" "$HOME/.zshrc"
    print_success ".zshrc symlinked to rice config"
else
    print_error ".zshrc not found in script directory"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Set zsh as default shell
# ═══════════════════════════════════════════════════════════════════════════════

if [ "$SHELL" = "$(which zsh)" ]; then
    print_success "Zsh is already the default shell"
else
    print_step "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Zsh set as default shell (re-login required)"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Done!
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
print_header "Installation Complete!"
echo ""
echo -e "${CYAN}Your zsh configuration includes:${NC}"
echo "  • Oh-My-Zsh framework"
echo "  • zsh-autosuggestions (Fish-like suggestions)"
echo "  • zsh-syntax-highlighting (Command highlighting)"
echo "  • fzf integration (Ctrl+R for fuzzy history)"
echo "  • Agnoster theme with Powerline symbols"
echo "  • Custom completions and keybindings"
echo ""
echo -e "${PURPLE}To start using zsh now, run: ${GREEN}zsh${NC}"
echo -e "${PURPLE}Or log out and log back in for the changes to take effect.${NC}"
echo ""
