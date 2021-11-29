#!/bin/sh

# Goto a particular workspace or make it if it doesn't exist

# Dependencies:
#   - wmctrl
#   - rofi

# Setup the logger
. $HOME/lib/shell/logging && eval "$(get_logger $0)"
logger "Initializing herbstluftwm window manager"

hc() {
    herbstclient $@
}

tag_list() {
    wmctrl -d | awk '{print $9}'
}

tag=$(tag_list | rofi -dmenu -i -p "Goto Tag")

if [ -z "$tag" ]; then
    logger "no tag selected, aborting..."
    exit 0
else
    logger "tag selected: $tag"
    hc use "$tag"
    error_code=$?
    if  [ $error_code -eq 3 ]; then
        fmt_tag=$(echo "[$tag]" | tr -t ' ' '-')
        logger "creating new workspace $fmt_tag"
        hc add "$fmt_tag"
        hc use "$fmt_tag"
    else
        logger "unknown error code: $error_code"
    fi
fi