{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./feh.nix
    ./herbstluftwm.nix
    ./kitty.nix # [unused]
    ./mpv.nix
    ./polybar
    ./qutebrowser.nix
    ./sxhkd
    ./xinit
  ];
}
