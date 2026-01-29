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
  ];

  networking.hostName = "alexandria";
  networking.hostId = "2cbf9c15";

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/nvme0n1";
      useOSProber = true;
    };

    # This is configuration needed to use ZFS on the NAS
    supportedFilesystems = [ "zfs" ];
    zfs.devNodes = "/dev/disk/by-id/";
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  # we bind mount the nas to the export location
  fileSystems."/export/nas/media" = {
    device = "/mnt/nas/media";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export/nas       10.69.8.0/24(rw,fsid=0,sync,no_subtree_check,root_squash)
      /export/nas/media 10.69.8.0/24(rw,nohide,sync,no_subtree_check,root_squash)
    '';
  };

  # NOTE: Uncomment this to allow automounting this nas
  # boot.zfs.extraPools = [ "nas" ];

  # WARNING: Read comment in lib/constants.nix file!
  system.stateVersion = constants.stateVersion;
}
