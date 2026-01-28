{
  config,
  ...
}:
let
  colorScheme = (import ../../../lib/colorschemes.nix).defaultColorScheme;
  colors = builtins.mapAttrs (_: v: builtins.substring 1 (-1) v) colorScheme;
in
{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "Iosevka:size=${toString (10.0 * config.my.fontScale)}";
        selection-target = "clipboard";
      };
      cursor = {
        style = "beam";
        blink = "yes";
      };
      scrollback = {
        lines = 100000;
      };
      colors = with colors; {
        inherit foreground background;
        regular0 = black;
        regular1 = red;
        regular2 = green;
        regular3 = yellow;
        regular4 = blue;
        regular5 = magenta;
        regular6 = cyan;
        regular7 = white;
        bright0 = blackAlt;
        bright1 = redAlt;
        bright2 = greenAlt;
        bright3 = yellowAlt;
        bright4 = blueAlt;
        bright5 = magentaAlt;
        bright6 = cyanAlt;
        bright7 = whiteAlt;
      };
    };
  };
}
