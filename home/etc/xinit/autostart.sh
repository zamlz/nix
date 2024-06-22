#!/bin/sh

# utilities
$HOME/.fehbg &
(pkill sxhkd; sleep 0.1; sxhkd) &
(pkill picom; sleep 0.1; picom) &
(pkill -f "polybar top"; sleep 0.1; polybar top) &
(pkill -f "polybar bot"; sleep 0.1; polybar bot) &

# xorg settings
xset r rate 400 50
xset s off
setxkbmap -option caps:escape
