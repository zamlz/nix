# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }: {

  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ../hardware/xynthar-thinkpad-p14s.nix
    ../nixos
  ];

  networking.hostName = "xynthar";

  # NOTE: This is for LUKS for SWAP.
  boot.initrd = {
    secrets = {
      "/crypto_keyfile.bin" = null;
    };
    luks.devices."luks-0224b369-12c1-4ea0-a732-6ee6ec2e1192" = {
      device = "/dev/disk/by-uuid/0224b369-12c1-4ea0-a732-6ee6ec2e1192";
      keyFile = "/crypto_keyfile.bin";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
