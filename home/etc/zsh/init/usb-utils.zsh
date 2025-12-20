#!/usr/bin/envzsh

# Helper functions for various USB related tasks

create-live-usb() {
    local image="$1"
    local target_path="$2"
    echo "Writing $1 to $2"
    sudo pv "$1" -Yo
}
