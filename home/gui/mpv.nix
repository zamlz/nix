{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.mpv = {
    enable = true;
    scripts = [pkgs.mpvScripts.mpv-cheatsheet];
  };
}
