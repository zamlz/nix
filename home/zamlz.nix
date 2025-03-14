{ inputs, lib, config, pkgs, ... }: {

  imports = [
      ./etc/alacritty.nix
      ./etc/fd.nix
      ./etc/feh.nix
      ./etc/fzf.nix
      ./etc/git.nix
      ./etc/gnupg.nix
      ./etc/helix.nix  # [unused]
      ./etc/herbstluftwm.nix
      ./etc/kakoune.nix
      ./etc/kitty.nix  # [unused]
      ./etc/lazygit.nix
      ./etc/mpv.nix
      ./etc/neovim  # [unused]
      ./etc/password-store.nix
      ./etc/polybar
      ./etc/ssh.nix
      ./etc/sxhkd
      ./etc/tmux.nix
      ./etc/xinit
      ./etc/zk.nix
      ./etc/zsh
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # make sure to enable man pages for all things home-manager installs
  programs.man.generateCaches = true;

  home = {
    # This determines the Home Manager release that your configuration is
    # compatible with. DO NOT CHANGE
    stateVersion = "23.05";
    username = "zamlz";
    homeDirectory = "/home/zamlz";
    packages = with pkgs; [
      # NixOS specific tools
      nh
      nix-search-cli
      # System CLI Tools
      microfetch
      ripgrep
      zip
      bat
      unzip
      qpdf
      yt-dlp
      # Fun CLI Tools
      cmatrix
      figlet
      lolcat
      kittysay
      # Fonts
      iosevka
      # Desktop Environment Utilities
      imagemagick
      qrencode
      i3lock
      maim  # needed by sxhkd (screenshot script)
      wmctrl
      xclip # needed by sxhkd (screenshot script)
      xdotool
      # GUI Apps
      firefox
      qutebrowser
      spotify
      # DAW Software & derivatives
      puredata
      plugdata
      bitwig-studio
      vital
      mixxx
      # Misc Experiments
      pipenv
      (python3.withPackages (ps: with ps; [
          ipdb
          ipython
          loguru  # FIXME: navi dependencies should be tracked seperately
      ]))
    ];
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
