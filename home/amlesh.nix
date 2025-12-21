{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: let
  cliImports = [
    ./etc/bat.nix
    ./etc/claude.nix
    ./etc/eza.nix
    ./etc/fastfetch.nix
    ./etc/fd.nix
    ./etc/fzf.nix
    ./etc/git.nix
    ./etc/gnupg.nix
    ./etc/helix.nix # [unused]
    ./etc/kakoune.nix
    ./etc/lazygit.nix
    ./etc/neovim.nix # [unused]
    ./etc/password-store.nix
    ./etc/ssh.nix
    ./etc/systemd.nix
    ./etc/taskwarrior.nix
    ./etc/tmux.nix
    ./etc/trash-cli.nix
    ./etc/yt-dlp.nix
    ./etc/zsh
  ];
  cliPackages = with pkgs; [
    # System CLI Tools
    mediainfo
    pv
    qpdf
    ripgrep
    rsync
    yt-dlp
    # Fun CLI Tools
    cmatrix
    figlet
    kittysay
    lolcat
    # Nix Dev Tools
    alejandra
    deadnix
    statix
    # Misc Experiments
    pipenv
    (python3.withPackages (ps:
      with ps; [
        ipdb
        ipython
        loguru # FIXME: navi dependencies should be tracked seperately
      ]))
  ];
  guiPackages = with pkgs; [
    # Fonts
    iosevka
    # Desktop Utilities
    arandr
    imagemagick
    qrencode
    maim # needed by sxhkd (screenshot script)
    wmctrl
    xclip # needed by sxhkd (screenshot script)
    xdotool
    # Web
    firefox
    # Entertainment
    spotify
    # DAW Software & derivatives
    puredata
    plugdata
    bitwig-studio
    vital
    mixxx
  ];
in {
  # choose imports based on graphical or server environment
  imports =
    if systemConfig.useGUI
    then cliImports ++ [ ./gui ]
    else cliImports;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # make sure to enable man pages for all things home-manager installs
  programs.man.generateCaches = true;

  home = {
    # This determines the Home Manager release that your configuration is
    # compatible with. DO NOT CHANGE
    stateVersion = "23.05";
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    packages =
      if systemConfig.useGUI
      then cliPackages ++ guiPackages
      else cliPackages;
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
