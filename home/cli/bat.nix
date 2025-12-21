{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.bat = {
    enable = true;
    config = {
      color = "always";
      theme = "ansi";
      style = "numbers";
    };
  };
}
