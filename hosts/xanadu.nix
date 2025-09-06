# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ../hardware/xanadu-thinkpad-25a.nix
    ../nixos
  ];

  networking.hostName = "xanadu";

  boot = {
    initrd = {
      # NOTE: This is for LUKS for SWAP.
      luks.devices."luks-9db61b5f-7b53-4108-883d-550e8b52c3c8" = {
        device = "/dev/disk/by-uuid/9db61b5f-7b53-4108-883d-550e8b52c3c8";
        keyFile = "/crypto_keyfile.bin";
      };
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
