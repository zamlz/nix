{
  pkgs,
  ...
}:
let
  removeHash = str: builtins.replaceStrings ["#"] [""] str;
  colorScheme = (import ../../../lib/colorschemes.nix).defaultColorScheme;
  noHashColorScheme = builtins.mapAttrs (name: value: removeHash value) colorScheme;
in
{
  # FIXME: use niri through niri-flakes for home manager support
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  home.packages = with pkgs; [
    # hyprlax
    swaybg
    xwayland-satellite
    # noctalia-shell # not in current flake revision
  ];

  # FIXME: Need configuration
  programs.waybar = {
    enable = true;
  };

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

  # FIXME: Doesn't appear
  # programs.anyrun = {
  #   enable = false;
  #   config = {
  #     x = {
  #       fraction = 0.5;
  #     };
  #     y = {
  #       fraction = 0.3;
  #     };
  #     width = {
  #       fraction = 0.3;
  #     };
  #     hideIcons = false;
  #     ignoreExclusiveZones = false;
  #     layer = "overlay";
  #     hidePluginInfo = false;
  #     closeOnClick = false;
  #     showResultsImmediately = false;
  #     maxEntries = null;
  #     plugins = [
  #       "${pkgs.anyrun}/lib/libapplications.so"
  #       # "${pkgs.anyrun}/lib/libsymbols.so"
  #       # "${pkgs.anyrun}/lib/librink.so"
  #       # "${pkgs.anyrun}/lib/libshell.so"
  #       # "${pkgs.anyrun}/lib/libtranslate.so"
  #       # "${pkgs.anyrun}/lib/librandr.so"
  #       # "${pkgs.anyrun}/lib/libdictionary.so"
  #       # "${pkgs.anyrun}/lib/libnix_run.so"
  #       # "${pkgs.anyrun}/lib/libniri_focus.so"
  #     ];
  #   };
  # };
}
