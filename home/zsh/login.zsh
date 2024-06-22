# We do not need #! here. NixOS may prefix this script as needed.
# Hopefully, it does not postfix it as we are using `exec` commands here.

if [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 1 ]; then
    exec startx $HOME/.config/xinit/rc.sh "herbstluftwm"

elif [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 2 ]; then
    exec startx $HOME/.config/xinit/rc.sh "qtile start --backend x11"

fi
