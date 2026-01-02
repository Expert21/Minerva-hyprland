#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                      SWITCH MODE - GHOST / ARCANA                          ║
# ║              Toggle between pentesting and aesthetic modes                 ║
# ╚══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.config"
HYPR_DIR="$CONFIG_DIR/hypr"
MODE_FILE="$HYPR_DIR/.current-mode"
THEMES_DIR="$HYPR_DIR/themes"

# Get current mode (default to arcana)
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "arcana")

# Colors for terminal output
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Use pkexec for GUI sudo prompts
run_privileged() {
    if command -v pkexec &>/dev/null; then
        pkexec "$@"
    else
        sudo "$@"
    fi
}

swap_configs() {
    local mode=$1
    
    echo -e "${CYAN}[*] Swapping configs to $mode (using symlinks)...${NC}"
    
    # Symlink hyprland.conf
    rm -f "$HYPR_DIR/hyprland.conf"
    ln -sf "$THEMES_DIR/$mode/hyprland.conf" "$HYPR_DIR/hyprland.conf"
    
    # Symlink waybar directory
    rm -rf "$CONFIG_DIR/waybar"
    ln -sf "$THEMES_DIR/$mode/waybar" "$CONFIG_DIR/waybar"
    
    # Symlink kitty config
    rm -rf "$CONFIG_DIR/kitty"
    mkdir -p "$CONFIG_DIR/kitty"
    ln -sf "$THEMES_DIR/$mode/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"
    
    # Symlink rofi directory
    rm -rf "$CONFIG_DIR/rofi"
    ln -sf "$THEMES_DIR/$mode/rofi" "$CONFIG_DIR/rofi"
    
    # Symlink dunst directory
    rm -rf "$CONFIG_DIR/dunst"
    ln -sf "$THEMES_DIR/$mode/dunst" "$CONFIG_DIR/dunst"
    
    echo -e "${GREEN}[✓] Configs symlinked to $mode theme${NC}"
}

kill_services() {
    echo -e "${CYAN}[*] Stopping services...${NC}"
    
    # Try graceful termination first (SIGTERM)
    pkill quickshell 2>/dev/null || true
    pkill -x dunst 2>/dev/null || true
    pkill -x swww-daemon 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || true
    
    # Give them a moment to exit cleanly
    sleep 0.5
    
    # Force kill any survivors (SIGKILL)
    pkill -9 quickshell 2>/dev/null || true
    pkill -9 -x dunst 2>/dev/null || true
    pkill -9 -x swww-daemon 2>/dev/null || true
    pkill -9 -x swaybg 2>/dev/null || true
    
    # Final brief wait to ensure they're gone
    sleep 0.5
    
    echo -e "${GREEN}[✓] Services stopped${NC}"
}

activate_ghost_mode() {
    echo -e "${CYAN}[*] Activating GHOST MODE...${NC}"
    
    # Save mode state
    echo "ghost" > "$MODE_FILE"
    
    # Kill existing services
    kill_services
    
    # Swap configs via symlinks
    swap_configs "ghost"
    
    # Set solid black background
    swaybg -c "#000000" &
    disown
    
    # Start waybar and dunst with new configs
    sleep 0.5
    quickshell -p "$THEMES_DIR/ghost/quickshell/shell.qml" &
    disown
    dunst &
    disown
    
    # ═══════════════════════════════════════════════════════════════════════
    # VPN ACTIVATION
    # ═══════════════════════════════════════════════════════════════════════
    echo -e "${CYAN}[*] Connecting to ProtonVPN...${NC}"
    protonvpn connect 2>/dev/null || {
        echo -e "${RED}[!] VPN connection failed - check ProtonVPN${NC}"
        notify-send -u critical "Ghost Mode" "VPN connection failed!"
        return 1
    }
    
    # Wait for VPN tunnel to establish (with timeout)
    echo -e "${CYAN}[*] Waiting for VPN tunnel...${NC}"
    TIMEOUT=15
    ELAPSED=0
    while ! ip link show proton0 &>/dev/null && \
          ! ip link show tun0 &>/dev/null && \
          ! ip link show wg0 &>/dev/null; do
        sleep 1
        ((ELAPSED++))
        if [ $ELAPSED -ge $TIMEOUT ]; then
            echo -e "${RED}[!] VPN tunnel failed to establish${NC}"
            notify-send -u critical "Ghost Mode" "VPN tunnel timeout!"
            return 1
        fi
    done
    echo -e "${GREEN}[✓] VPN tunnel established${NC}"
    
    # ═══════════════════════════════════════════════════════════════════════
    # UFW KILL-SWITCH (with GUI password prompt)
    # ═══════════════════════════════════════════════════════════════════════
    echo -e "${CYAN}[*] Activating UFW kill-switch (may prompt for password)...${NC}"
    
    UFW_SCRIPT=$(mktemp)
    cat > "$UFW_SCRIPT" << 'EOFUFW'
#!/bin/bash
ufw --force disable
ufw --force reset
ufw default deny incoming
ufw default deny outgoing
ufw allow out on lo
ufw allow in on lo
ufw allow out 51820/udp
ufw allow out 1194/udp
ufw allow out on proton0
ufw allow out on tun0
ufw allow out on wg0
ufw allow out on proton0 to any port 53
ufw allow out on tun0 to any port 53
ufw allow out on wg0 to any port 53
ufw allow out on proton0 to any port 443
ufw allow out on tun0 to any port 443
ufw allow out on wg0 to any port 443
ufw --force enable
ufw reload
EOFUFW
    chmod +x "$UFW_SCRIPT"
    
    if ! run_privileged bash "$UFW_SCRIPT" 2>> ~/.config/hypr/ufw-errors.log; then
        echo -e "${RED}[!] UFW killswitch failed to apply${NC}"
        notify-send -u critical "Ghost Mode" "UFW killswitch FAILED!"
        rm -f "$UFW_SCRIPT"
        return 1
    fi
    rm -f "$UFW_SCRIPT"
    echo -e "${GREEN}[✓] UFW killswitch active${NC}"
    
    # Give UFW time to fully apply
    sleep 1
    
    # ═══════════════════════════════════════════════════════════════════════
    # LAUNCH PENTESTING TOOLS
    # ═══════════════════════════════════════════════════════════════════════
    echo -e "${CYAN}[*] Launching pentesting tools...${NC}"
    
    burpsuite &>/dev/null &
    disown
    
    wireshark &>/dev/null &
    disown
    
    kitty &>/dev/null &
    disown
    
    # Reload Hyprland config
    sleep 0.5
    hyprctl reload
    
    notify-send -u normal "󰊠 GHOST MODE ACTIVATED" "VPN: Connected ✓\nKill-switch: Active\nTools: Launching..."
    
    echo -e "${GREEN}[✓] Ghost Mode activated!${NC}"
}

