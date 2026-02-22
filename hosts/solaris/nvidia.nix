{
  config,
  ...
}:
{
  # NOTE: Typically, this would be in gui.nix but we don't want this to apply
  # to all devices.
  services.xserver = {
    resolutions = [
      {
        x = 5120;
        y = 1440;
      }
    ];
    videoDrivers = [ "nvidia" ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # experimental and unstable!
    powerManagement.finegrained = false; # experimental and unstable!
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
