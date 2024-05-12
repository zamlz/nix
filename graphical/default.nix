{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./xorg/herbstluftwm.nix
    ./xorg/picom.nix
    ./xorg/polybar.nix
    ./xorg/qtile
    ./xorg/sxhkd.nix
    ./xorg/xinit.nix
    ./wayland
  ];
}

