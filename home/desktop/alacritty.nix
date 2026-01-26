{
  systemConfig,
  ...
}:
let
  colorScheme = (import ../../lib/colorschemes.nix).defaultColorScheme;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        live_config_reload = true;
      };
      colors = with colorScheme; {
        draw_bold_text_with_bright_colors = false;
        primary = {
          inherit background;
          inherit foreground;
        };
        cursor = {
          cursor = foreground;
          text = "CellForeground";
        };
        normal = {
          inherit black;
          inherit red;
          inherit green;
          inherit yellow;
          inherit blue;
          inherit magenta;
          inherit cyan;
          inherit white;
        };
        bright = {
          inherit black;
          inherit red;
          inherit green;
          inherit yellow;
          inherit blue;
          inherit magenta;
          inherit cyan;
          inherit white;
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
        size = 10.0 * systemConfig.fontScale;
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
