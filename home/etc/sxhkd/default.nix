{ inputs, lib, config, pkgs, systemConfig, ... }: let
  terminal = "${pkgs.alacritty}/bin/alacritty";
  termPromptLauncher = script: lineNum: columnNum: fontSize:
    let
      saveWindowId = "$HOME/.config/sxhkd/navi/tools/save_active_window_id.py";
      fontOption = "--option 'font.size=${builtins.toString (systemConfig.fontScale * fontSize)}'";
      lineOption = "--option 'window.dimensions.lines=${builtins.toString lineNum}'";
      columnOption = "--option 'window.dimensions.columns=${builtins.toString columnNum}'";
      termClass = "--class 'termprompt,termprompt'";
    in
    # To be clear, not all commands need the saveWindowId script. But some commands do need to have
    # this window id saved before the terminal instance is spawed. To be safe, we simply do it for
    # all of them thanks to this function
    "${saveWindowId}; ${terminal} ${termClass} ${fontOption} ${lineOption} ${columnOption} --command ${script}";
  ProgramLauncher = termPromptLauncher "$HOME/.config/sxhkd/fzf-program-launcher.sh" 16 80 9;
  WindowSwitcher = termPromptLauncher "$HOME/.config/sxhkd/window_switcher.py" 20 100 9;
  PasswordStore = termPromptLauncher "$HOME/.config/sxhkd/fzf-password-store.sh" 14 100 9;
  SystemManager = termPromptLauncher "$HOME/.config/sxhkd/system_manager.py" 6 40 12;
  WorkspaceManager = termPromptLauncher "$HOME/.config/sxhkd/workspace_manager.py" 10 120 9;
  FileSystemExplorer = termPromptLauncher "$HOME/.config/sxhkd/file_system_explorer.py" 35 164 8;
  FileSystemOpen = termPromptLauncher "$HOME/.config/sxhkd/file_system_open.py" 35 164 8;
  ManPageOpen = termPromptLauncher "$HOME/.config/sxhkd/man_open.py" 35 164 8;
  NotesManager = termPromptLauncher "$HOME/.config/sxhkd/notes_manager.py" 35 164 8;
  RipGrep = termPromptLauncher "$HOME/.config/sxhkd/ripgrep.py" 35 164 8;
  Calculator = termPromptLauncher "$HOME/.config/sxhkd/calculator.py" 12 96 12;
  GitManager = termPromptLauncher "$HOME/.config/sxhkd/git_manager.py" 35 164 8;
  maimScreenshot = "$HOME/.config/sxhkd/maim-screenshot.sh";
in {
  xdg.configFile."sxhkd/file_preview.sh".source = ../../../scripts/file_preview.sh;
  xdg.configFile."sxhkd/man_preview.sh".source = ../../../scripts/man_preview.sh;
  xdg.configFile."sxhkd/file_system_explorer.py".source = ../../../scripts/file_system_explorer.py;
  xdg.configFile."sxhkd/file_system_open.py".source = ../../../scripts/file_system_open.py;
  xdg.configFile."sxhkd/fzf-password-store.sh".source = ../../../scripts/fzf-password-store.sh;
  xdg.configFile."sxhkd/fzf-program-launcher.sh".source = ../../../scripts/fzf-program-launcher.sh;
  xdg.configFile."sxhkd/ripgrep.py".source = ../../../scripts/ripgrep.py;
  xdg.configFile."sxhkd/calculator.py".source = ../../../scripts/calculator.py;
  xdg.configFile."sxhkd/man_open.py".source = ../../../scripts/man_open.py;
  xdg.configFile."sxhkd/git_manager.py".source = ../../../scripts/git_manager.py;
  xdg.configFile."sxhkd/maim-screenshot.sh".source = ./maim-screenshot.sh;
  xdg.configFile."sxhkd/system_manager.py".source = ../../../scripts/system_manager.py;
  xdg.configFile."sxhkd/window_switcher.py".source = ../../../scripts/window_switcher.py;
  xdg.configFile."sxhkd/workspace_manager.py".source = ../../../scripts/workspace_manager.py;
  xdg.configFile."sxhkd/notes_manager.py".source = ../../../scripts/notes_manager.py;
  xdg.configFile."sxhkd/navi".source = ../../../scripts/navi;
  xdg.configFile."sxhkd/navi".recursive = true;
  xdg.configFile."sxhkd/nohup.sh".source = ../../../scripts/nohup.sh;

  services.sxhkd = {
    enable = true;
    keybindings = {
      # System Controls
      "super + ctrl + alt + Escape" = "${SystemManager}";
      
      # Core Utils
      "super + Return" = "${terminal}";
      "super + e" = "${ProgramLauncher}";

      # Desktop Environment
      "super + w" = "${WindowSwitcher}";
      "super + slash" = "${WorkspaceManager} --jump";
      "super + shift + slash" = "${WorkspaceManager} --move-window";
      "super + BackSpace" = "${WorkspaceManager} --delete";

      # Filesystem
      "super + x; x" = "${FileSystemExplorer}";
      "super + x; f" = "${FileSystemOpen} --file";
      "super + x; d" = "${FileSystemOpen} --directory";
      "super + x; shift + f" = "${FileSystemOpen} --file --global-search";
      "super + x; shift + d" = "${FileSystemOpen} --directory --global-search";
      "super + x; s" = "${RipGrep}";
      "super + x; shift + s" = "${RipGrep} --global-search";

      # Notes
      "super + n" = "${NotesManager}";

      # External Tools
      "super + g" = "${GitManager}";
      "super + shift + g" = "${GitManager} --open-dir";
      "super + m" = "${ManPageOpen}";
      "super + z" = "${Calculator}";

      # FIXME: This configuration should somehow be owned by password-store?
      "super + p"         = "${PasswordStore}";
      "super + shift + p" = "${PasswordStore} --qrcode";
      # Screenshot tool:
      #   Interactively select a window or rectangle with the mouse to take a screen
      #   shot of it. It's important that these keybindings are prefaces with the =@=
      #   token as it implies that the command should be executed on key release as
      #   opposed to key press. Scrot and xclip here will not work properly unless they
      #   are on key release.
      "@Print"         = "${maimScreenshot} -s";
      "@shift + Print" = "${maimScreenshot}";
      
      # Multimedia and Physical Switches
      "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
      "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -1%";

      # FIXME: These tools are not ready to use yet
      # "XF86MonBrightnessUp" = "xbacklight -inc 1 -time 10";
      # "XF86MonBrightnessDown" = "xbacklight -dec 1 -time 10";
      # "XF86AudioPlay" = "spotify-cli toggle";
      # "XF86AudioNext" = "spotify-cli next";
      # "XF86AudioPrev" = "spotify-cli prev";
    };
  };
}
