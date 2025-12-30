#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                    WALLPAPER SWITCHER - OBSIDIAN ARCANA                   ║
# ║            Supports static images (swww) and videos (mpvpaper)            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
STATE_FILE="$HOME/.config/hypr/.current-wallpaper"
THUMBNAIL_DIR="$HOME/.config/hypr/.wallpaper-thumbnails"

# Supported file extensions
IMAGE_EXTENSIONS="jpg|jpeg|png|gif|webp|bmp"
VIDEO_EXTENSIONS="mp4|webm|mkv|mov|avi"

# Colors for terminal output
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

log_info() {
    echo -e "${CYAN}[*] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

log_error() {
    echo -e "${RED}[!] $1${NC}"
}

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

# Get all wallpapers in directory
get_wallpapers() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
        -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" -o \
        -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o \
        -iname "*.mov" -o -iname "*.avi" \
    \) 2>/dev/null | sort
}

# Get current wallpaper from state file
get_current_wallpaper() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo ""
    fi
}

# Save current wallpaper to state file
save_current_wallpaper() {
    echo "$1" > "$STATE_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PROCESS CLEANUP - Critical for switching between swww and mpvpaper
# ═══════════════════════════════════════════════════════════════════════════════

kill_swww() {
    log_info "Stopping swww-daemon..."
    pkill -x swww-daemon 2>/dev/null || true
    pkill -x swww 2>/dev/null || true
    sleep 0.3
    # Force kill if still running
    pkill -9 -x swww-daemon 2>/dev/null || true
    pkill -9 -x swww 2>/dev/null || true
    sleep 0.2
}

kill_mpvpaper() {
    log_info "Stopping mpvpaper..."
    pkill -x mpvpaper 2>/dev/null || true
    sleep 0.3
    # Force kill if still running
    pkill -9 -x mpvpaper 2>/dev/null || true
    sleep 0.2
}

# Kill all wallpaper processes
kill_all_wallpaper_processes() {
    kill_swww
    kill_mpvpaper
}

# ═══════════════════════════════════════════════════════════════════════════════
# WALLPAPER SETTERS
# ═══════════════════════════════════════════════════════════════════════════════

set_image_wallpaper() {
    local wallpaper="$1"
    
    log_info "Setting image wallpaper: $(basename "$wallpaper")"
    
    # Kill mpvpaper first (if running) - MUST happen before starting swww
    kill_mpvpaper
    
    # Check if swww-daemon is running, if not start it
    if ! pgrep -x swww-daemon > /dev/null; then
        log_info "Starting swww-daemon..."
        swww-daemon &
        disown
        sleep 0.5
    fi
    
    # Set wallpaper with transition
    swww img "$wallpaper" \
        --transition-type grow \
        --transition-pos 0.5,0.9 \
        --transition-duration 2 \
        --transition-fps 60
    
    log_success "Image wallpaper set!"
}

set_video_wallpaper() {
    local wallpaper="$1"
    
    log_info "Setting video wallpaper: $(basename "$wallpaper")"
    
    # Kill swww first (if running) - MUST happen before starting mpvpaper
    kill_swww
    
    # Also kill any existing mpvpaper to avoid conflicts
    kill_mpvpaper
    
    # Start mpvpaper with loop and no audio
    # Using '*' for all monitors
    mpvpaper -o "no-audio loop" '*' "$wallpaper" &
    disown
    
    log_success "Video wallpaper set!"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN WALLPAPER SETTER
# ═══════════════════════════════════════════════════════════════════════════════

set_wallpaper() {
    local wallpaper="$1"
    
    # Validate file exists
    if [ ! -f "$wallpaper" ]; then
        log_error "Wallpaper not found: $wallpaper"
        return 1
    fi
    
    # Determine type and set accordingly
    if is_image "$wallpaper"; then
        set_image_wallpaper "$wallpaper"
    elif is_video "$wallpaper"; then
        set_video_wallpaper "$wallpaper"
    else
        log_error "Unsupported file type: $wallpaper"
        return 1
    fi
    
    # Save state
    save_current_wallpaper "$wallpaper"
    
    # Send notification
    notify-send -u low "✨ Wallpaper Changed" "$(basename "$wallpaper")"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CYCLE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

cycle_next() {
    local wallpapers=($(get_wallpapers))
    local count=${#wallpapers[@]}
    
    if [ $count -eq 0 ]; then
        log_error "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
    
    local current=$(get_current_wallpaper)
    local next_index=0
    
    # Find current index and get next
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current" ]; then
            next_index=$(( (i + 1) % count ))
            break
        fi
    done
    
    set_wallpaper "${wallpapers[$next_index]}"
}

cycle_previous() {
    local wallpapers=($(get_wallpapers))
    local count=${#wallpapers[@]}
    
    if [ $count -eq 0 ]; then
        log_error "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
    
    local current=$(get_current_wallpaper)
    local prev_index=$((count - 1))
    
    # Find current index and get previous
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current" ]; then
            prev_index=$(( (i - 1 + count) % count ))
            break
        fi
    done
    
    set_wallpaper "${wallpapers[$prev_index]}"
}

set_random() {
    local wallpapers=($(get_wallpapers))
    local count=${#wallpapers[@]}
    
    if [ $count -eq 0 ]; then
        log_error "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
    
    local random_index=$((RANDOM % count))
    set_wallpaper "${wallpapers[$random_index]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# RESTORE FUNCTION (for startup)
# ═══════════════════════════════════════════════════════════════════════════════

restore_wallpaper() {
    local current=$(get_current_wallpaper)
    
    if [ -n "$current" ] && [ -f "$current" ]; then
        log_info "Restoring saved wallpaper..."
        set_wallpaper "$current"
    else
        # Fall back to first available wallpaper
        local wallpapers=($(get_wallpapers))
        if [ ${#wallpapers[@]} -gt 0 ]; then
            log_info "No saved wallpaper, using first available..."
            set_wallpaper "${wallpapers[0]}"
        else
            log_error "No wallpapers found in $WALLPAPER_DIR"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# USAGE
# ═══════════════════════════════════════════════════════════════════════════════

show_usage() {
    echo "Usage: $(basename "$0") [OPTION]"
    echo ""
    echo "Options:"
    echo "  --set <path>    Set specific wallpaper"
    echo "  --next          Cycle to next wallpaper"
    echo "  --prev          Cycle to previous wallpaper"
    echo "  --random        Set random wallpaper"
    echo "  --restore       Restore last saved wallpaper"
    echo "  --list          List available wallpapers"
    echo "  --current       Show current wallpaper"
    echo "  --help          Show this help"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THUMBNAIL_DIR"

case "$1" in
    --set)
        if [ -z "$2" ]; then
            log_error "Please specify a wallpaper path"
            exit 1
        fi
        set_wallpaper "$2"
        ;;
    --next)
        cycle_next
        ;;
    --prev)
        cycle_previous
        ;;
    --random)
        set_random
        ;;
    --restore)
        restore_wallpaper
        ;;
    --list)
        get_wallpapers
        ;;
    --current)
        get_current_wallpaper
        ;;
    --help|-h)
        show_usage
        ;;
    *)
        # Default: restore wallpaper (useful for startup)
        restore_wallpaper
        ;;
esac
