{
  inputs,
  pkgs,
  config,
  ...
}:
let
  # Terminal prompt launcher using navi-term
  # Creates a floating terminal window with specific dimensions and font size
  termPromptLauncher =
    {
      script,
      lines,
      columns,
      fontSize,
    }:
    let
      scaledFontSize = builtins.toString (config.my.fontScale * fontSize);
    in
    [
      "navi-term"
      "--app-id"
      "termprompt"
      "--lines"
      (toString lines)
      "--columns"
      (toString columns)
      "--font-size"
      scaledFontSize
      "-e"
      "zsh"
      "-c"
      "${script}"
    ];
in
{
  imports = [ inputs.niri.homeModules.niri ];

  # Script to resize niri windows on order of n/x, (n+1)/x, ... x/x
  # where x is the number in the script file name
  xdg.configFile =
    let
      scripts = [
        "n"
        "1"
        "2"
        "3"
        "4"
        "5"
      ];
      mkScript = n: {
        name = "niri/niri-cycle-${n}.sh";
        value = {
          source = ./scripts/niri-cycle-${n}.sh;
          executable = true;
        };
      };
    in
    builtins.listToAttrs (map mkScript scripts);
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;

    settings = {
      animations.enable = false;
      input = {
        keyboard = {
          xkb = {
            options = "caps:escape";
          };
          # track-layout = "global";
          repeat-delay = 400;
          repeat-rate = 50;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      layout = {
        gaps = 0;
        background-color = "#00000000";
        center-focused-column = "never";
        always-center-single-column = true;

        preset-column-widths = [
          { proportion = 0.5; }
          { proportion = 1.0; }
        ];

        default-column-width.proportion = pkgs.lib.mkDefault 1.0;

        preset-window-heights = [
          { proportion = 0.5; }
          { proportion = 1.0; }
        ];

        focus-ring.enable = false;

        border = {
          enable = true;
          width = 4;
          active = {
            gradient = {
              from = "#f00a";
              to = "#0f0a";
              angle = 45;
              in' = "oklch longer hue";
            };
          };
          inactive = {
            color = "#282828";
          };
        };

        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };

      prefer-no-csd = true;

      spawn-at-startup = [
        # FIXME: If NIRI has a systemd target, then we should retarget this service
        { sh = "systemctl --user restart waybar.service"; }
        # FIXME: Create a systemd unit for swaybg or find a different wallpaper service
        { sh = "swaybg --mode fill --image ~/.config/wallpaper"; }
      ];

      screenshot-path = "~/tmp/screenshot-%Y-%m-%d-%H-%M-%S.png";

      window-rules = [
        {
          matches = [
            {
              app-id = "^firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
        {
          matches = [
            { app-id = "^termprompt$"; }
            { title = "^feh:pass:.*$"; }
          ];
          open-floating = true;
          open-focused = true;
        }
        {
          matches = [
            { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
            { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
          ];
          block-out-from = "screen-capture";
        }
      ];

      layer-rules = [
        {
          matches = [
            { namespace = "^wallpaper$"; }
          ];
          place-within-backdrop = true;
        }
        {
          matches = [
            { namespace = "^waybar$"; }
          ];
          place-within-backdrop = false;
        }
      ];

      binds = {
        "Mod+Ctrl+Alt+Shift+Slash".action.show-hotkey-overlay = { };

        "Mod+Space" = {
          action.toggle-overview = { };
          repeat = false;
        };

        "Mod+Q" = {
          action.close-window = { };
          repeat = false;
        };

        # Focus navigation
        "Mod+H".action.focus-column-left = { };
        "Mod+J".action.focus-window-or-workspace-down = { };
        "Mod+K".action.focus-window-or-workspace-up = { };
        "Mod+L".action.focus-column-right = { };

        "Mod+Home".action.focus-column-first = { };
        "Mod+End".action.focus-column-last = { };

        "Mod+BracketRight".action.focus-workspace-down = { };
        "Mod+BracketLeft".action.focus-workspace-up = { };

        # FIXME: Enable when I use multi-monitors
        # "Mod+Ctrl+H".action.focus-monitor-left = { };
        # "Mod+Ctrl+J".action.focus-monitor-down = { };
        # "Mod+Ctrl+K".action.focus-monitor-up = { };
        # "Mod+Ctrl+L".action.focus-monitor-right = { };

        # Move operations
        "Mod+Shift+H".action.move-column-left = { };
        "Mod+Shift+J".action.move-window-down-or-to-workspace-down = { };
        "Mod+Shift+K".action.move-window-up-or-to-workspace-up = { };
        "Mod+Shift+L".action.move-column-right = { };

        "Mod+Ctrl+Home".action.move-column-to-first = { };
        "Mod+Ctrl+End".action.move-column-to-last = { };

        "Mod+Ctrl+BracketRight".action.move-column-to-workspace-down = { };
        "Mod+Ctrl+BracketLeft".action.move-column-to-workspace-up = { };

        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

        "Mod+Shift+BracketRight".action.move-workspace-down = { };
        "Mod+Shift+BracketLeft".action.move-workspace-up = { };

        # Wheel scroll bindings
        "Mod+WheelScrollDown" = {
          action.focus-workspace-down = { };
          cooldown-ms = 150;
        };
        "Mod+WheelScrollUp" = {
          action.focus-workspace-up = { };
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          action.move-column-to-workspace-down = { };
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          action.move-column-to-workspace-up = { };
          cooldown-ms = 150;
        };

        "Mod+WheelScrollRight".action.focus-column-right = { };
        "Mod+WheelScrollLeft".action.focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

        # Workspace switching
        "Alt+1".action.focus-workspace = 1;
        "Alt+2".action.focus-workspace = 2;
        "Alt+3".action.focus-workspace = 3;
        "Alt+4".action.focus-workspace = 4;
        "Alt+5".action.focus-workspace = 5;
        "Alt+6".action.focus-workspace = 6;
        "Alt+7".action.focus-workspace = 7;
        "Alt+8".action.focus-workspace = 8;
        "Alt+9".action.focus-workspace = 9;
        "Alt+0".action.focus-workspace = 10;

        "Alt+Shift+1".action.move-column-to-workspace = 1;
        "Alt+Shift+2".action.move-column-to-workspace = 2;
        "Alt+Shift+3".action.move-column-to-workspace = 3;
        "Alt+Shift+4".action.move-column-to-workspace = 4;
        "Alt+Shift+5".action.move-column-to-workspace = 5;
        "Alt+Shift+6".action.move-column-to-workspace = 6;
        "Alt+Shift+7".action.move-column-to-workspace = 7;
        "Alt+Shift+8".action.move-column-to-workspace = 8;
        "Alt+Shift+9".action.move-column-to-workspace = 9;
        "Alt+Shift+0".action.move-column-to-workspace = 10;

        "Mod+Grave".action.focus-workspace-previous = { };

        # Column operations
        "Mod+Ctrl+H".action.consume-or-expel-window-left = { };
        "Mod+Ctrl+L".action.consume-or-expel-window-right = { };

        "Mod+Ctrl+K".action.consume-window-into-column = { };
        "Mod+Ctrl+J".action.expel-window-from-column = { };

        "Mod+C".action.center-column = { };
        "Mod+Ctrl+C".action.center-visible-columns = { };

        # Resize and layout
        # FIXME: Replace with resize rotation scripts
        "Mod+1" = {
          hotkey-overlay.title = "Cycle column width by 1sts";
          action.spawn = [ "${config.xdg.configHome}/niri/niri-cycle-1.sh" ];
        };
        "Mod+2" = {
          hotkey-overlay.title = "Cycle column width by 2nds";
          action.spawn = [ "${config.xdg.configHome}/niri/niri-cycle-2.sh" ];
        };
        "Mod+3" = {
          hotkey-overlay.title = "Cycle column width by 3rds";
          action.spawn = [ "${config.xdg.configHome}/niri/niri-cycle-3.sh" ];
        };
        "Mod+4" = {
          hotkey-overlay.title = "Cycle column width by 4ths";
          action.spawn = [ "${config.xdg.configHome}/niri/niri-cycle-4.sh" ];
        };
        "Mod+5" = {
          hotkey-overlay.title = "Cycle column width by 5ths";
          action.spawn = [ "${config.xdg.configHome}/niri/niri-cycle-5.sh" ];
        };

        "Mod+R".action.switch-preset-column-width = { };
        "Mod+Shift+R".action.switch-preset-window-height = { };
        "Mod+Ctrl+R".action.reset-window-height = { };

        "Mod+T".action.maximize-column = { };
        "Mod+Shift+T".action.fullscreen-window = { };
        "Mod+Ctrl+T".action.expand-column-to-available-width = { };

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Floating
        "Mod+V".action.toggle-window-floating = { };
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

        "Mod+B".action.toggle-column-tabbed-display = { };

        # Screenshots
        "Print".action.screenshot = { };
        "Ctrl+Print".action.screenshot-screen = { };
        "Alt+Print".action.screenshot-window = { };

        "Mod+Shift+I" = {
          action.toggle-keyboard-shortcuts-inhibit = { };
          allow-inhibiting = false;
        };

        # System Controls
        "Mod+Ctrl+Alt+Escape" = {
          hotkey-overlay.title = "navi-system";
          action.spawn = termPromptLauncher {
            script = "navi-system";
            lines = 6;
            columns = 40;
            fontSize = 12;
          };
        };
        "Mod+Ctrl+Shift+Escape".action.power-off-monitors = { };

        # Launchers
        "Mod+Return" = {
          hotkey-overlay.title = "navi-term";
          action.spawn = [ "navi-term" ];
        };
        "Mod+Shift+Return" = {
          hotkey-overlay.title = "Identical navi-term";
          action.spawn = [
            "navi-term"
            "--inherit-cwd"
          ];
        };
        "Mod+E" = {
          hotkey-overlay.title = "navi-launcher";
          action.spawn = termPromptLauncher {
            script = "navi-launcher";
            lines = 16;
            columns = 80;
            fontSize = 9;
          };
        };

        # External Tools
        "Mod+G" = {
          hotkey-overlay.title = "navi-git";
          action.spawn = termPromptLauncher {
            script = "navi-git";
            lines = 20;
            columns = 124;
            fontSize = 8;
          };
        };
        "Mod+Shift+G" = {
          hotkey-overlay.title = "navi-git open-dir";
          action.spawn = termPromptLauncher {
            script = "navi-git --open-dir";
            lines = 20;
            columns = 124;
            fontSize = 8;
          };
        };
        "Mod+M" = {
          hotkey-overlay.title = "navi-man";
          action.spawn = termPromptLauncher {
            script = "navi-man";
            lines = 20;
            columns = 124;
            fontSize = 8;
          };
        };
        "Mod+Z" = {
          hotkey-overlay.title = "navi-calculator";
          action.spawn = termPromptLauncher {
            script = "navi-calculator";
            lines = 12;
            columns = 64;
            fontSize = 12;
          };
        };

        # Password Store
        "Mod+P" = {
          hotkey-overlay.title = "navi-pass";
          action.spawn = termPromptLauncher {
            script = "navi-pass";
            lines = 16;
            columns = 80;
            fontSize = 9;
          };
        };
        "Mod+Shift+P" = {
          hotkey-overlay.title = "navi-pass qrcode";
          action.spawn = termPromptLauncher {
            script = "navi-pass --qrcode";
            lines = 16;
            columns = 80;
            fontSize = 9;
          };
        };

        # Notes
        "Mod+N" = {
          hotkey-overlay.title = "notes-log-journal";
          action.spawn = termPromptLauncher {
            script = "notes-log-journal";
            lines = 20;
            columns = 90;
            fontSize = 8;
          };
        };
        "Mod+Y" = {
          hotkey-overlay.title = "navi-todo";
          action.spawn = termPromptLauncher {
            script = "navi-todo";
            lines = 30;
            columns = 128;
            fontSize = 8;
          };
        };

        # Window/Workspace management (commented - conflicts with existing binds)
        "Mod+W" = {
          hotkey-overlay.title = "navi-window";
          action.spawn = termPromptLauncher {
            script = "navi-window";
            lines = 20;
            columns = 128;
            fontSize = 9;
          };
        };
        "Mod+Slash" = {
          hotkey-overlay.title = "navi-workspace jump";
          action.spawn = termPromptLauncher {
            script = "navi-workspace --jump";
            lines = 10;
            columns = 120;
            fontSize = 9;
          };
        };
        "Mod+Shift+Slash" = {
          hotkey-overlay.title = "navi-workspace move-window";
          action.spawn = termPromptLauncher {
            script = "navi-workspace --move-window";
            lines = 10;
            columns = 120;
            fontSize = 9;
          };
        };
        "Mod+BackSpace" = {
          hotkey-overlay.title = "navi-workspace delete";
          action.spawn = termPromptLauncher {
            script = "navi-workspace --delete";
            lines = 10;
            columns = 120;
            fontSize = 9;
          };
        };

        # Filesystem
        "Mod+A" = {
          hotkey-overlay.title = "navi-file-explorer";
          action.spawn = termPromptLauncher {
            script = "navi-file-explorer";
            lines = 30;
            columns = 140;
            fontSize = 8;
          };
        };
        "Mod+S" = {
          hotkey-overlay.title = "navi-ripgrep";
          action.spawn = termPromptLauncher {
            script = "navi-ripgrep";
            lines = 30;
            columns = 140;
            fontSize = 8;
          };
        };
        "Mod+D" = {
          hotkey-overlay.title = "navi-file-open directory";
          action.spawn = termPromptLauncher {
            script = "navi-file-open --directory";
            lines = 30;
            columns = 140;
            fontSize = 8;
          };
        };
        "Mod+F" = {
          hotkey-overlay.title = "navi-file-open file";
          action.spawn = termPromptLauncher {
            script = "navi-file-open --file";
            lines = 30;
            columns = 140;
            fontSize = 8;
          };
        };

        # Filesystem Global search variants
        "Mod+Shift+A" = {
          hotkey-overlay.title = "navi-file-explorer [global]";
          action.spawn = termPromptLauncher {
            script = "navi-file-explorer --global-search";
            lines = 35;
            columns = 164;
            fontSize = 8;
          };
        };
        "Mod+Shift+S" = {
          hotkey-overlay.title = "navi-ripgrep [global]";
          action.spawn = termPromptLauncher {
            script = "navi-ripgrep --global-search";
            lines = 35;
            columns = 164;
            fontSize = 8;
          };
        };
        "Mod+Shift+D" = {
          hotkey-overlay.title = "navi-file-open directory [global]";
          action.spawn = termPromptLauncher {
            script = "navi-file-open --directory --global-search";
            lines = 35;
            columns = 164;
            fontSize = 8;
          };
        };
        "Mod+Shift+F" = {
          hotkey-overlay.title = "navi-file-open file [global]";
          action.spawn = termPromptLauncher {
            script = "navi-file-open --file --global-search";
            lines = 35;
            columns = 164;
            fontSize = 8;
          };
        };

        # Media keys
        "XF86AudioRaiseVolume" = {
          action.spawn = [
            "sh"
            "-c"
            "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
          ];
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action.spawn = [
            "sh"
            "-c"
            "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
          ];
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action.spawn = [
            "sh"
            "-c"
            "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ];
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          action.spawn = [
            "sh"
            "-c"
            "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ];
          allow-when-locked = true;
        };

        "XF86AudioPlay" = {
          action.spawn = [
            "sh"
            "-c"
            "playerctl play-pause"
          ];
          allow-when-locked = true;
        };
        "XF86AudioStop" = {
          action.spawn = [
            "sh"
            "-c"
            "playerctl stop"
          ];
          allow-when-locked = true;
        };
        "XF86AudioPrev" = {
          action.spawn = [
            "sh"
            "-c"
            "playerctl previous"
          ];
          allow-when-locked = true;
        };
        "XF86AudioNext" = {
          action.spawn = [
            "sh"
            "-c"
            "playerctl next"
          ];
          allow-when-locked = true;
        };

        "XF86MonBrightnessUp" = {
          action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "+10%"
          ];
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "10%-"
          ];
          allow-when-locked = true;
        };
      };
    };
  };
}
