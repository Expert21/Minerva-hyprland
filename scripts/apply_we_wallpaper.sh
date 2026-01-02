#!/bin/bash
# Apply Wallpaper Engine wallpaper using linux-wallpaperengine
# Usage: apply_we_wallpaper.sh <workshop_id_or_path>

WALLPAPER_PATH="$1"

# If just an ID was passed, construct full path
if [[ "$WALLPAPER_PATH" != /* ]]; then
    WALLPAPER_PATH="$HOME/.local/share/Steam/steamapps/workshop/content/431960/$WALLPAPER_PATH"
fi

# Kill any existing wallpaper processes
pkill -f linux-wallpaperengine 2>/dev/null
pkill -f swww-daemon 2>/dev/null
pkill -f mpvpaper 2>/dev/null

# Small delay to ensure processes are killed
sleep 0.3

# Launch linux-wallpaperengine
# --screen-root renders to root window (desktop background)
linux-wallpaperengine --screen-root "$WALLPAPER_PATH" &

echo "Applied Wallpaper Engine wallpaper: $WALLPAPER_PATH"
