#!/usr/bin/env zsh

if [ -d $1 ]; then
    tree -C $1
elif [ -f $1 ]; then
    grep -Iq . $1 > /dev/null 2>&1
    # it errors on binary files, then display media-info instead
    if [ $? -eq 0 ]; then
        # FIXME: One day i will figure out how to use the exact colors my editor uses
        bat --line-range=:500 $1
    else
        mediainfo $1
    fi
else;
    echo "ERROR: not a file or directory! No preview available"
fi
