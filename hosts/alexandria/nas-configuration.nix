_: {
  # Allows access to the NFS server
  networking.firewall.allowedTCPPorts = [ 2049 ];

  boot = {
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
}
