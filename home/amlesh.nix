{ inputs, lib, config, pkgs, systemConfig, ... }: let
  cliImports = [
    ./etc/fd.nix
    ./etc/fzf.nix
    ./etc/git.nix
    ./etc/gnupg.nix
    ./etc/helix.nix  # [unused]
    ./etc/kakoune.nix
    ./etc/lazygit.nix
    ./etc/neovim  # [unused]
    ./etc/password-store.nix
    ./etc/ssh.nix
    ./etc/systemd.nix
    ./etc/tmux.nix
    ./etc/zk.nix
    ./etc/zsh
  ];
  cliPackages = with pkgs; [
    # NixOS specific tools
    nh
    nix-search-cli
    # System CLI Tools
    bat
    microfetch
    qpdf
    ripgrep
    unzip
    yt-dlp
    zip
    # Fun CLI Tools
    cmatrix
    figlet
    kittysay
    lolcat
    # Misc Experiments
    pipenv
    (python3.withPackages (ps: with ps; [
        ipdb
        ipython
        loguru  # FIXME: navi dependencies should be tracked seperately
    ]))
  ];
  guiImports = [
    ./etc/alacritty.nix
    ./etc/feh.nix
    ./etc/herbstluftwm.nix
    ./etc/kitty.nix  # [unused]
    ./etc/mpv.nix
    ./etc/polybar
    ./etc/sxhkd
    ./etc/xinit
  ];
  guiPackages = with pkgs; [
    # Fonts
    iosevka
    # Desktop Utilities
    imagemagick
    qrencode
    i3lock
    maim  # needed by sxhkd (screenshot script)
    wmctrl
    xclip # needed by sxhkd (screenshot script)
    xdotool
    # Web
    firefox
    qutebrowser
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
  imports = (
    if systemConfig.useGUI then
      cliImports ++ guiImports
    else
      cliImports
  );

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
    packages = (
      if systemConfig.useGUI then
        cliPackages ++ guiPackages
      else
        cliPackages
    );
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
