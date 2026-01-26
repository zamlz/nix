{
  pkgs,
  ...
}:
let
  colorScheme = (import ../../../lib/colorschemes.nix).defaultColorScheme;
in
{
  # FIXME: Need configuration
  programs.waybar = with colorScheme; {
    enable = true;
    systemd = {
      enable = true;
      enableInspect = false;
    };
    settings = {
      topBar = {
        class = "top";
        layer = "top";
        position = "top";
        height = 32; # 3% of 1080p
        modules-left = [ "custom/system-info" ];
        modules-center = [ "clock" ];

        "custom/system-info" = {
          format = "{}";
          interval = "once";
          exec = pkgs.writeShellScript "system-info" ''
            echo " $(whoami)@$(uname -n)"
          '';
          tooltip = false;
        };

        "clock" = {
          interval = 1;
          format = "{:%B %d, %Y (%A) %I:%M:%S %p}";
          format-alt = "{:%Y-%m-%d %r}";
          tooltip-format = "{calendar}";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      };
      botBar = {
        class = "bot";
        layer = "top";
        position = "bottom";
        height = 32;
        modules-center = [ "niri/workspaces" ];
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Iosevka;
        background: ${background};
        color: ${foreground};
      }

      #clock, #clock.calendar.today {
        color: ${blue};
      }
    '';
  };
}
