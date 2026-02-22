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
    (self + /nixos/server.nix)
    (self + /nixos/services/glances.nix)
    (self + /nixos/services/kavita.nix)
    (self + /nixos/services/alexandria-nas-nfs.nix)
  ];

  networking = {
    hostName = "yggdrasil";
    hostId = "6e9d6c6c";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # WARNING: Read comment in lib/constants.nix file!
  system.stateVersion = constants.stateVersion;
}
