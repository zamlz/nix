# NixOS Configuration

A (WIP) NixOS Configuration repo for all my systems.

## Usage (NixOS)

Install the nixos system. Note this command is hardware dependent. We use the
hostname to associate hardware.

```shell
sudo nixos-rebuild switch --flake .#${hostname}
```

If `nh` is availabe on the system, you can simply do

```shell
nh os switch .
```

## Usage (Other Linux or Mac)

Since the external linux system is managing the system software, we use
nix to manage the user software. This will need to have home-manager
installed in standalone mode.

```shell
home-manager switch --flake .#{username}
```

*Note, while it is typical to use `username` here, it is not
necessary. Refer to the `flake.nix` for the real name*

## New Installation Guide

First, install a minimal installation of NixOS.

Next, once you get into the system. Create a new entry for the system in the
`nixosConfigurations`. This will require copying the
`hardware-configuration.nix` file into the config as well.
Be sure to also go through the `configuration.nix` and set the relevent parameters
to build the same system.

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
