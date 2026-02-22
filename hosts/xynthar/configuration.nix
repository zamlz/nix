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
    (self + /nixos/desktop.nix)
    (self + /nixos/services/alexandria-nas-nfs.nix)
  ];

  networking = {
    hostName = "xynthar";
    hostId = "f820da9f";
  };

  boot = {
    # NOTE: This is for LUKS for SWAP.
    initrd = {
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
      luks.devices."luks-0224b369-12c1-4ea0-a732-6ee6ec2e1192" = {
        device = "/dev/disk/by-uuid/0224b369-12c1-4ea0-a732-6ee6ec2e1192";
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
