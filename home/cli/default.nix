{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./awscli.nix
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
    ./notes
    ./man.nix
    ./neovim.nix # [unused]
    ./password-store.nix
    ./ssh.nix
    ./systemd.nix
    ./taskwarrior.nix
    ./tmux.nix
    ./yt-dlp.nix
    ./zsh
  ];

  home.packages =
    (with pkgs; [
      # System CLI Tools
      htop
      pstree
      mediainfo
      pv
      qpdf
      ripgrep
      rsync
      curl
      less
      tree
      zip
      unzip
      jq
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
        ]
      ))
    ])
    ++ [
      inputs.mdutils.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
