#!/usr/bin/env zsh

# This file should contain anything we would normally put in `.zshenv`

# Make our pager a little more intelligent
export LESS="-M -R -i --use-color --mouse -Dd+b -Du+c -DHkC -j5"
export MANROFFOPT="-c"

# no longer creates __pycache__ folders in the same folder as *.py files
export PYTHONPYCACHEPREFIX="$HOME/.cache/__pycache__"

# Save the window info immediately in case processes are started without ever
# needing a zsh prompt. navi-save-window-info saves the current window's PWD,
# which is used by navi-spawn-identical-shell to open new terminals in the same
# directory. Works on both X11 (herbstluftwm) and Wayland (niri).
navi-save-window-info > /dev/null 2>&1
