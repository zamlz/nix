# We do not need #! here. NixOS may prefix/postfix this script as needed.

# This file should contain anything we would normally put in `.zshrc`

source $HOME/.config/zsh/prompt.zsh

# register hooks before the user is given the oppurtunity to enter a command
precmd() {
    # load terminal window info if it exists
    load_window_info > /dev/null 2>&1
    export PROMPT=$(prompt_generate $?)
    # save terminal window info (creates id file)
    save_window_info > /dev/null 2>&1
    # update the terminal title
    # FIXME: maybe incorporate previously run command if exists?
    print -Pn "\e]0;zsh %(1j,%j job%(2j|s|); ,)%~\a"
}

# register hooks to run after accepting a command but before executing it
preexec() {
    # writes the command and it's arguments to the title
    # FIXME: does not work with fg well
    printf "\033]0;%s\a" "$1"
}

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
