#!/usr/bin/env zsh

# This file contains general zsh hooks which are used for the following purpose
# - Generating my shell prompt (PS1)
# - Saving Window Info (PWD tracking for navi-spawn-identical-shell)
# - Setting the Window Title

# register hooks to run before the user is given the oppurtunity to enter a
# command. The order of these operations matter!!
precmd() {
    # we must save the last known exit code first, otherwise, subsequent
    # operations will override it.
    local exit_code=$?
    # set my PS1
    export PROMPT=$(generate_complex_prompt ${exit_code})
    # save terminal window info (creates id file for PWD tracking)
    navi-save-window-info > /dev/null 2>&1
    # get ssh info for window title
    # FIXME: Only works if remote client is using my shell configuration
    if [ -n "$SSH_TTY" ]; then
        prefix="$(whoami)@$(hostname): "
    else
        prefix=""
    fi
    # update the terminal title
    # FIXME: maybe incorporate previously run command if exists?
    print -Pn "\e]0;${prefix}zsh %(1j,%j job%(2j|s|); ,)%~\a"
}

# register hooks to run after accepting a command but before executing it
preexec() {
    # get ssh info for window title
    # FIXME: Only works if remote client is using my shell configuration
    if [ -n "$SSH_TTY" ]; then
        prefix="$(whoami)@$(hostname): "
    else
        prefix=""
    fi
    # writes the command and it's arguments to the title
    # FIXME: does not work with fg well
    printf "\033]0;%s\a" "${prefix}${1}"
}
