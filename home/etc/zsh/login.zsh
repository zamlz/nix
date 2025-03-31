#!/usr/bin/env zsh

# This file should contain anything we would normally put in `.zlogin`

if [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 1 ]; then
    exec startx $HOME/.config/xinit/rc.sh "herbstluftwm"
fi
