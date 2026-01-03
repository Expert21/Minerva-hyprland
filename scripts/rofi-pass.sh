#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Rofi Pass - Password manager integration using pass (password-store)
# ═══════════════════════════════════════════════════════════════════════════════

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

# Check if pass is installed
if ! command -v pass &>/dev/null; then
    notify-send "Error" "pass (password-store) is not installed" -u critical
    exit 1
fi

# Check if password store exists
if [ ! -d "$PASSWORD_STORE_DIR" ]; then
    notify-send "Error" "Password store not found at $PASSWORD_STORE_DIR" -u critical
    exit 1
fi

# Get list of passwords
get_passwords() {
    cd "$PASSWORD_STORE_DIR" || exit 1
    find . -name "*.gpg" -type f | \
        sed 's|^\./||;s|\.gpg$||' | \
        sort
}

# Main menu
PASSWORDS=$(get_passwords)
SELECTED=$(echo "$PASSWORDS" | rofi -dmenu -i -p "󰌋 Password" \
    -theme-str 'window {width: 400px;}' \
    -theme-str 'listview {lines: 10;}')

if [ -z "$SELECTED" ]; then
    exit 0
fi

# Secondary menu - what to copy
ACTION=$(echo -e "󰌋 Password\n󰀄 Username\n󱃻 OTP\n📋 Show all fields" | \
    rofi -dmenu -i -p "Action" \
    -theme-str 'window {width: 300px;}')

case "$ACTION" in
    *"Password"*)
        pass show -c "$SELECTED" 2>/dev/null
        notify-send "Password Copied" "$SELECTED" -t 3000
        # Auto-clear after 45 seconds (pass default)
        ;;
    *"Username"*)
        USERNAME=$(pass show "$SELECTED" 2>/dev/null | grep -i "^user\|^login\|^username" | head -1 | cut -d: -f2 | xargs)
        if [ -n "$USERNAME" ]; then
            echo -n "$USERNAME" | wl-copy
            notify-send "Username Copied" "$USERNAME" -t 3000
        else
            # Try to extract from path (e.g., sites/github.com/username)
            USERNAME=$(basename "$SELECTED")
            echo -n "$USERNAME" | wl-copy
            notify-send "Username Copied" "$USERNAME (from path)" -t 3000
        fi
        ;;
    *"OTP"*)
        if command -v pass-otp &>/dev/null; then
            OTP=$(pass otp "$SELECTED" 2>/dev/null)
            if [ -n "$OTP" ]; then
                echo -n "$OTP" | wl-copy
                notify-send "OTP Copied" "$OTP" -t 5000
            else
                notify-send "Error" "No OTP found for $SELECTED" -u critical
            fi
        else
            notify-send "Error" "pass-otp not installed" -u critical
        fi
        ;;
    *"Show all"*)
        CONTENT=$(pass show "$SELECTED" 2>/dev/null)
        # Show in rofi (read-only)
        echo "$CONTENT" | rofi -dmenu -i -p "Fields" \
            -theme-str 'window {width: 500px;}' \
            -theme-str 'listview {lines: 15;}'
        ;;
esac
