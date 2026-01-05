#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║              CONFIG DEPLOYER - DUAL MODE RICE                              ║
# ║                    Obsidian Arcana + Ghost Mode                            ║
# ║                    Using Quickshell (no waybar)                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

set -e

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                      DUAL MODE - CONFIG DEPLOYER                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
HYPR_DIR="$CONFIG_DIR/hypr"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helper function to safely copy files/directories
safe_copy() {
    local src="$1"
    local dest="$2"
    local is_dir="${3:-false}"
    
    if [ "$is_dir" = "true" ]; then
        if [ -d "$src" ]; then
            mkdir -p "$dest"
            cp -r "$src"/* "$dest/" 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Deployed $(basename "$src")/"
        else
            echo -e "  ${YELLOW}⚠${NC} Skipped $(basename "$src")/ (not found)"
        fi
    else
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dest")"
            cp "$src" "$dest"
            echo -e "  ${GREEN}✓${NC} Deployed $(basename "$src")"
        else
            echo -e "  ${YELLOW}⚠${NC} Skipped $(basename "$src") (not found)"
        fi
    fi
}

# Helper function to create safe symlinks
safe_symlink() {
    local src="$1"
    local dest="$2"
    
    rm -rf "$dest"
    if [ -e "$src" ]; then
        ln -sf "$src" "$dest"
        echo -e "  ${GREEN}✓${NC} Linked $(basename "$dest") -> $(basename "$src")"
    else
        echo -e "  ${YELLOW}⚠${NC} Failed to link $(basename "$dest") (source not found)"
    fi
}

# Configs to backup/deploy
CONFIGS=(
    "hypr"
    "kitty"
    "rofi"
    "dunst"
    "btop"
    "ranger"
    "micro"
    "ekphos"
)

# ─────────────────────────────────────────────────────────────────────────────
# BACKUP PHASE
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}Checking for existing configs to backup...${NC}"
NEEDS_BACKUP=false
for config in "${CONFIGS[@]}"; do
    if [ -e "$CONFIG_DIR/$config" ]; then
        NEEDS_BACKUP=true
        break
    fi
done

if [ "$NEEDS_BACKUP" = true ]; then
    echo -e "${YELLOW}Creating backup at $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    for config in "${CONFIGS[@]}"; do
        if [ -e "$CONFIG_DIR/$config" ]; then
            echo "  Backing up $config..."
            cp -r "$CONFIG_DIR/$config" "$BACKUP_DIR/"
        fi
    done
    echo -e "${GREEN}Backup complete!${NC}"
    echo ""
fi

# ─────────────────────────────────────────────────────────────────────────────
# DIRECTORY STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Setting up directory structure...${NC}"
mkdir -p "$HYPR_DIR/themes/arcana/rofi"
mkdir -p "$HYPR_DIR/themes/arcana/dunst"

mkdir -p "$HYPR_DIR/scripts"
mkdir -p "$HYPR_DIR/wallpapers"
echo -e "${GREEN}✓ Directory structure created${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY BASE HYPRLAND CONFIG
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying base Hyprland config...${NC}"
safe_copy "$SCRIPT_DIR/hypr/hyprland.conf" "$HYPR_DIR/hyprland-base.conf"
safe_copy "$SCRIPT_DIR/hypr/hypridle.conf" "$HYPR_DIR/hypridle.conf"
safe_copy "$SCRIPT_DIR/hypr/hyprlock.conf" "$HYPR_DIR/hyprlock-base.conf"
echo ""



# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY ARCANA THEME
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying Arcana theme...${NC}"
ARCANA_SRC="$SCRIPT_DIR/themes/arcana"
ARCANA_DEST="$HYPR_DIR/themes/arcana"

safe_copy "$ARCANA_SRC/hyprland.conf" "$ARCANA_DEST/hyprland.conf"
safe_copy "$ARCANA_SRC/kitty.conf" "$ARCANA_DEST/kitty.conf"
safe_copy "$ARCANA_SRC/hyprlock.conf" "$ARCANA_DEST/hyprlock.conf"
safe_copy "$ARCANA_SRC/rofi" "$ARCANA_DEST/rofi" true
safe_copy "$ARCANA_SRC/dunst" "$ARCANA_DEST/dunst" true

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY GHOST THEME
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${CYAN}Deploying Ghost Mode theme...${NC}"
GHOST_SRC="$SCRIPT_DIR/themes/ghost"
GHOST_DEST="$HYPR_DIR/themes/ghost"

safe_copy "$GHOST_SRC/hyprland.conf" "$GHOST_DEST/hyprland.conf"
safe_copy "$GHOST_SRC/kitty.conf" "$GHOST_DEST/kitty.conf"
safe_copy "$GHOST_SRC/hyprlock.conf" "$GHOST_DEST/hyprlock.conf"
safe_copy "$GHOST_SRC/rofi" "$GHOST_DEST/rofi" true
safe_copy "$GHOST_SRC/dunst" "$GHOST_DEST/dunst" true

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY ALL SCRIPTS
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying scripts...${NC}"
SCRIPTS_SRC="$SCRIPT_DIR/scripts"

# Deploy all .sh files from scripts directory
if [ -d "$SCRIPTS_SRC" ]; then
    for script in "$SCRIPTS_SRC"/*.sh; do
        if [ -f "$script" ]; then
            safe_copy "$script" "$HYPR_DIR/scripts/$(basename "$script")"
        fi
    done
    # Make all scripts executable
    chmod +x "$HYPR_DIR/scripts/"*.sh 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Made all scripts executable"
else
    echo -e "  ${RED}✗${NC} Scripts directory not found!"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY WALLPAPERS
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying wallpapers...${NC}"
if [ -d "$SCRIPT_DIR/wallpapers" ] && [ "$(ls -A "$SCRIPT_DIR/wallpapers" 2>/dev/null)" ]; then
    for wallpaper in "$SCRIPT_DIR/wallpapers"/*; do
        if [ -f "$wallpaper" ]; then
            safe_copy "$wallpaper" "$HYPR_DIR/wallpapers/$(basename "$wallpaper")"
        fi
    done
else
    echo -e "  ${YELLOW}⚠${NC} No wallpapers found in source directory"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SET DEFAULT MODE
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Setting up default mode (Arcana)...${NC}"
echo "arcana" > "$HYPR_DIR/.current-mode"

# Create initial symlink for hyprland.conf
safe_symlink "$HYPR_DIR/themes/arcana/hyprland.conf" "$HYPR_DIR/hyprland.conf"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY INITIAL ACTIVE CONFIGS (ARCANA)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Setting up active config symlinks (Arcana mode)...${NC}"

# Kitty
rm -rf "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/kitty"
safe_symlink "$HYPR_DIR/themes/arcana/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"

# Rofi
rm -rf "$CONFIG_DIR/rofi"
safe_symlink "$HYPR_DIR/themes/arcana/rofi" "$CONFIG_DIR/rofi"

# Dunst
rm -rf "$CONFIG_DIR/dunst"
safe_symlink "$HYPR_DIR/themes/arcana/dunst" "$CONFIG_DIR/dunst"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY BTOP THEMES
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying btop themes...${NC}"
mkdir -p "$CONFIG_DIR/btop/themes"
safe_copy "$SCRIPT_DIR/btop/themes" "$CONFIG_DIR/btop/themes" true
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY RANGER CONFIG
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying ranger config...${NC}"
mkdir -p "$CONFIG_DIR/ranger"
safe_copy "$SCRIPT_DIR/ranger/rc.conf" "$CONFIG_DIR/ranger/rc.conf"
safe_copy "$SCRIPT_DIR/ranger/rifle.conf" "$CONFIG_DIR/ranger/rifle.conf"
safe_copy "$SCRIPT_DIR/ranger/scope.sh" "$CONFIG_DIR/ranger/scope.sh"
if [ -f "$CONFIG_DIR/ranger/scope.sh" ]; then
    chmod +x "$CONFIG_DIR/ranger/scope.sh"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY MICRO COLORSCHEMES
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying micro colorschemes...${NC}"
mkdir -p "$CONFIG_DIR/micro/colorschemes"
safe_copy "$SCRIPT_DIR/micro/colorschemes" "$CONFIG_DIR/micro/colorschemes" true
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY EKPHOS CONFIG
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${PURPLE}Deploying ekphos config...${NC}"
mkdir -p "$CONFIG_DIR/ekphos/themes"
safe_copy "$SCRIPT_DIR/ekphos/config.toml" "$CONFIG_DIR/ekphos/config.toml"
safe_copy "$SCRIPT_DIR/ekphos/themes" "$CONFIG_DIR/ekphos/themes" true
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# DEPLOY ZSH CONFIG (if exists)
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
    echo -e "${PURPLE}Deploying zsh config...${NC}"
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak" 2>/dev/null || true
        echo -e "  ${YELLOW}⚠${NC} Backed up existing .zshrc"
    fi
    safe_copy "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    echo ""
fi



# ─────────────────────────────────────────────────────────────────────────────
# COMPLETION SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                         DEPLOYMENT COMPLETE!                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${PURPLE}Deployed Locations:${NC}"
echo "  ~/.config/hypr/               - Hyprland base configs & scripts"
echo "  ~/.config/hypr/themes/arcana/ - Obsidian Arcana theme + Quickshell"
echo "  ~/.config/hypr/themes/ghost/  - Ghost Mode theme + Quickshell"
echo "  ~/.config/hypr/themes/shared/ - Shared QML components"
echo "  ~/.config/hypr/scripts/       - Mode switching & utility scripts"
echo "  ~/.config/hypr/wallpapers/    - Wallpaper collection"
echo ""

echo -e "${CYAN}Active Configs (via symlinks):${NC}"
echo "  ~/.config/kitty/    -> Arcana theme"
echo "  ~/.config/rofi/     -> Arcana theme"
echo "  ~/.config/dunst/    -> Arcana theme"
echo ""
echo -e "${CYAN}Mode Switching:${NC}"
echo "  Keybind: SUPER + SHIFT + G"
echo "  Script:  ~/.config/hypr/scripts/switch-mode.sh"
echo ""
echo -e "${YELLOW}Ghost Mode Features:${NC}"
echo "  • ProtonVPN auto-connect"
echo "  • UFW kill-switch activation"
echo "  • Auto-launch: Burpsuite, Wireshark, Terminal"
echo ""
echo -e "${PURPLE}Wallpaper Controls (Arcana mode):${NC}"
echo "  SUPER + W         - Open wallpaper menu"
echo "  SUPER + SHIFT + W - Cycle to next wallpaper"
echo ""
echo -e "${YELLOW}Scripts Deployed:${NC}"
if [ -d "$HYPR_DIR/scripts" ]; then
    ls -1 "$HYPR_DIR/scripts/"*.sh 2>/dev/null | xargs -I{} basename {} | sed 's/^/  • /'
fi
echo ""



echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Log out and select Hyprland from your display manager"

echo "  3. Use SUPER + SHIFT + G to switch between modes"
echo "  4. Use SUPER + W to change wallpapers in Arcana mode"
echo ""
if [ "$NEEDS_BACKUP" = true ]; then
    echo -e "${GREEN}Your old configs were backed up to:${NC}"
    echo "  $BACKUP_DIR"
    echo ""
fi
