{ inputs, lib, config, pkgs, ... }: let
  terminal = "${pkgs.alacritty}/bin/alacritty";
  termPromptLauncher = script: lineNum: columnNum: fontSize:
    let
      fontOption = "--option 'font.size=${builtins.toString fontSize}'";
      lineOption = "--option 'window.dimensions.lines=${builtins.toString lineNum}'";
      columnOption = "--option 'window.dimensions.columns=${builtins.toString columnNum}'";
      termClass = "--class 'termprompt,termprompt'";
    in
    "${terminal} ${termClass} ${fontOption} ${lineOption} ${columnOption} --command ${script}";
  ProgramLauncher = termPromptLauncher "$HOME/.config/sxhkd/fzf-program-launcher.sh" 16 80 9;
  WindowSwitcher = termPromptLauncher "$HOME/.config/sxhkd/fzf-window-switcher.sh" 20 100 9;
  PasswordStore = termPromptLauncher "$HOME/.config/sxhkd/fzf-password-store.sh" 10 100 9;
  SystemManager = termPromptLauncher "$HOME/.config/sxhkd/fzf-system-manager.sh" 6 40 12;
  FileSystemExplorer = termPromptLauncher "$HOME/.config/sxhkd/fzf-file-system-explorer.sh" 35 164 8;
  FileSystemOpen = termPromptLauncher "$HOME/.config/sxhkd/fzf-file-system-open.sh" 35 164 8;
  LazyGit = termPromptLauncher "$HOME/.config/sxhkd/launch-lazygit.sh" 35 164 8;
  maimScreenshot = "$HOME/.config/sxhkd/maim-screenshot.sh";
  saveWindowId = "$HOME/.config/sxhkd/save-window-id.sh";
in {
  xdg.configFile."sxhkd/fzf-file-system-explorer.sh".source = ../../scripts/fzf-file-system-explorer.sh;
  xdg.configFile."sxhkd/fzf-file-system-open.sh".source = ../../scripts/fzf-file-system-open.sh;
  xdg.configFile."sxhkd/fzf-file-preview.sh".source = ../../scripts/fzf-file-preview.sh;
  xdg.configFile."sxhkd/fzf-password-store.sh".source = ../../scripts/fzf-password-store.sh;
  xdg.configFile."sxhkd/fzf-program-launcher.sh".source = ../../scripts/fzf-program-launcher.sh;
  xdg.configFile."sxhkd/fzf-system-manager.sh".source = ../../scripts/fzf-system-manager.sh;
  xdg.configFile."sxhkd/fzf-window-switcher.sh".source = ../../scripts/fzf-window-switcher.sh;
  xdg.configFile."sxhkd/get-window-info.sh".source = ../../scripts/get-window-info.sh;
  xdg.configFile."sxhkd/launch-lazygit.sh".source = ../../scripts/launch-lazygit.sh;
  xdg.configFile."sxhkd/maim-screenshot.sh".source = ./scripts/maim-screenshot.sh;
  xdg.configFile."sxhkd/save-window-id.sh".source = ../../scripts/save-window-id.sh;

  services.sxhkd = {
    enable = true;
    keybindings = {
      # Core utils
      "super + Return" = "${terminal}";
      "super + e" = "${ProgramLauncher}";
      "super + w" = "${WindowSwitcher}";
      "super + g" = "${saveWindowId}; ${LazyGit}";
      "super + x" = "${saveWindowId}; ${FileSystemExplorer}";
      "super + d" = "${saveWindowId}; ${FileSystemOpen} -d";
      "super + f" = "${saveWindowId}; ${FileSystemOpen} -f";
      "super + shift + d" = "${saveWindowId}; ${FileSystemOpen} -d -g";
      "super + shift + f" = "${saveWindowId}; ${FileSystemOpen} -f -g";
      
      # FIXME: This configuration should somehow be owned by password-store?
      "super + p"         = "${PasswordStore}";
      "super + shift + p" = "${PasswordStore} --qrcode";

      # System Controls
      "super + ctrl + alt + Escape" = "${SystemManager}";
      
      # Screenshot tool:
      #   Interactively select a window or rectangle with the mouse to take a screen
      #   shot of it. It's important that these keybindings are prefaces with the =@=
      #   token as it implies that the command should be executed on key release as
      #   opposed to key press. Scrot and xclip here will not work properly unless they
      #   are on key release.
      "@Print"         = "${maimScreenshot} -s";
      "@shift + Print" = "${maimScreenshot}";
      
      # Multimedia and Physical Switches
      # "XF86MonBrightnessUp" = "";
      # "XF86MonBrightnessDown" = "";
      # "XF86AudioMute" = "";
      # "XF86AudioMicMute" = "";
      # "XF86AudioRaiseVolume" = "";
      # "XF86AudioLowerVolume" = "";
      # "XF86AudioPlay" = "";
      # "XF86AudioNext" = "";
      # "XF86AudioPrev" = "";
    };
  };
}
