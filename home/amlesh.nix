{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  imports =
    if systemConfig.useGUI
    then [./cli ./desktop]
    else [./cli];

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # This determines the Home Manager release that your configuration is
    # compatible with. DO NOT CHANGE
    stateVersion = "23.05";
  };

  # FIXME: What is this?
  systemd.user.startServices = "sd-switch";
}
