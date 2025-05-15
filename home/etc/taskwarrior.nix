{ inputs, lib, config, pkgs, systemConfig, ... }: {
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    colorTheme = "dark-256";
    config = {
      confirmation = false;
      color.calendar.weekend = "green";
    };
  };
}
