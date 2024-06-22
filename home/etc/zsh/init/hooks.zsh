#!/usr/bin/env zsh

# This file contains general zsh hooks which are used for the following purpose
# - Generating my shell prompt (PS1)
# - Loading & Saving Xorg Window Info
# - Setting the Xorg Window Title

# register hooks to run before the user is given the oppurtunity to enter a
# command. The order of these operations matter!!
precmd() {
    # load terminal window info if it exists
    load_window_info > /dev/null 2>&1
    # set my PS1
    export PROMPT=$(generate_complex_prompt $?)
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
