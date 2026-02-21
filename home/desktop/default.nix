{
  pkgs,
  self,
  ...
}:
{
  imports = [
    (self + /home/options.nix)
    ./alacritty.nix
    ./feh.nix
    ./firefox.nix
    ./kitty.nix # [unused]
    ./mpv.nix
    ./qutebrowser.nix
    ./slippi.nix
    ./wayland
    ./x11
  ];

  home.packages = with pkgs; [
    navi-scripts
    # Fonts
    iosevka
    # Desktop Utilities
    arandr
    imagemagick
    qrencode
    maim # needed by sxhkd (screenshot script)
    wmctrl
    xclip # needed by sxhkd (screenshot script)
    xdotool
    # Entertainment
    spotify
    # DAW Software & derivatives
    puredata
    plugdata
    bitwig-studio
    vital
    mixxx
  ];
}
