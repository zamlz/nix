{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}:
{
  imports = [ ../../home/cli ];

  # DO NOT CHANGE: home.stateVersion
  # This determines the home manager release that your configuration is
  # compatible with
  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    stateVersion = "23.05";
  };

  # IMPORTANT: Allows home manager to properly integrate with the original OS's
  # directories and settings
  targets.genericLinux.enable = true;
}
