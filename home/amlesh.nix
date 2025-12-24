{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  constants,
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

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # WARNING: Read comment in lib/constants.nix file!
    stateVersion = constants.stateVersion;
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
