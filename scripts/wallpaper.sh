#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                    WALLPAPER SCRIPT - OBSIDIAN ARCANA                     ║
# ║                 Startup script - delegates to switcher                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWITCHER_SCRIPT="$SCRIPT_DIR/wallpaper-switcher.sh"

# Wait for swww daemon to be ready
sleep 0.5

# Use the wallpaper switcher to restore or set default wallpaper
if [ -f "$SWITCHER_SCRIPT" ]; then
    "$SWITCHER_SCRIPT" --restore
else
    # Fallback to original behavior if switcher doesn't exist
    WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
    WALLPAPER="$WALLPAPER_DIR/guts-berserk-dark-5120x2880-19127.jpg"
    
    if [ -f "$WALLPAPER" ]; then
        swww img "$WALLPAPER" \
            --transition-type grow \
            --transition-pos 0.5,0.9 \
            --transition-duration 2 \
            --transition-fps 60
    else
        echo "Wallpaper not found at $WALLPAPER"
        echo "Please add your wallpaper to $WALLPAPER_DIR"
    fi
fi
