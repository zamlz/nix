# NixOS Configuration

A (WIP) NixOS Configuration repo for all my systems.

## Basic Usage

Install the nixos system. Note this command is hardware dependent. We use the
hostname to associate hardware.

```shell
sudo nixos-rebuild switch --flake .#${hostname}
```

## New Installation Guide

First, install a minimal installation of NixOS.

Next, once you get into the system. Create a new entry for the system in the
`nixosConfigurations`. This will require copying the
`hardware-configuration.nix` file into the config as well.

Enable flakes on the original system. Add the following to the
`/etc/nixos/configuration.nix` file.

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
environment.systemPackages = with pkgs; [ git ];
```

Make sure to update the channels to unstable as well.

```shell
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nixos-rebuild switch --upgrade
```


## Misc

Refer to this for neovim
```
https://github.com/zamlz/nix/blob/007d7ffa9c244af4d539fa7b32e8cb2a76ae4d91/shell/neovim.nix
```
`
