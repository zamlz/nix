{
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./feh.nix
    ./herbstluftwm.nix
    ./kitty.nix # [unused]
    ./mpv.nix
    ./polybar
    ./wayland
    ./qutebrowser.nix
    ./sxhkd
    ./xinit
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
