# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  constants,
  self,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./nas-configuration.nix
    (self + /nixos/server.nix)
    (self + /nixos/services/glances.nix)
  ];

  networking = {
    hostName = "alexandria";
    hostId = "2cbf9c15";
  };

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/nvme0n1";
      useOSProber = true;
    };
  };

  # WARNING: Read comment in lib/constants.nix file!
  system.stateVersion = constants.stateVersion;
}
