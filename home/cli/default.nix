{
  pkgs,
  ...
}:
{
  imports = [
    ./bat.nix
    ./claude.nix
    ./eza.nix
    ./fastfetch.nix
    ./fd.nix
    ./fzf.nix
    ./git.nix
    ./gnupg
    ./helix.nix # [unused]
    ./home-manager.nix
    ./kakoune
    ./lazygit.nix
    ./man.nix
    ./neovim.nix # [unused]
    ./password-store.nix
    ./ssh.nix
    ./systemd.nix
    ./taskwarrior.nix
    ./tmux.nix
    ./trash-cli.nix
    ./yt-dlp.nix
    ./zsh
  ];

  home.packages = with pkgs; [
    # System CLI Tools
    mediainfo
    pv
    qpdf
    ripgrep
    rsync
    # Fun CLI Tools
    cmatrix
    figlet
    kittysay
    lolcat
    # Misc Experiments
    pipenv
    (python3.withPackages (
      ps: with ps; [
        ipdb
        ipython
        loguru # FIXME: navi dependencies should be tracked separately
      ]
    ))
  ];
}
