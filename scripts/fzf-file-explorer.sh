#!/usr/bin/env zsh

# Inspired by dired
LOGGER=$(which logger)
logger() {$LOGGER --tag fzf-file-explorer -- $@}

# get the last focused wid by running the save-window-id.sh script
source /tmp/.wid/$(cat /tmp/.last_focused_wid)
if [ -z "${WINDOW_PWD}" ]; then
    logger "no previouw window: ${HOME}"
    FILESYSTEM_POINTER=$HOME
else
    logger "loaded from old window: ${WINDOW_PWD}"
    FILESYSTEM_POINTER=${WINDOW_PWD}
fi
LS_HIDDEN_ARG=""
TOGGLE_HIDDEN_ACTION="__TOGGLE_HIDDEN_VIEW__"

while [ -d $FILESYSTEM_POINTER ] || [ -f $FILESYSTEM_POINTER ]; do
    logger "start: ${selection} ${FILESYSTEM_POINTER}"
    if [ -z "$FILESYSTEM_POINTER" ]; then
        return
    elif [ -f $FILESYSTEM_POINTER ]; then
        logger " opening $FILESYSTEM_POINTER in editor"
        nohup alacritty --working-directory $(dirname $FILESYSTEM_POINTER) \
            --command zsh -c "$EDITOR $FILESYSTEM_POINTER" > /dev/null 2>&1 &
        sleep 0.1
        return
    elif [ -d $FILESYSTEM_POINTER ]; then
        logger " changing to directory: ${FILESYSTEM_POINTER}"
        cd $FILESYSTEM_POINTER
        selection=$(ls -lh ${LS_HIDDEN_ARG} --color=always \
            | fzf --ansi --nth 9 --reverse --header-lines=1 \
                --preview $HOME'/.config/sxhkd/fzf-file-preview.sh {9}' \
                --bind "ctrl-h:become(echo ${TOGGLE_HIDDEN_ACTION})" \
                --bind "alt-h:become(echo ..)" \
                --bind "alt-j:down" \
                --bind "alt-k:up" \
                --bind "alt-l:become(echo {})" \
            | awk '{print $NF}')

        logger "  current ${selection} and ${FILESYSTEM_POINTER}"
        if [ "$selection" = "${TOGGLE_HIDDEN_ACTION}" ]; then
            if [ -z "${LS_HIDDEN_ARG}" ]; then
                LS_HIDDEN_ARG="-A"
            else
                LS_HIDDEN_ARG=""
            fi
        elif [ -z "$selection" ]; then
            return
        else
            FILESYSTEM_POINTER=$(pwd)/$selection
            logger "   setting new pointer: ${FILESYSTEM_POINTER}"
        fi
    fi
done
