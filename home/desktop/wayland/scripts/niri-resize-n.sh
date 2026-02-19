#!/usr/bin/env sh

set -e

# Script to resize niri windows on order of n/x, (n+1)/x, ... x/x
# where x is the number in the script file name
# the resize_order (x) is derived from the list of resize_factors

if [ -z "$RESIZE_FACTORS" ]; then
  exit 1
fi

RESIZE_ORDER=$(echo "$RESIZE_FACTORS" | jq 'length')

WINDOW_ID=$(niri msg --json focused-window | jq '.id')
WINDOW_ID_DIR="$HOME/tmp/.niri-resize"
WINDOW_ID_FILE="$WINDOW_ID_DIR/$WINDOW_ID"

mkdir -p "$WINDOW_ID_DIR"
if [ -f "$WINDOW_ID_FILE" ]; then
  . "$WINDOW_ID_FILE"
fi

INDEX="0"
if [ "$NIRI_RESIZE_X_VALUE" = "$RESIZE_ORDER" ]; then
  INDEX=$(awk "BEGIN { print ($NIRI_RESIZE_N_VALUE + 1) % $RESIZE_ORDER }")
fi

niri msg action set-column-width "$(echo "$RESIZE_FACTORS" | jq -r ".[$INDEX]")"

echo "NIRI_RESIZE_X_VALUE=$RESIZE_ORDER" > "$WINDOW_ID_FILE"
echo "NIRI_RESIZE_N_VALUE=$INDEX" >> "$WINDOW_ID_FILE"
