{
  pkgs,
  config,
  ...
}:
let
  # FIXME: All alacritty launches (regardless of termprompt) should be generalized
  # This means that things like working directory should be set
  terminal = "${pkgs.alacritty}/bin/alacritty";
  # FIXME: Consolidate this to a script so it is easier to generalize
  termPromptLauncher =
    script: lineNum: columnNum: fontSize:
    let
      fontOption = "--option 'font.size=${builtins.toString (config.my.fontScale * fontSize)}'";
      lineOption = "--option 'window.dimensions.lines=${builtins.toString lineNum}'";
      columnOption = "--option 'window.dimensions.columns=${builtins.toString columnNum}'";
      termClass = "--class 'termprompt,termprompt'";
    in
    # To be clear, not all commands need the navi-save-window-id script. But some commands do need to have
    # this window id saved before the terminal instance is spawed. To be safe, we simply do it for
    # all of them thanks to this function
    "navi-save-window-id; ${terminal} ${termClass} ${fontOption} ${lineOption} ${columnOption} --command ${script}";
  IdenticalTerminalLauncher = "navi-save-window-id; ${terminal} -e navi-spawn-shell";
  Calculator = termPromptLauncher "navi-calculator" 12 96 12;
  FileSystemExplorer = termPromptLauncher "navi-file-explorer" 35 164 8;
  FileSystemOpen = termPromptLauncher "navi-file-open" 35 164 8;
  GitManager = termPromptLauncher "navi-git" 35 164 8;
  LogJournalEntry = termPromptLauncher "$HOME/usr/notes/bin/notes log" 20 128 9;
  maimScreenshot = ./maim-screenshot.sh;
  ManPageOpen = termPromptLauncher "navi-man" 35 164 8;
  PasswordStore = termPromptLauncher "navi-pass" 14 100 9;
  ProgramLauncher = termPromptLauncher "navi-launcher" 16 80 9;
  RipGrep = termPromptLauncher "navi-ripgrep" 35 164 8;
  SystemManager = termPromptLauncher "navi-system" 6 40 12;
  WindowSwitcher = termPromptLauncher "navi-window" 20 128 9;
  WorkspaceManager = termPromptLauncher "navi-workspace" 10 120 9;
in
{
  services.sxhkd = {
    enable = true;
    # You can use xev to find keysyms for X11
    keybindings = {
      # System Controls
      "super + ctrl + alt + Escape" = "${SystemManager}";

      # Core Utils
      "super + Return" = "${terminal}";
      "super + shift + Return" = "${IdenticalTerminalLauncher}";
      "super + e" = "${ProgramLauncher}";

      # Desktop Environment
      "super + w" = "${WindowSwitcher}";
      "super + slash" = "${WorkspaceManager} --jump";
      "super + shift + slash" = "${WorkspaceManager} --move-window";
      "super + BackSpace" = "${WorkspaceManager} --delete";

      # Filesystem
      "super + x; a" = "${FileSystemExplorer}";
      "super + x; s" = "${RipGrep}";
      "super + x; d" = "${FileSystemOpen} --directory";
      "super + x; f" = "${FileSystemOpen} --file";
      "super + x; shift + a" = "${FileSystemExplorer} --global-search";
      "super + x; shift + s" = "${RipGrep} --global-search";
      "super + x; shift + d" = "${FileSystemOpen} --directory --global-search";
      "super + x; shift + f" = "${FileSystemOpen} --file --global-search";

      # Notes
      "super + n" = "${LogJournalEntry}";

      # External Tools
      "super + g" = "${GitManager}";
      "super + shift + g" = "${GitManager} --open-dir";
      "super + m" = "${ManPageOpen}";
      "super + z" = "${Calculator}";

      # FIXME: This configuration should somehow be owned by password-store?
      "super + p" = "${PasswordStore}";
      "super + shift + p" = "${PasswordStore} --qrcode";
      # Screenshot tool:
      #   Interactively select a window or rectangle with the mouse to take a screen
      #   shot of it. It's important that these keybindings are prefaces with the =@=
      #   token as it implies that the command should be executed on key release as
      #   opposed to key press. Scrot and xclip here will not work properly unless they
      #   are on key release.
      "@Print" = "${maimScreenshot} -s";
      "@shift + Print" = "${maimScreenshot}";

      # Multimedia and Physical Switches
      "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
      "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
    };
  };
}
