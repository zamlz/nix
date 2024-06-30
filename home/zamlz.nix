{ inputs, lib, config, pkgs, ... }: {

  imports = [ ./etc ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # bugfix github issue #2942
      allowUnfreePredicate = (_: true);
    };
  };
  
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
      # System CLI Tools
      neofetch
      ripgrep
      # Fun CLI Tools
      cmatrix
      figlet
      lolcat
      bat
      # Fonts
      iosevka
      # Desktop Environment Utilities
      feh
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
      # Misc Experiments
      pipenv
      (python3.withPackages (ps: with ps; [ipython]))
    ];
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
