{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: {
  hardware.graphics.enable = true;

  services.libinput.enable = true;

  services.xserver =
    if systemConfig.useGUI
    then {
      enable = true;
      autoRepeatDelay = 400;
      autoRepeatInterval = 50;
      displayManager.startx.enable = true;
    }
    else {};

  # Note: Unfortunately I have to leave i3lock here because
  # it is the only way it will be properly configured with PAM.
  # Ideally, I could move everything as far into my home-manager
  # config as possible.
  programs.i3lock.enable = systemConfig.useGUI;
}
