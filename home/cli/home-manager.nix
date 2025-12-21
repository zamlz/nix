{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # Let home manger install and manage itself
  programs.home-manager.enable = true;
}
