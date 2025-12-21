#!/usr/bin/env zsh

# These are some helper functions I've created to manage jobs.
# Honestly, they don't work that well tbh...

# FIXME: Eventually make this a widget like the fzf-zsh-history plugin (ctrl-r)
fzf-foreground-job() {
    [ -z "$(jobs)" ] && fg && return;
    fg %$(jobs | fzf --bind 'enter:become(echo %{1})' | tr -d '[]')
}
bindkey -s "^F" 'fzf-foreground-job^M'

autobg-ctrl-b () {
  if [[ $#BUFFER -eq 0 ]]; then
    echo ""
    bg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N autobg-ctrl-b
bindkey '^B' autobg-ctrl-b
