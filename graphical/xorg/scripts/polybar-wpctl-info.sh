#!/usr/bin/env sh

volume=$(wpctl get-volume @DEFAULT_SINK@)
if [ -n "$(echo $volume | grep MUTED)" ]; then
     echo "[MUTED]"
     exit 1
else
    echo "[$(echo $volume | sed -e 's|Volume: ||g')]"
    exit 0
fi
