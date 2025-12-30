#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                    WALLPAPER MENU - OBSIDIAN ARCANA                       ║
# ║              Rofi-based wallpaper selector with previews                  ║
# ╚══════════════════════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
THUMBNAIL_DIR="$HOME/.config/hypr/.wallpaper-thumbnails"
SWITCHER_SCRIPT="$SCRIPT_DIR/wallpaper-switcher.sh"

# Thumbnail size for rofi
THUMB_SIZE=200

# Supported file extensions
IMAGE_EXTENSIONS="jpg|jpeg|png|gif|webp|bmp"
VIDEO_EXTENSIONS="mp4|webm|mkv|mov|avi"

# ═══════════════════════════════════════════════════════════════════════════════
# THUMBNAIL GENERATION
# ═══════════════════════════════════════════════════════════════════════════════

# Get file extension (lowercase)
get_extension() {
    echo "${1##*.}" | tr '[:upper:]' '[:lower:]'
}

# Check if file is an image
is_image() {
    local ext=$(get_extension "$1")
    [[ "$ext" =~ ^($IMAGE_EXTENSIONS)$ ]]
}

# Check if file is a video
is_video() {
    local ext=$(get_extension "$1")
    [[ "$ext" =~ ^($VIDEO_EXTENSIONS)$ ]]
}

# Generate thumbnail for a file
generate_thumbnail() {
    local file="$1"
    local thumb_path="$2"
    
    # Skip if thumbnail already exists and is newer than source
    if [ -f "$thumb_path" ] && [ "$thumb_path" -nt "$file" ]; then
        return 0
    fi
    
    if is_image "$file"; then
        # Use ImageMagick to create thumbnail
        convert "$file" -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
            -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
            "$thumb_path" 2>/dev/null
    elif is_video "$file"; then
        # Use ffmpeg to extract frame and create thumbnail
        ffmpeg -y -i "$file" -ss 00:00:01 -vframes 1 \
            -vf "scale=${THUMB_SIZE}:${THUMB_SIZE}:force_original_aspect_ratio=increase,crop=${THUMB_SIZE}:${THUMB_SIZE}" \
            "$thumb_path" 2>/dev/null
        
        # Add play icon overlay for videos
        if [ -f "$thumb_path" ]; then
            # Create a simple play triangle overlay
            convert "$thumb_path" \
                -fill 'rgba(255,255,255,0.7)' \
                -draw "polygon ${THUMB_SIZE_3},${THUMB_SIZE_4} ${THUMB_SIZE_3},${THUMB_SIZE_34} ${THUMB_SIZE_23},${THUMB_SIZE_2}" \
                "$thumb_path" 2>/dev/null || true
        fi
    fi
}

# Generate all thumbnails
generate_all_thumbnails() {
    mkdir -p "$THUMBNAIL_DIR"
    
    local files=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
        -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" -o \
        -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o \
        -iname "*.mov" -o -iname "*.avi" \
    \) 2>/dev/null)
    
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        local basename=$(basename "$file")
        local thumb_path="$THUMBNAIL_DIR/${basename%.*}.png"
        generate_thumbnail "$file" "$thumb_path" &
    done <<< "$files"
    
    # Wait for all thumbnails to generate
    wait
}

# ═══════════════════════════════════════════════════════════════════════════════
# ROFI MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_wallpaper_menu() {
    # Generate thumbnails first
    generate_all_thumbnails
    
    # Get all wallpaper files
    local files=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
        -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" -o \
        -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o \
        -iname "*.mov" -o -iname "*.avi" \
    \) 2>/dev/null | sort)
    
    if [ -z "$files" ]; then
        notify-send -u critical "Wallpaper Menu" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    
    # Build rofi input with icons
    local rofi_input=""
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        local basename=$(basename "$file")
        local name="${basename%.*}"
        local thumb_path="$THUMBNAIL_DIR/${name}.png"
        
        # Add type indicator
        local type_icon=""
        if is_video "$file"; then
            type_icon="🎬 "
        else
            type_icon="🖼️ "
        fi
        
        if [ -f "$thumb_path" ]; then
            rofi_input+="${type_icon}${name}\x00icon\x1f${thumb_path}\n"
        else
            rofi_input+="${type_icon}${name}\n"
        fi
    done <<< "$files"
    
    # Show rofi menu
    local selected=$(echo -e "$rofi_input" | rofi -dmenu \
        -theme ~/.config/rofi/wallpaper.rasi \
        -p "󰸉 Wallpapers" \
        -i \
        -no-custom \
        -format 's')
    
    # Exit if nothing selected
    [ -z "$selected" ] && exit 0
    
    # Remove type icon prefix and find the matching file
    selected="${selected#🎬 }"
    selected="${selected#🖼️ }"
    
    # Find the full path of the selected wallpaper
    local selected_file=""
    while IFS= read -r file; do
        local name="${file%.*}"
        name=$(basename "$name")
        if [ "$name" = "$selected" ]; then
            selected_file="$file"
            break
        fi
    done <<< "$files"
    
    if [ -n "$selected_file" ]; then
        "$SWITCHER_SCRIPT" --set "$selected_file"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

show_wallpaper_menu
