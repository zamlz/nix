{
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./feh.nix
    ./kitty.nix # [unused]
    ./mpv.nix
    ./wayland
    ./x11
    ./qutebrowser.nix
  ];

  home.packages = with pkgs; [
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
    # Web
    firefox
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
