#!/usr/bin/env zsh

if [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 2 ]; then
    exec startx $HOME/.config/xinit/rc.sh "herbstluftwm"
fi
