{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports = [
    ./bat.nix
    ./claude.nix
    ./eza.nix
    ./fastfetch.nix
    ./fd.nix
    ./fzf.nix
    ./git.nix
    ./gnupg.nix
    ./helix.nix # [unused]
    ./kakoune.nix
    ./lazygit.nix
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
}
