{
  pkgs,
  self,
  ...
}:
let
  colorScheme = (import (self + /lib/colorschemes.nix)).defaultColorScheme;
in
{
  xdg.configFile."polybar/kernel_info.sh" = {
    source = ./kernel_info.sh;
    executable = true;
    text = ''
      #!/usr/bin/env sh
      # userathost with kernel info
      echo "$(whoami)@$(uname -n) :: $(uname -o) $(uname -r)"
    '';
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      pulseSupport = true;
    };
    # Do not let polybar start itself. Let the autostart script deal with it
    script = "";
    config =
      let
        barConfig =
          {
            placement,
            left-modules,
            center-modules,
            right-modules,
          }:
          {
            width = "100%";
            height = "3%";
            radius = 0;
            font-0 = "Iosevka:size=14";
            separator = " ";
            background = "${colorScheme.background}";
            foreground = "${colorScheme.foreground}";
            padding = 2;
            module-margin = 1;
            border-size = 0;
            border-color = "${colorScheme.foreground}";
            bottom = placement == "bottom";
            modules-left = left-modules;
            modules-center = center-modules;
            modules-right = right-modules;
          };

        batteryConfig = battery: {
          type = "internal/battery";
          full-at = 99;
          low-at = 10;
          inherit battery;
          adapter = "";
          poll-interval = 5;
          time-format = "%H:%M";
          format-background = "${colorScheme.background}";
          format-foreground = "${colorScheme.foreground}";
          format-charging = "<label-charging>";
          format-discharging = "<label-discharging>";
          format-full = "<label-full>";
          format-low = "<label-low> <animation-low>";
          label-full = "%percentage%!";
          label-full-foreground = "${colorScheme.white}";
          label-charging = "%percentage%* %time%";
          label-charging-foreground = "${colorScheme.greenAlt}";
          label-discharging = "%percentage%% %time%";
          label-discharging-foreground = "${colorScheme.green}";
          label-low = "%percentage%% %time%";
          label-low-foreground = "${colorScheme.red}";
          animation-low-0 = "(LOW BATTERY)";
          animation-low-1 = "( . . . . . )";
          animation-low-framerate = 400;
          animation-low-foreground = "${colorScheme.red}";
        };

        dateConfig = {
          type = "internal/date";
          internal = 1;
          date = "%B %d, %Y (%A)";
          time = "%l:%M:%S %p";
          date-alt = "%Y-%m-%d";
          time-alt = "%r";
          label = "%date% %time%";
          label-foreground = "${colorScheme.blue}";
        };

        workspaceConfig = {
          type = "internal/xworkspaces";
          pin-workspaces = false;
          enable-click = true;
          enable-scroll = true;
          format = "<label-state>";
          format-background = "${colorScheme.background}";
          format-foreground = "${colorScheme.foreground}";
          label-monitor = "%name%";
          label-monitor-background = "${colorScheme.background}";
          label-monitor-foreground = "${colorScheme.red}";
          label-active = " %index%:%name% ";
          label-active-background = "${colorScheme.background}";
          label-active-foreground = "${colorScheme.blue}";
          label-occupied = " %index%:%name% ";
          label-occupied-background = "${colorScheme.background}";
          label-occupied-foreground = "${colorScheme.white}";
          label-urgent = " %index%:%name% ";
          label-urgent-background = "${colorScheme.background}";
          label-urgent-foreground = "${colorScheme.yellow}";
          label-empty = " %index%:%name% ";
          label-empty-background = "${colorScheme.background}";
          label-empty-foreground = "#484848";
        };

        systemInfoConfig = {
          type = "custom/script";
          # FIXME: can I get this to use xdg.configFile in the future?
          exec = "~/.config/polybar/kernel_info.sh";
          interval = 90;
          format = "<label>";
          label-foreground = "${colorScheme.foreground}";
        };

        cpuConfig = {
          type = "internal/cpu";
          interval = 1;
          warn-percentage = 50;
          format = "";
          format-warn = "<label-warn>";
          label-warn = "cpu:%percentage%%";
          label-warn-foreground = "${colorScheme.red}";
        };

        memoryConfig = {
          type = "internal/memory";
          interval = 1;
          warn-percentage = 75;
          format = "";
          format-warn = "<label-warn>";
          label-warn = "mem:%percentage_used%%(%percentage_swap_used%%)";
          label-warn-foreground = "${colorScheme.red}";
        };

        wiredConfig = {
          type = "internal/network";
          interface-type = "wired";
          label-connected = "%ifname%: (%local_ip%)";
          label-connected-foreground = "${colorScheme.cyan}";
        };

        wirelessConfig = {
          type = "internal/network";
          interface-type = "wireless";
          label-connected = "%ifname%: %essid% (%local_ip%)";
          label-connected-foreground = "${colorScheme.cyan}";
        };

        windowConfig = {
          type = "internal/xwindow";
          format = "<label>";
          label = "%title%";
          label-foreground = "${colorScheme.foreground}";
        };

        backlightConfig = {
          type = "internal/backlight";
          format = "<label>";
          label = "%percentage%%";
          label-foreground = "${colorScheme.foreground}";
          enable-scroll = true;
        };

        pulseaudioVolumeConfig = {
          type = "internal/pulseaudio";
          interval = 5;
          format-volume = "<label-volume>";
          format-muted = "<label-muted>";
          label-volume = "[%decibels% dB]";
          label-volume-foreground = "${colorScheme.foreground}";
          label-muted = "[MUTED %decibels% dB]";
          label-muted-foreground = "${colorScheme.red}";
        };
      in
      {
        "bar/top" = barConfig {
          placement = "top";
          left-modules = "kernel";
          center-modules = "date";
          right-modules = "volume backlight battery1 battery0 wired wireless";
        };

        "bar/bot" = barConfig {
          placement = "bottom";
          left-modules = "workspace";
          center-modules = "";
          right-modules = "cpu memory window";
        };

        "settings" = {
          pseudo-transparency = true;
        };

        "module/battery0" = batteryConfig "BAT0";
        "module/battery1" = batteryConfig "BAT1";
        "module/cpu" = cpuConfig;
        "module/memory" = memoryConfig;
        "module/backlight" = backlightConfig;
        "module/wired" = wiredConfig;
        "module/wireless" = wirelessConfig;
        "module/date" = dateConfig;
        "module/kernel" = systemInfoConfig;
        "module/workspace" = workspaceConfig;
        "module/window" = windowConfig;
        "module/volume" = pulseaudioVolumeConfig;
      };
  };
}
