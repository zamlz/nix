{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--group"
      "--header"
      "--git"
      "--classify=always"
      "--time-style=long-iso"
    ];
    git = true;
    icons = null;
    # https://github.com/eza-community/eza-themes/blob/main/themes/default.yml
    theme = {
      users = {
        user_you = {
          foreground = "Blue";
          is_bold = false;
        };
        group_yours = {
          foreground = "Magenta";
          is_bold = false;
        };
      };
      date = {
        foreground = "Cyan";
        is_dimmed = true;
      };
    };
  };

  # Override `ls` to eza by setting the shell alias to it
  programs.zsh.shellAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
  };
}
