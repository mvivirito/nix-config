#!/usr/bin/env bash

# Get Tailscale status
STATUS=$(tailscale status 2>&1)

# Check various states
if echo "$STATUS" | grep -qi "Tailscale is stopped\|stopped"; then
    echo '{"text": "󰿆", "tooltip": "Tailscale: Stopped", "class": "disconnected"}'
elif echo "$STATUS" | grep -qi "needs login\|logged out\|log in"; then
    echo '{"text": "󰽥", "tooltip": "Tailscale: Needs Login", "class": "warning"}'
elif echo "$STATUS" | grep -qi "command not found\|not installed"; then
    echo '{"text": "󰿆", "tooltip": "Tailscale: Not installed", "class": "disconnected"}'
elif echo "$STATUS" | grep -q "^100\."; then
    # Connected - get our IP from the first line
    SELF_IP=$(echo "$STATUS" | grep "^100\." | head -1 | awk '{print $1}')
    PEER_COUNT=$(echo "$STATUS" | grep -c "^100\.")
    echo "{\"text\": \"󰛳\", \"tooltip\": \"Tailscale: Connected\\nIP: $SELF_IP\\nPeers: $PEER_COUNT\", \"class\": \"connected\"}"
else
    # Unknown state - show whatever status we got
    FIRST_LINE=$(echo "$STATUS" | head -1)
    echo "{\"text\": \"󰿆\", \"tooltip\": \"Tailscale: $FIRST_LINE\", \"class\": \"unknown\"}"
fi
