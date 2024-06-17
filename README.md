# NixOS Configuration

A (WIP) NixOS Configuration repo for all my systems.

## Usage

Install the nixos system. Note this command is hardware dependent. We use the
hostname to associate hardware.

```shell
sudo nixos-rebuild switch --flake .#${hostname}
```


Install the home-manager configuration

```shell
home-manager switch --flake .#zamlz
```

## TODOs

### NixOS
- [x] Use `flake.nix` 
- [ ] Control backlight with keyboard buttons
- [x] Control Volume with keyboard buttons
- [ ] Investigate pipewire
- [ ] Disk Wipe on Reboot
- [ ] Full Disk Encryption
- [ ] Use `deploy-rs`
