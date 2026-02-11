#!/usr/bin/envzsh

# Helper functions for various USB related tasks

create-live-usb() {
    local image="$1"
    local target_path="$2"
    echo "Writing $image to $target_path"
    sudo pv "$image" -Yo "$target_path"
}
