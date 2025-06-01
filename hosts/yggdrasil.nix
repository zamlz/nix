# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }: {

  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ../hardware/yggdrasil-cincoze-ds1201.nix
    ../nixos
  ];

  networking.hostName = "yggdrasil";
  networking.hostId = "6e9d6c6c";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Mount my nas running on alexandria
  # FIXME: remove this duplication found on all my hosts
  fileSystems."/mnt/media" = {
    device = "10.69.8.4:/media";
    fsType = "nfs";
    # enable lazy mounting for this share
    options = [ "x-systemd.automount" "noauto"];
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
