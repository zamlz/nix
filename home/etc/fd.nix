{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # A simple, fast and user-friendly alternative to 'find'
  programs.fd = {
    enable = true;
    ignores = [
      "*.git/" # never ever touch anything in this directory
    ];
  };
}
