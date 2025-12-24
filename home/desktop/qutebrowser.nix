{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  colorScheme = (import ../../lib/colorschemes.nix).defaultColorScheme;
in
{
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = false;
    # Find available options here: https://qutebrowser.org/doc/help/settings.html
    settings = {
      auto_save.session = true;
      changelog_after_upgrade = "patch";
      colors = {
        hints = {
          bg = "${colorScheme.background}";
          fg = "${colorScheme.foreground}";
          match.fg = "${colorScheme.blue}";
        };
        completion = {
          fg = "${colorScheme.foreground}";
          match.fg = "${colorScheme.blue}";
          even.bg = "${colorScheme.background}";
          odd.bg = "${colorScheme.background}";
          category = {
            bg = "${colorScheme.black}";
            fg = "${colorScheme.foreground}";
          };
          item.selected = {
            bg = "${colorScheme.blue}";
            fg = "${colorScheme.background}";
            match.fg = "${colorScheme.foreground}";
            border.bottom = "${colorScheme.blue}";
            border.top = "${colorScheme.blue}";
          };
        };
        tabs = {
          even.bg = "${colorScheme.background}";
          even.fg = "${colorScheme.foreground}";
          odd.bg = "${colorScheme.background}";
          odd.fg = "${colorScheme.foreground}";
          selected = {
            even.bg = "#383838";
            even.fg = "${colorScheme.foreground}";
            odd.bg = "#383838";
            odd.fg = "${colorScheme.foreground}";
          };
        };
      };
      tabs = {
        tabs_are_windows = true;
        show = "multiple";
      };
      downloads.location.directory = "~/tmp";
      fonts = {
        default_size = "14pt";
        default_family = [ "Iosevka" ];
      };
    };
  };
}
