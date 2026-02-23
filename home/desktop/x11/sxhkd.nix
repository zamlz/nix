{
  config,
  ...
}:
let
  terminal = "navi-term";
  # termPromptLauncher uses navi-term which abstracts terminal-specific options
  # navi-term automatically saves the focused window ID before spawning, so commands
  # like navi-spawn-identical-shell can determine which directory to use
  termPromptLauncher =
    script: lineNum: columnNum: fontSize:
    let
      scaledFontSize = builtins.toString (config.my.fontScale * fontSize);
    in
    "navi-term --app-id termprompt --lines ${builtins.toString lineNum} --columns ${builtins.toString columnNum} --font-size ${scaledFontSize} -e ${script}";
  IdenticalTerminalLauncher = "${terminal} --inherit-cwd";
  Calculator = termPromptLauncher "navi-calculator" 12 96 12;
  FileSystemExplorer = termPromptLauncher "navi-file-explorer" 35 164 8;
  FileSystemOpen = termPromptLauncher "navi-file-open" 35 164 8;
  GitManager = termPromptLauncher "navi-git" 35 164 8;
  LogJournalEntry = termPromptLauncher "$HOME/usr/notes/bin/notes log" 20 128 9;
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

      "@Print" = "${config.xdg.configHome}/sxhkd/maim-screenshot.sh -s";
      "@shift + Print" = "${config.xdg.configHome}/sxhkd/maim-screenshot.sh";

      # Multimedia and Physical Switches
      "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
      "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
    };
  };

  # Screenshot tool:
  #   Interactively select a window or rectangle with the mouse to take a screen
  #   shot of it. It's important that these keybindings are prefaces with the =@=
  #   token as it implies that the command should be executed on key release as
  #   opposed to key press. Scrot and xclip here will not work properly unless they
  #   are on key release.
  xdg.configFile."sxhkd/maim-screenshot.sh" = {
    executable = true;
    text = /* sh */ ''
      #!/usr/bin/env sh

      # maim on it's own is a nice minimal screenshot tool that literally prints the
      # output back to STDOUT. We take that binary output and pipe it to a file and
      # the user's clipboard.

      maim --hidecursor "$@" /dev/stdout \
          | tee "$HOME/tmp/$(date +'%Y-%m-%dT%H:%M:%S%:z').png" \
          | xclip -selection clipboard -target image/png
    '';
  };
}
