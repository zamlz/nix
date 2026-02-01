{
  self,
  ...
}:
let
  colorScheme = (import (self + /lib/colorschemes.nix)).defaultColorScheme;
in
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    # systemctl --user add-wants niri.service noctalia.service
    settings = {
      bar = {
        position = "top";
        opacity = 0.9;
        margin = 8;
        radius = 12;
      };

      general = {
        animationSpeed = 1.0;
        shadow = true;
      };

      colors = {
        useWallpaperColors = false;
        dark = true;
        scheme = {
          inherit (colorScheme) background foreground;
          primary = colorScheme.blue;
          secondary = colorScheme.magenta;
          accent = colorScheme.yellow;
          error = colorScheme.red;
          success = colorScheme.green;
        };
      };

      wallpaper = {
        directory = "~/Pictures/wallpapers";
        fillMode = "fill";
      };

      launcher = {
        terminal = "footclient";
      };

      audio = {
        volumeStep = 5;
      };

      brightness = {
        step = 5;
      };
    };
  };
}
