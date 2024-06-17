# NixOS Configuration

A (WIP) NixOS Configuration repo for all my systems.

## TODOs

- [x] Use `flake.nix` 
- [ ] Control backlight with keyboard buttons
- [x] Control Volume with keyboard buttons
- [ ] Investigate pipewire
- [ ] Disk Wipe on Reboot
- [ ] Full Disk Encryption
- [ ] Use `deploy-rs`

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
