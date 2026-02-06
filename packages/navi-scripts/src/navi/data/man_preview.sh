#!/usr/bin/env sh

# FIXME: Why are these not respected in FZF?
# note: these are also defined in the environments.zsh file
export LESS="-M -R -i --use-color --mouse -Dd+b -Du+c -DHkC -j5"
export MANPAGER="less"
export MANROFFOPT="-c"

man_args=$(echo $@ \
    | tr -d '()' \
    | awk '{printf "%s ", $2} {print $1}')
man $man_args
