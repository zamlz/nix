{
  pkgs,
  ...
}:
{
  # FIXME: use niri through niri-flakes for home manager support
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  home.packages = with pkgs; [
    hyprlax # potential wallpaper engine?
    # noctalia-shell # not in current flake revision
  ];

  # FIXME: Need configuration
  programs.waybar = {
    enable = true;
  };

  # FIXME: Doesn't appear
  programs.anyrun = {
    enable = true;
    config = {
      x = {
        fraction = 0.5;
      };
      y = {
        fraction = 0.3;
      };
      width = {
        fraction = 0.3;
      };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/librandr.so"
        "${pkgs.anyrun}/lib/libdictionary.so"
        "${pkgs.anyrun}/lib/libnix_run.so"
        "${pkgs.anyrun}/lib/libniri_focus.so"
      ];
    };
  };
}
