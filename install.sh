#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║              PACKAGE INSTALLER - OBSIDIAN ARCANA RICE                     ║
# ║                         Arch Linux / pacman                               ║
# ╚══════════════════════════════════════════════════════════════════════════╝

set -e

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                     OBSIDIAN ARCANA - PACKAGE INSTALLER                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Core packages
CORE=(
    hyprland
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
)

# Bar and UI
UI=(
    waybar
    rofi-wayland
    dunst
)

# Terminal
TERMINAL=(
    kitty
)

# Utilities
UTILS=(
    swww
    grim
    slurp
    hyprshot
    wl-clipboard
    cliphist
    brightnessctl
    pavucontrol
    network-manager-applet
)

# Fonts
FONTS=(
    ttf-jetbrains-mono-nerd
)

# Optional (file manager, etc)
OPTIONAL=(
    thunar
    papirus-icon-theme
)

echo -e "${PURPLE}Installing core Hyprland packages...${NC}"
sudo pacman -S --needed "${CORE[@]}"

echo ""
echo -e "${PURPLE}Installing UI components...${NC}"
sudo pacman -S --needed "${UI[@]}"

echo ""
echo -e "${PURPLE}Installing terminal...${NC}"
sudo pacman -S --needed "${TERMINAL[@]}"

echo ""
echo -e "${PURPLE}Installing utilities...${NC}"
sudo pacman -S --needed "${UTILS[@]}"

echo ""
echo -e "${PURPLE}Installing fonts...${NC}"
sudo pacman -S --needed "${FONTS[@]}"

echo ""
read -p "Install optional packages (thunar, papirus-icon-theme)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S --needed "${OPTIONAL[@]}"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                         INSTALLATION COMPLETE!                            ║"
echo "║                                                                           ║"
echo "║  Next steps:                                                              ║"
echo "║  1. Run ./deploy.sh to copy configs to ~/.config                         ║"
echo "║  2. Add your wallpaper to ~/.config/hypr/wallpapers/wallpaper.jpg        ║"
echo "║  3. Log out and select Hyprland from your display manager                ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
