{ inputs, lib, config, pkgs, systemConfig, ... }: let
  colorScheme = (import ./colorschemes.nix).defaultColorScheme;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        live_config_reload = true;
      };
      colors = with colorScheme; {
        draw_bold_text_with_bright_colors = false;
        primary = {
          background = background;
          foreground = foreground;
        };
        cursor = {
          cursor = foreground;
          text = "CellForeground";
        };
        normal = {
          black = black;
          red = red;
          green = green;
          yellow = yellow;
          blue = blue;
          magenta = magenta;
          cyan = cyan;
          white = white;
        };
        bright = {
          black = blackAlt;
          red = redAlt;
          green = greenAlt;
          yellow = yellowAlt;
          blue = blueAlt;
          magenta = magentaAlt;
          cyan = cyanAlt;
          white = whiteAlt;
        };
      };

      cursor = {
        vi_mode_style = "Block";
        style = {
          blinking = "On";
          shape = "Beam";
        };
      };

      font = {
        size = 8.0 * systemConfig.fontScale;
        glyph_offset = {
          x = 0;
          y = 0;
        };
        normal = {
          family = "Iosevka";
          style = "Regular";
        };
        italic = {
          family = "Iosevka";
          style = "Italic";
        };
        bold = {
          family = "Iosevka";
          style = "Bold";
        };
        
        bold_italic = {
          family = "Iosevka";
          style = "Bold Italic";
        };
      };

      scrolling = {
        history = 100000;
        multiplier = 3;
      };

      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
      };

      window = {
        dynamic_padding = false;
        opacity = 1.0;
        padding = {
          x = 0;
          y = 0;
        };
      };
    };
  };
}
