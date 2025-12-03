#!/usr/bin/env bash
# Display layout management script
# Usage: display_layout.sh [extend|mirror|laptop-only|external-only]

set -e

MAIN_DISPLAY="DP-2"
LAPTOP_DISPLAY="eDP-1"

case "${1:-extend}" in
  extend)
    # Extend displays (default)
    wlr-randr --output "$MAIN_DISPLAY" --on --pos 1661,0 --scale 1
    wlr-randr --output "$LAPTOP_DISPLAY" --on --pos 6781,166 --scale 1.25
    notify-send "Display Layout" "Extended mode: Main (DP-2) + Laptop (eDP-1)"
    ;;
  mirror)
    # Mirror displays
    wlr-randr --output "$MAIN_DISPLAY" --on --scale 1
    wlr-randr --output "$LAPTOP_DISPLAY" --on --scale 1.25 --same-as "$MAIN_DISPLAY"
    notify-send "Display Layout" "Mirror mode enabled"
    ;;
  laptop)
    # Laptop only
    wlr-randr --output "$MAIN_DISPLAY" --off
    wlr-randr --output "$LAPTOP_DISPLAY" --on --pos 0,0 --scale 1.25
    notify-send "Display Layout" "Laptop display only"
    ;;
  external)
    # External display only
    wlr-randr --output "$LAPTOP_DISPLAY" --off
    wlr-randr --output "$MAIN_DISPLAY" --on --pos 0,0 --scale 1
    notify-send "Display Layout" "External display only (DP-2)"
    ;;
  *)
    echo "Usage: $0 {extend|mirror|laptop|external}"
    exit 1
    ;;
esac
