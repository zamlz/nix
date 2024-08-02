{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./docker.nix
    ./nix.nix
    ./users.nix
    ./core.nix
    ./boot.nix
    ./networking.nix
    ./audio.nix
    ./gui.nix
  ];
}
