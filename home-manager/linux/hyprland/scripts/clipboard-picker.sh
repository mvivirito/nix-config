#!/usr/bin/env bash
# Clipboard history picker with formatted display
#
# Purpose: Shows cliphist entries in human-readable format, handles images/binary data
# Bound to: SUPER+SHIFT+V
#
# Pipeline:
# 1. Get raw cliphist entries (format: "ID<tab>content")
# 2. Format for display (truncate long text, label binary data)
# 3. Show in tofi picker
# 4. Find original entry matching selection
# 5. Decode and copy to clipboard

set -euo pipefail

# Get all clipboard history entries from cliphist
items=$(cliphist list)

# Format entries for human-readable display
# AWK logic:
# - Preserve full line as 'line' variable
# - Extract ID (field 1), then remove it to get content text
# - Detect binary data pattern: "[[ binary data 1.2 MiB image/png ]]"
#   - If matched, reformat as "[image image/png 1.2 MiB]" (more readable)
# - Truncate text longer than 140 chars to "first 137 chars..."
# - Print formatted text (ID removed for clean display)
display=$(printf "%s\n" "$items" | awk '{
  line=$0;           # Preserve original line (with ID)
  id=$1;             # Extract ID
  $1="";             # Remove ID field
  sub(/^ /,"");      # Remove leading space after ID removal
  text=$0;           # Text is now everything except ID

  # Detect and reformat binary data entries
  if (match(text, /^\[\[ binary data ([0-9.]+ [KMG]iB) ([^ ]+)/, m)) {
    text="[image " m[2] " " m[1] "]"  # Reformat: [image mime/type size]
  }

  # Truncate long text
  if (length(text)>140)
    text=substr(text,1,137)"...";

  print text;        # Output formatted text only
}')

# Show formatted entries in tofi picker
selection=$(printf "%s\n" "$display" | tofi --config "$HOME/.config/tofi/clipboard")

# Exit if user canceled
[ -z "$selection" ] && exit 0

# Find original cliphist entry matching the formatted selection
# We need the original with ID intact to decode properly
line=$(printf "%s\n" "$items" | awk -v sel="$selection" '{
  line=$0;           # Full original line (with ID)
  id=$1;
  $1="";
  sub(/^ /,"");
  text=$0;

  # Apply same formatting as display to match selection
  if (match(text, /^\[\[ binary data ([0-9.]+ [KMG]iB) ([^ ]+)/, m)) {
    text="[image " m[2] " " m[1] "]"
  }
  if (length(text)>140)
    text=substr(text,1,137)"...";

  # If formatted text matches selection, print original line and exit
  if (text==sel) {
    print line;
    exit
  }
}')

# Exit if no match found
[ -z "$line" ] && exit 0

# Decode the selected entry and copy to clipboard
# cliphist stores in encoded format, decode restores original content
printf "%s\n" "$line" | cliphist decode | wl-copy
