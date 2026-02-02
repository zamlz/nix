{
  pkgs,
  self,
  ...
}:
let
  colorScheme = (import (self + /lib/colorschemes.nix)).defaultColorScheme;
in
{
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
        modules-left = [
          "custom/system-info"
          "systemd-failed-units#system"
          "systemd-failed-units#user"
          "privacy"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "backlight"
          "battery"
          "network"
        ];
        "battery" = {
          format = "{capacity}% {time}";
          format-time = "{H}:{M}";
          tooltip-format = "Power: {power}W Health: {health}";
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
        "custom/system-info" = {
          format = "{}";
          interval = "once";
          exec = pkgs.writeShellScript "system-info" ''
            source /etc/os-release
            echo "$(whoami)@$(uname -n) :: $(uname -o) $(uname -r) :: ''${NAME} ''${VERSION}"
          '';
          tooltip = false;
        };
        "network" = {
          tooltip = false;
          format = "{ifname}: {essid} ({ipaddr})";
          format-disconnected = "";
        };
        "systemd-failed-units#system" = {
          hide-on-ok = true;
          system = true;
          user = false;
          format = "systemd: {nr_failed_system} failed units";
          format-ok = "";
        };
        "systemd-failed-units#user" = {
          hide-on-ok = true;
          system = false;
          user = true;
          format = "systemd-user: {nr_failed_user} failed units";
          format-ok = "";
        };
      };
      botBar = {
        class = "bot";
        layer = "top";
        position = "bottom";
        height = 32;
        modules-left = [ "niri/workspaces" ];
        modules-right = [
          "niri/window"
        ];
        "niri/workspaces" = {
          format = "{icon}{value}{icon}";
          format-icons = {
            focused = "<span color='${blue}'>\/</span>";
            default = " ";
          };
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Iosevka;
        background: ${background};
        color: ${foreground};
        padding-left: 8px;
        padding-right: 8px;
      }

      #battery {
        color: ${green};
      }

      #clock, #clock.calendar.today {
        color: ${blue};
      }

      #network {
        color: ${cyan};
      }

      #systemd-failed-units {
        color: ${red};
      }
    '';
  };
}
