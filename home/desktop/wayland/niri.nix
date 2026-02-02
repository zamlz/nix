{ pkgs, config, ... }:
let
  # Terminal prompt launcher for foot
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
      font = "Iosevka:size=${scaledFontSize}";
    in
    [
      "footclient"
      "--app-id=termprompt"
      "--window-size-chars=${toString columns}x${toString lines}"
      "--override=main.font=${font}"
    ]
    ++ script;
in
{
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;

    settings = {
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
        gaps = 16;
        background-color = "#00000000";
        center-focused-column = "never";
        always-center-single-column = true;

        preset-column-widths = [
          { proportion = 1 / 3.0; }
          { proportion = 1 / 2.0; }
          { proportion = 2 / 3.0; }
        ];

        default-column-width = {
          proportion = 1 / 2.0;
        };

        preset-window-heights = [
          { proportion = 1 / 3.0; }
          { proportion = 1 / 2.0; }
          { proportion = 2 / 3.0; }
          { proportion = 1.0; }
        ];

        focus-ring = {
          enable = false;
        };

        border = {
          enable = true;
          width = 6;
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
          left = 16;
          right = 16;
          top = 8;
          bottom = 8;
        };
      };

      prefer-no-csd = true;

      spawn-at-startup = [
        # FIXME: If NIRI has a systemd target, then we should retarget this service
        { sh = "systemctl --user restart waybar.service"; }
        { sh = "systemctl --user start foot-server.service"; }
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
        {
          matches = [
            { namespace = "^noctalia$"; }
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

        "Mod+Ctrl+H".action.focus-monitor-left = { };
        "Mod+Ctrl+J".action.focus-monitor-down = { };
        "Mod+Ctrl+K".action.focus-monitor-up = { };
        "Mod+Ctrl+L".action.focus-monitor-right = { };

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
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;

        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+0".action.move-column-to-workspace = 10;

        "Mod+Grave".action.focus-workspace-previous = { };

        # Column operations
        "Mod+Comma".action.consume-or-expel-window-left = { };
        "Mod+Period".action.consume-or-expel-window-right = { };

        "Mod+Shift+Comma".action.consume-window-into-column = { };
        "Mod+Shift+Period".action.expel-window-from-column = { };

        # Resize and layout
        "Mod+R".action.switch-preset-column-width = { };
        "Mod+Shift+R".action.switch-preset-window-height = { };
        "Mod+Ctrl+R".action.reset-window-height = { };
        "Mod+T".action.maximize-column = { };
        "Mod+Shift+T".action.fullscreen-window = { };
        "Mod+Ctrl+T".action.expand-column-to-available-width = { };

        "Mod+C".action.center-column = { };
        "Mod+Ctrl+C".action.center-visible-columns = { };

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Floating
        "Mod+V".action.toggle-window-floating = { };
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

        "Mod+W".action.toggle-column-tabbed-display = { };

        # Screenshots
        "Print".action.screenshot = { };
        "Ctrl+Print".action.screenshot-screen = { };
        "Alt+Print".action.screenshot-window = { };

        "Mod+Shift+I" = {
          action.toggle-keyboard-shortcuts-inhibit = { };
          allow-inhibiting = false;
        };

        # System Controls
        "Mod+Ctrl+Alt+Escape".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/system_manager.py" ];
          lines = 6;
          columns = 40;
          fontSize = 12;
        };
        "Mod+Ctrl+Shift+Escape".action.power-off-monitors = { };

        # Launchers
        "Mod+Return".action.spawn = [ "footclient" ];
        "Mod+E".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/fzf-program-launcher.sh" ];
          lines = 16;
          columns = 80;
          fontSize = 9;
        };

        # External Tools
        "Mod+G".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/git_manager.py" ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+Shift+G".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/git_manager.py"
            "--open-dir"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+M".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/man_open.py" ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+Z".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/calculator.py" ];
          lines = 12;
          columns = 96;
          fontSize = 12;
        };

        # Password Store
        "Mod+P".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/password-store.py" ];
          lines = 14;
          columns = 100;
          fontSize = 9;
        };
        "Mod+Shift+P".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/password-store.py"
            "--qrcode"
          ];
          lines = 14;
          columns = 100;
          fontSize = 9;
        };

        # Notes
        "Mod+N".action.spawn = termPromptLauncher {
          script = [ "$HOME/usr/notes/bin/notes log" ];
          lines = 20;
          columns = 128;
          fontSize = 9;
        };

        # Window/Workspace management (commented - conflicts with existing binds)
        # "Mod+W".action.spawn = termPromptLauncher {
        #   script = [ "${config.xdg.configHome}/scripts/window_switcher.py" ];
        #   lines = 20; columns = 128; fontSize = 9;
        # };
        # "Mod+Slash".action.spawn = termPromptLauncher {
        #   script = [ "${config.xdg.configHome}/scripts/workspace_manager.py" "--jump" ];
        #   lines = 10; columns = 120; fontSize = 9;
        # };
        # "Mod+Shift+Slash".action.spawn = termPromptLauncher {
        #   script = [ "${config.xdg.configHome}/scripts/workspace_manager.py" "--move-window" ];
        #   lines = 10; columns = 120; fontSize = 9;
        # };
        # "Mod+BackSpace".action.spawn = termPromptLauncher {
        #   script = [ "${config.xdg.configHome}/scripts/workspace_manager.py" "--delete" ];
        #   lines = 10; columns = 120; fontSize = 9;
        # };

        # Filesystem
        "Mod+A".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/file_system_explorer.py" ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+S".action.spawn = termPromptLauncher {
          script = [ "${config.xdg.configHome}/scripts/ripgrep.py" ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+D".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/file_system_open.py"
            "--directory"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+F".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/file_system_open.py"
            "--file"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };

        # Filesystem Global search variants
        "Mod+Shift+A".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/file_system_explorer.py"
            "--global-search"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+Shift+S".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/ripgrep.py"
            "--global-search"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+Shift+D".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/file_system_open.py"
            "--directory"
            "--global-search"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
        };
        "Mod+Shift+F".action.spawn = termPromptLauncher {
          script = [
            "${config.xdg.configHome}/scripts/file_system_open.py"
            "--file"
            "--global-search"
          ];
          lines = 35;
          columns = 164;
          fontSize = 8;
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
