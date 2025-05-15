{ inputs, lib, config, pkgs, systemConfig, ... }: {
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      confirmation = false;
    };
  };
}
