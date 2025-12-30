#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║              CONFIG DEPLOYER - DUAL MODE RICE                              ║
# ║                    Obsidian Arcana + Ghost Mode                            ║
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
NC='\033[0m'

# Configs to deploy
CONFIGS=(
    "hypr"
    "waybar"
    "kitty"
    "rofi"
    "dunst"
)

# Backup existing configs
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

# Create hypr directory structure
echo -e "${PURPLE}Setting up directory structure...${NC}"
mkdir -p "$HYPR_DIR/themes/arcana/waybar"
mkdir -p "$HYPR_DIR/themes/arcana/rofi"
mkdir -p "$HYPR_DIR/themes/arcana/dunst"
mkdir -p "$HYPR_DIR/themes/ghost/waybar"
mkdir -p "$HYPR_DIR/themes/ghost/rofi"
mkdir -p "$HYPR_DIR/themes/ghost/dunst"
mkdir -p "$HYPR_DIR/scripts"
mkdir -p "$HYPR_DIR/wallpapers"

# Deploy theme files
echo -e "${PURPLE}Deploying Arcana theme...${NC}"
cp "$SCRIPT_DIR/themes/arcana/hyprland.conf" "$HYPR_DIR/themes/arcana/"
cp -r "$SCRIPT_DIR/themes/arcana/waybar/"* "$HYPR_DIR/themes/arcana/waybar/"
cp "$SCRIPT_DIR/themes/arcana/kitty.conf" "$HYPR_DIR/themes/arcana/"
cp -r "$SCRIPT_DIR/themes/arcana/rofi/"* "$HYPR_DIR/themes/arcana/rofi/"
cp "$SCRIPT_DIR/themes/arcana/dunst/dunstrc" "$HYPR_DIR/themes/arcana/dunst/"

echo -e "${CYAN}Deploying Ghost Mode theme...${NC}"
cp "$SCRIPT_DIR/themes/ghost/hyprland.conf" "$HYPR_DIR/themes/ghost/"
cp -r "$SCRIPT_DIR/themes/ghost/waybar/"* "$HYPR_DIR/themes/ghost/waybar/"
cp "$SCRIPT_DIR/themes/ghost/kitty.conf" "$HYPR_DIR/themes/ghost/"
cp -r "$SCRIPT_DIR/themes/ghost/rofi/"* "$HYPR_DIR/themes/ghost/rofi/"
cp "$SCRIPT_DIR/themes/ghost/dunst/dunstrc" "$HYPR_DIR/themes/ghost/"

# Deploy scripts
echo -e "${PURPLE}Deploying scripts...${NC}"
cp "$SCRIPT_DIR/scripts/switch-mode.sh" "$HYPR_DIR/scripts/"
cp "$SCRIPT_DIR/scripts/vpn-status.sh" "$HYPR_DIR/scripts/"
cp "$SCRIPT_DIR/scripts/wallpaper.sh" "$HYPR_DIR/scripts/"
cp "$SCRIPT_DIR/scripts/wallpaper-switcher.sh" "$HYPR_DIR/scripts/"
cp "$SCRIPT_DIR/scripts/wallpaper-menu.sh" "$HYPR_DIR/scripts/"
chmod +x "$HYPR_DIR/scripts/"*.sh

# Deploy hypridle and hyprlock
if [ -f "$SCRIPT_DIR/hypr/hypridle.conf" ]; then
    cp "$SCRIPT_DIR/hypr/hypridle.conf" "$HYPR_DIR/"
fi
if [ -f "$SCRIPT_DIR/hypr/hyprlock.conf" ]; then
    cp "$SCRIPT_DIR/hypr/hyprlock.conf" "$HYPR_DIR/"
fi

# Set default mode to Arcana
echo -e "${PURPLE}Setting up default mode (Arcana)...${NC}"
echo "arcana" > "$HYPR_DIR/.current-mode"

# Create initial symlink and copy configs for Arcana
ln -sf "$HYPR_DIR/themes/arcana/hyprland.conf" "$HYPR_DIR/hyprland.conf"

# Deploy initial active configs (Arcana mode)
rm -rf "$CONFIG_DIR/waybar"
cp -r "$HYPR_DIR/themes/arcana/waybar" "$CONFIG_DIR/waybar"

rm -rf "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/kitty"
cp "$HYPR_DIR/themes/arcana/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"

rm -rf "$CONFIG_DIR/rofi"
cp -r "$HYPR_DIR/themes/arcana/rofi" "$CONFIG_DIR/rofi"

rm -rf "$CONFIG_DIR/dunst"
cp -r "$HYPR_DIR/themes/arcana/dunst" "$CONFIG_DIR/dunst"

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                         DEPLOYMENT COMPLETE!                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${PURPLE}Themes deployed:${NC}"
echo "  ~/.config/hypr/themes/arcana/  (Obsidian Arcana - aesthetic)"
echo "  ~/.config/hypr/themes/ghost/   (Ghost Mode - pentesting)"
echo ""
echo -e "${CYAN}Mode switching:${NC}"
echo "  Keybind: SUPER + SHIFT + G"
echo "  Script:  ~/.config/hypr/scripts/switch-mode.sh"
echo ""
echo -e "${YELLOW}Ghost Mode features:${NC}"
echo "  • ProtonVPN auto-connect"
echo "  • UFW kill-switch activation"
echo "  • Auto-launch: Burpsuite, Wireshark, Terminal"
echo ""
echo -e "${PURPLE}Wallpaper controls (Arcana mode):${NC}"
echo "  SUPER + W         - Open wallpaper menu"
echo "  SUPER + SHIFT + W - Cycle to next wallpaper"
echo ""
echo -e "${YELLOW}Don't forget to:${NC}"
echo "  1. Add your wallpaper to ~/.config/hypr/wallpapers/wallpaper.jpg"
echo "  2. Log out and select Hyprland from your display manager"
echo "  3. Install swaybg for Ghost Mode black background"
echo ""
if [ "$NEEDS_BACKUP" = true ]; then
    echo -e "${GREEN}Your old configs were backed up to:${NC}"
    echo "  $BACKUP_DIR"
fi
