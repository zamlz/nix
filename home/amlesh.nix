{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  # choose imports based on graphical or server environment
  imports =
    if systemConfig.useGUI
    then [ ./cli ./gui ] else [ ./cli ];

  # make sure to enable man pages for all things home-manager installs
  programs.man.generateCaches = true;

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
