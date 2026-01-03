#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Rofi Projects - Quick project launcher
# ═══════════════════════════════════════════════════════════════════════════════

# Directories to search for projects
PROJECT_DIRS=(
    "$HOME/Projects"
    "$HOME/Development"
    "$HOME/Code"
    "$HOME/repos"
    "$HOME/work"
)

# Max depth to search
MAX_DEPTH=2

# Find projects (directories containing .git, package.json, Cargo.toml, etc.)
find_projects() {
    for dir in "${PROJECT_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            # Find git repositories
            find "$dir" -maxdepth $MAX_DEPTH -type d -name ".git" 2>/dev/null | \
                sed 's|/.git$||' | \
                while read -r proj; do
                    echo "$(basename "$proj")|$proj"
                done
        fi
    done | sort -u
}

# Format for display
PROJECTS=$(find_projects)

if [ -z "$PROJECTS" ]; then
    notify-send "No Projects Found" "Check PROJECT_DIRS in script" -u critical
    exit 1
fi

# Display in rofi
SELECTED=$(echo "$PROJECTS" | cut -d'|' -f1 | rofi -dmenu -i -p " Project" \
    -theme-str 'window {width: 400px;}' \
    -theme-str 'listview {lines: 12;}')

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Get full path
PROJECT_PATH=$(echo "$PROJECTS" | grep "^$SELECTED|" | cut -d'|' -f2)

if [ -z "$PROJECT_PATH" ]; then
    notify-send "Error" "Could not find project path" -u critical
    exit 1
fi

# Secondary menu - what to do
ACTION=$(echo -e "󱃖 Open in Terminal
 Open in Editor
 Open in File Manager
 Open in VS Code" | rofi -dmenu -i -p "Action" \
    -theme-str 'window {width: 300px;}')

case "$ACTION" in
    *"Terminal"*)
        kitty --working-directory="$PROJECT_PATH" &
        ;;
    *"Editor"*)
        kitty --working-directory="$PROJECT_PATH" -e ${EDITOR:-micro} . &
        ;;
    *"File Manager"*)
        kitty --working-directory="$PROJECT_PATH" -e ranger &
        ;;
    *"VS Code"*)
        code "$PROJECT_PATH" &
        ;;
esac

notify-send "Opening Project" "$SELECTED" -t 2000
