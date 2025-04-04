{ inputs, lib, config, pkgs, ... }: {

  hardware.graphics.enable = true;

  services.libinput.enable = true;

  services.xserver = {
    enable = true;
    autoRepeatDelay = 400;
    autoRepeatInterval = 50;
    displayManager.startx.enable = true;
  };
}
