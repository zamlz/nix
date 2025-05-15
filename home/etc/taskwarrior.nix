{ inputs, lib, config, pkgs, systemConfig, ... }: {
  programs.taskwarrior = {
    enable = true;
    config = {
      confirmation = false;
    };
  };
}
