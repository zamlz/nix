#!/usr/bin/env zsh

if [ -d $1 ]; then
    tree -C $1
elif [ -f $1 ]; then
    # FIXME: One day i will figure out how to use the exact colors my editor uses
    bat --color=always --style=numbers --line-range=:500 --theme=ansi $1
else;
    echo "ERROR: not a file or directory! No preview available"
fi
