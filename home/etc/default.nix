{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./alacritty
    ./fzf
    ./git
    ./gnupg
    ./helix
    ./herbstluftwm
    ./kakoune
    ./lazygit
    ./neofetch
    ./password-store
    ./picom
    ./polybar
    ./qtile
    ./ssh
    ./sxhkd
    ./tmux
    ./xinit
    ./zsh
  ];
}
