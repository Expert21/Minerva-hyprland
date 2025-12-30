#!/bin/bash
# VPN Status script for Waybar
# Returns status icon for ProtonVPN

STATUS=$(protonvpn status 2>/dev/null)

if echo "$STATUS" | grep -qi "connected"; then
    # Extract server info if possible
    SERVER=$(echo "$STATUS" | grep -i "Server:" | awk '{print $2}' | head -c 10)
    if [ -n "$SERVER" ]; then
        echo "󰌾 $SERVER"
    else
        echo "󰌾 VPN"
    fi
elif echo "$STATUS" | grep -qi "connecting"; then
    echo "󰌿 ..."
else
    echo "󰿆 OFF"
fi
