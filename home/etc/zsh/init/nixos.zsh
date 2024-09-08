#!/usr/bin/env zsh

# A collection of useful utils for managing my NixOS installation

# A simple helper utility that will use `nvd` along with `nixos-rebuild`

xu() {
    nixos_old_generation=$(readlink -f /run/current-system)
    sudo nixos-rebuild switch --flake ".#$(hostname)" || return $?
    nixos_new_generation=$(readlink -f /run/current-system)
    nvd diff "$nixos_old_generation" "$nixos_new_generation"
}
