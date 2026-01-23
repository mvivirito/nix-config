#!/usr/bin/env bash
# Clipboard initialization - ensures proper startup order
#
# Components:
# - wl-clip-persist: Keeps clipboard content after source app closes
# - cliphist: Stores clipboard history (text + images)
set -euo pipefail

# Start wl-clip-persist first (must be running before watchers)
wl-clip-persist --clipboard --primary &
sleep 0.3

# Start cliphist watchers for text and images
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
