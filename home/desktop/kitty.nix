{
  config,
  self,
  ...
}:
let
  colorScheme = (import (self + /lib/colorschemes.nix)).defaultColorScheme;
in
{
  programs.kitty = {
    # TODO: explore kitty remote-control featuers and cloning
    enable = true;
    font = {
      name = "Iosevka";
      size = 8.0 * config.my.fontScale;
    };

    settings = {
      # Fonts
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      # Terminal bell
      enable_audio_bell = false;
      window_alert_on_bell = true;

      # Window layout
      remember_window_size = false;
      confirm_os_window_close = -1;
      window_padding_width = 0;

      # Advanced
      close_on_child_death = false;
      allow_remote_control = false;

      # Colorscheme
      dynamic_background_opacity = true;
      background_opacity = 1.0;
      background_blur = 0;

      # Mouse
      mouse_hide_wait = -1.0;
    };

    shellIntegration = {
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    extraConfig = with colorScheme; ''
      foreground ${foreground}
      background ${background}
      color0  ${black}
      color1  ${red}
      color2  ${green}
      color3  ${yellow}
      color4  ${blue}
      color5  ${magenta}
      color6  ${cyan}
      color7  ${white}
      color8  ${blackAlt}
      color9  ${redAlt}
      color10 ${greenAlt}
      color11 ${yellowAlt}
      color12 ${blueAlt}
      color13 ${magentaAlt}
      color14 ${cyanAlt}
      color15 ${whiteAlt}
    '';
  };
}
