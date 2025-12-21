{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}:
{
  imports =
    if systemConfig.useGUI then
      [
        ./cli
        ./desktop
      ]
    else
      [ ./cli ];

  # DO NOT CHANGE: home.stateVersion
  # This determines the home manager release that your configuration is
  # compatible with
  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    stateVersion = "23.05";
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
