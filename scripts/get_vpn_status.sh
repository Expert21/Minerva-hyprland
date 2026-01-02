#!/bin/bash
# Get VPN connection status from protonvpn-cli
status=$(protonvpn-cli status 2>/dev/null | grep -i "Status:" | awk '{print $2}')
if [ -z "$status" ]; then
    status="Disconnected"
fi
echo "{\"connected\": \"$status\"}"
