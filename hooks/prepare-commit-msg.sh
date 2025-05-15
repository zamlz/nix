#!/bin/sh

# Only modify the commit message if it's a new commit (not merge, etc.)
case "$2" in
  commit|template|'')
    HOSTNAME=$(hostname)
    if ! grep -q "^$HOSTNAME: " "$1"; then
      sed -i "1s/^/$HOSTNAME: /" "$1"
    fi
    ;;
esac

