# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  constants,
  inputs,
  self,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    (self + /nixos/desktop.nix)
    (self + /nixos/services/glances.nix)
    (self + /nixos/services/immich.nix)
    (self + /nixos/services/ollama.nix)
    (self + /nixos/services/alexandria-nas-nfs.nix)
    inputs.slippi.nixosModules.default
  ];

  networking.hostName = "solaris";
  networking.hostId = "03f96989";

  boot = {
    # NOTE: This is for LUKS for SWAP.
    initrd = {
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
      luks.devices."luks-e547a75b-449e-4704-bc89-61587ce72de7" = {
        device = "/dev/disk/by-uuid/e547a75b-449e-4704-bc89-61587ce72de7";
        keyFile = "/crypto_keyfile.bin";
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # WARNING: Read comment in lib/constants.nix file!
  system.stateVersion = constants.stateVersion;
}
