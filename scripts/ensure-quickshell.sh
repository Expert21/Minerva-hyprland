#!/bin/bash
# Ensures Quickshell is running with the correct config for the current mode
# Can be used by hypridle or as a recover script

CONFIG_DIR="$HOME/.config"
HYPR_DIR="$CONFIG_DIR/hypr"
MODE_FILE="$HYPR_DIR/.current-mode"
THEMES_DIR="$HYPR_DIR/themes"

# Check if quickshell is running
if pgrep -x "quickshell" >/dev/null; then
    exit 0
fi

# Determine mode
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "arcana")

echo "[$(date)] Quickshell not running. Resurrecting in $CURRENT_MODE mode..." >> /tmp/quickshell-watchdog.log

if [ "$CURRENT_MODE" = "ghost" ]; then
    quickshell -p "$THEMES_DIR/ghost/quickshell/shell.qml" > /tmp/quickshell-ghost.log 2>&1 &
else
    quickshell -p "$THEMES_DIR/arcana/quickshell/shell.qml" > /tmp/quickshell-arcana.log 2>&1 &
fi

disown
