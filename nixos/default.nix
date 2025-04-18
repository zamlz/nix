{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./audio.nix
    ./core.nix
    ./docker.nix
    ./gui.nix
    ./networking.nix
    ./nix.nix
    ./printing.nix
    ./users.nix
    ./security.nix
  ];
}
