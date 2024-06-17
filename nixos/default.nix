{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./nix.nix
    ./users.nix
    ./core.nix
    ./boot.nix
    ./networking.nix
    ./audio.nix
    ./gui.nix
  ];
}
