{
  pkgs,
  ...
}:
let
  removeHash = str: builtins.replaceStrings [ "#" ] [ "" ] str;
  colorScheme = (import ../../../lib/colorschemes.nix).defaultColorScheme;
  noHashColorScheme = builtins.mapAttrs (name: value: removeHash value) colorScheme;
in
{
  programs.swaylock = {
    enable = true;
    settings = with noHashColorScheme; {
      ignore-empty-password = true;
      show-failed-attempts = true;
      image = "~/.config/wallpaper";
      hide-keyboard-layout = true;
      disable-caps-lock-text = true;
      bs-hl-color = magenta;
      font-size = 48;
      indicator-idle-visible = false;
      indicator-radius = 80;
      indicator-thickness = 12;
    };
  };
}