activate_arcana_mode() {
    echo -e "${PURPLE}[*] Returning to ARCANA MODE...${NC}"
    
    # Save mode state
    echo "arcana" > "$MODE_FILE"
    
    # ═══════════════════════════════════════════════════════════════════════
    # RELAX FIREWALL FIRST (with GUI password prompt)
    # ═══════════════════════════════════════════════════════════════════════
    echo -e "${PURPLE}[*] Relaxing UFW rules (may prompt for password)...${NC}"
    
    UFW_SCRIPT=$(mktemp)
    cat > "$UFW_SCRIPT" << 'EOFUFW'
#!/bin/bash
ufw --force disable
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow out on lo
ufw allow in on lo
ufw --force enable
ufw reload
EOFUFW
    chmod +x "$UFW_SCRIPT"
    
    if ! run_privileged bash "$UFW_SCRIPT" 2>> ~/.config/hypr/ufw-errors.log; then
        echo -e "${RED}[!] UFW reset failed${NC}"
        notify-send -u critical "Arcana Mode" "UFW reset FAILED!"
        rm -f "$UFW_SCRIPT"
        # Continue anyway - don't block on UFW failure for arcana
    fi
    rm -f "$UFW_SCRIPT"
    echo -e "${GREEN}[✓] UFW relaxed${NC}"
    
    # ═══════════════════════════════════════════════════════════════════════
    # DISCONNECT VPN
    # ═══════════════════════════════════════════════════════════════════════
    echo -e "${PURPLE}[*] Disconnecting VPN...${NC}"
    protonvpn disconnect 2>/dev/null || true
    
    # Wait for VPN to fully disconnect
    sleep 1
    
    # Kill existing services
    kill_services
    
    # Swap configs via symlinks
    swap_configs "arcana"
    
    # Restart swww for wallpapers
    swww-daemon &
    disown
    sleep 0.5
    
    # Apply wallpaper
    if [ -f "$HYPR_DIR/scripts/wallpaper.sh" ]; then
        "$HYPR_DIR/scripts/wallpaper.sh" &>/dev/null &
        disown
    elif [ -f "$HYPR_DIR/wallpapers/wallpaper.jpg" ]; then
        swww img "$HYPR_DIR/wallpapers/wallpaper.jpg" --transition-type grow &>/dev/null &
        disown
    fi
    
    # Start waybar and dunst with new configs
    sleep 0.3
    quickshell -p "$THEMES_DIR/arcana/quickshell/shell.qml" &
    disown
    dunst &
    disown
    
    # Reload Hyprland config
    sleep 0.5
    hyprctl reload
    
    notify-send -u normal "✨ Arcana Mode" "Welcome back to the aesthetic realm"
    
    echo -e "${PURPLE}[✓] Arcana Mode activated!${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

# Allow forcing a specific mode via argument
if [ "$1" = "ghost" ]; then
    activate_ghost_mode
    exit 0
elif [ "$1" = "arcana" ]; then
    activate_arcana_mode
    exit 0
fi

# Toggle based on current mode
if [ "$CURRENT_MODE" = "arcana" ]; then
    activate_ghost_mode
else
    activate_arcana_mode
fi
