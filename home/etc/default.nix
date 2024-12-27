{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./alacritty
    ./fzf
    ./git
    ./gnupg
    ./helix
    ./herbstluftwm
    ./kakoune
    ./kitty
    ./lazygit
    ./neofetch
    ./neovim
    ./password-store
    ./polybar
    ./qtile
    ./ssh
    ./sxhkd
    ./tmux
    ./xinit
    ./zsh
  ];
}
